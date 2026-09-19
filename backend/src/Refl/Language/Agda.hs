-- | The Agda plugin: one @agda --interaction-json@ per session, the level
-- file re-spliced on every check, hole operations mapped onto agda-mode's
-- commands and their text edits applied server-side.
module Refl.Language.Agda
  ( agda
  , replaceSpan
  , applyMakeCase
  , isUnsolvedWarning
  , resultFrom
  , tidyMessage
  ) where

import           Control.Exception            (SomeException, try, onException)
import           Control.Monad                (void)
import           Data.Char                    (isDigit)
import           Data.Aeson                   (Value (Null))
import           Data.IORef
import           Data.List                    (find)
import           Data.Maybe                   (mapMaybe)
import           Data.Text                    (Text)
import qualified Data.Text                    as T
import qualified Data.UUID                    as UUID
import qualified Data.UUID.V4                 as UUID
import           System.Directory             (createDirectoryIfMissing,
                                               removeDirectoryRecursive)
import           System.FilePath              (takeDirectory, (<.>), (</>))

import           Refl.Content.Splice
import           Refl.Content.Frontmatter     (writeFileUtf8)
import           Refl.Language
import           Refl.Language.Agda.IOTCM
import           Refl.Language.Agda.Process
import           Refl.Language.Agda.Response
import           Refl.Protocol.Types
import           Refl.Verify

agda :: Language
agda = Language
  { langInfo = LangInfo (LangId "agda") "Agda" "agda" "agda" True commands
  , langCommands = commands
  , langStaticRules = \src user ->
      agdaRules src user ++ forbiddenIdentifiers "--" (lsForbidsNames src) user
  , langStart = start
  }
 where
  commands = [CmdLoad, CmdGoal, CmdGive, CmdRefine, CmdCase, CmdAuto, CmdInfer, CmdNormalise, CmdSolveAll]

data St = St
  { stProc   :: AgdaProc
  , stDir    :: FilePath
  , stFile   :: FilePath
  , stLoaded :: IORef (Maybe (Text, [Hole]))   -- ^ last successfully loaded user text and its holes
  }

start :: Env -> LevelSources -> IO (Either Text ProverSession)
start env src = do
  uuid <- UUID.nextRandom
  let dir = envWorkRoot env </> ("agda-" ++ UUID.toString uuid)
      relPath = T.unpack (T.replace "." "/" (lsModuleName src)) <.> "agda"
      file = dir </> relPath
  createDirectoryIfMissing True (takeDirectory file)
  writeFileUtf8 (dir </> "refl-level.agda-lib")
    "name: refl-level\ninclude: .\ndepend: standard-library refl-support\n"
  writeFileUtf8 file (splice src "" (lsTemplate src))
  let extra = [("LC_ALL", "en_US.UTF-8")] ++ maybe [] (\d -> [("AGDA_DIR", d)]) (envAgdaDir env)
  r <- startAgda (logMsg env) (envAgda env) extra dir `onException` removeDirectoryRecursive dir
  case r of
    Left e -> removeDirectoryRecursive dir >> pure (Left e)
    Right p -> do
      ref <- newIORef Nothing
      let st = St p dir file ref
      pure $ Right ProverSession
        { psCheck = check env src st
        , psHole  = hole env src st
        , psClose = do
            stopAgda p
            void (try (removeDirectoryRecursive dir) :: IO (Either SomeException ()))
        }

-- ---------------------------------------------------------------------------
-- Check
-- ---------------------------------------------------------------------------

check :: Env -> LevelSources -> St -> Text -> IO CheckResult
check env src st user = do
  let vs = langStaticRules agda src user
  writeIORef (stLoaded st) Nothing
  if not (null vs) then pure (rejected vs) else do
    writeFileUtf8 (stFile st) (splice src "" user)
    r <- sendCmd (stProc st) 120 (stFile st) ALoad
    case r of
      Left e -> do
        logMsg env ("agda load failed: " <> e)
        writeIORef (stLoaded st) Nothing
        pure (failure e)
      Right rs -> do
        let res0 = resultFrom src user rs
            res = res0 { crDiagnostics = map tidy (crDiagnostics res0) }
            tidy d = d { diagMessage = tidyMessage (stFile st) (T.count "\n" (lsPrefix src)) (diagMessage d) }
        if crVerdict res == Failed then pure () else
          writeIORef (stLoaded st) (Just (user, crHoles res))
        pure res

failure :: Text -> CheckResult
failure e = CheckResult [] [Diagnostic SevError Nothing e] [] Failed ("Agda: " <> e) Null

-- | Assemble a 'CheckResult' from the responses to a load.
resultFrom :: LevelSources -> Text -> [AgdaResponse] -> CheckResult
resultFrom src user rs = CheckResult
  { crHoles = holes
  , crDiagnostics = diags
  , crHighlight = hls
  , crVerdict = verdictFrom [] diags nGoals
  , crStatus = status
  , crExtras = Null
  }
 where
  off = userOffset src
  ulen = T.length user
  toUser a b = let a' = a - 1 - off; b' = b - 1 - off
               in if a' >= 0 && b' <= ulen && a' <= b' then Just (Span a' b') else Nothing
  ips = concat [ x | RInteractionPoints x <- rs ]
  -- Every display counts: a goals report and an error display can both
  -- appear, and each error must be reported exactly once.
  goalsReports = [ (v, i, w, e) | RDisplay (DAllGoals v i w e) <- rs ]
  errorDisplays = [ (m, w) | RDisplay (DError m w) <- rs ]
  (vis, invis) = case goalsReports of
    (v, i, _, _) : _ -> (v, i)
    [] -> ([], [])
  warns = concat [ w | (_, _, w, _) <- goalsReports ] ++ concat (map snd errorDisplays)
  errs = concat [ e | (_, _, _, e) <- goalsReports ] ++ [ Msg m jumpPos | (m, _) <- errorDisplays ]
  jumpPos = case [ p | RJumpToError p <- rs ] of
    p : _ -> Just (p, p + 1)
    []    -> Nothing
  holes = [ Hole (HoleId i) sp (lookup i [ (geId g, geType g) | g <- vis ])
          | (i, Just (a, b)) <- ips, Just sp <- [toUser a b] ]
  hls = [ HighlightSpan sp atoms
        | RHighlighting xs <- rs, HL a b atoms <- xs, not (null atoms), Just sp <- [toUser a b] ]
  -- A prompt alone is not evidence of successful checking: a load that
  -- reports no error must also have produced exactly one goals report, one
  -- interaction-point list and a final status (checked, or goals left).
  -- Agda answers a failing load with an Error display and nothing else, so
  -- completeness is only demanded when there is no error.
  complete = case reverse [ b | RStatus b <- rs ] of
    checked : _ -> (checked || nGoals > 0)
             && length [ () | RDisplay (DAllGoals {}) <- rs ] == 1
             && length [ () | RInteractionPoints _ <- rs ] == 1
    _ -> False
  unknown = [ t | ROther t <- rs ] ++ [ t | RDisplay (DOtherInfo t _) <- rs ]
  protocolErrors =
    [ Diagnostic SevError Nothing "Agda's answer to the load was incomplete; check the file again."
    | null errs, not complete ]
    ++ [ Diagnostic SevError Nothing ("Unrecognized Agda response: " <> T.take 300 t) | t <- unknown ]
  diags = protocolErrors ++ [ Diagnostic SevError (msgSpan m) (msgText m) | m <- errs ]
       ++ [ Diagnostic (if isUnsolvedWarning (msgText m) then SevInfo else SevError) (msgSpan m) (msgText m)
          | m <- warns ]
  msgSpan m = msgRange m >>= uncurry toUser
  nGoals = maximum [length vis + length invis, length ips,
                    if any (isUnsolvedWarning . msgText) warns then 1 else 0]
  status
    | not (null errs) = "Error"
    | nGoals > 0 = T.pack (show nGoals) <> " open goal" <> (if nGoals == 1 then "" else "s")
    | any ((== SevError) . diagSeverity) diags = "Warnings are errors here"
    | otherwise = "All goals solved"

-- | Agda names the session's absolute file path and whole-file lines in its
-- messages; show the player lines of their own region instead.
tidyMessage :: FilePath -> Int -> Text -> Text
tidyMessage path prefixLines msg = case T.splitOn (T.pack path) msg of
  [] -> msg
  (first : rest) -> T.concat (first : map relocate rest)
 where
  relocate piece = case T.uncons piece of
    Just (':', more) | (ds, after) <- T.span isDigit more, not (T.null ds) ->
      let (rest', after') = position after
      in location (read (T.unpack ds)) rest' <> after'
    _ -> "the level file" <> piece
  -- the part of a range after the line number: ".c", ".c-c'" or ".c-l'.c'"
  position t = let (loc, after) = T.span (\c -> isDigit c || c == '.' || c == '-') t in (loc, after)
  location l rest'
    | l > prefixLines = "line " <> T.pack (show (l - prefixLines)) <> rest'
    | otherwise = "the fixed prelude, line " <> T.pack (show l) <> rest'

-- | Warnings Agda reports for open goals; they are already counted as goals.
isUnsolvedWarning :: Text -> Bool
isUnsolvedWarning t = any (`T.isInfixOf` t)
  ["Unsolved interaction metas", "Unsolved metas", "UnsolvedInteractionMetas", "UnsolvedMetaVariables"]

-- ---------------------------------------------------------------------------
-- Hole operations
-- ---------------------------------------------------------------------------

hole :: Env -> LevelSources -> St -> Text -> Target -> HoleOp -> IO HoleOutcome
hole env src st user target op = do
  loaded <- readIORef (stLoaded st)
  ok <- case loaded of
    Just (t, _) | t == user -> pure True
    _ -> do
      r <- check env src st user
      pure (crVerdict r /= Failed && notRejected (crVerdict r))
  if not ok then pure (OutError "The file does not load; fix the errors first.") else do
    Just (_, holes) <- readIORef (stLoaded st)
    case target of
      TargetPos _ -> pure (OutError "Agda commands act on a hole: select one first.")
      TargetHole hid -> case find ((== hid) . holeId) holes of
        Nothing -> pure (OutError "That hole no longer exists; check the file again.")
        Just h  -> run h
 where
  notRejected (Rejected _) = False
  notRejected _            = True
  send cmd = sendCmd (stProc st) 60 (stFile st) cmd
  run h = do
    let i = unHoleId (holeId h)
        sp = holeSpan h
    case op of
      OpGoal n -> withResp (send (AGoalTypeContext (rewriteOf n) i)) $ \rs ->
        case [ g | RDisplay (DGoalSpecific _ g) <- rs ] of
          GIGoalType ty es : _ -> OutGoal (Goal target ty es Null)
          GICurrentGoal ty : _ -> OutGoal (Goal target ty [] Null)
          _ -> OutError "No goal information returned."
      OpGive e -> giveLike sp e (send (AGive i e))
      OpRefine e -> giveLike sp e (send (ARefineOrIntro False i e))
      OpIntro -> giveLike sp "" (send (ARefineOrIntro True i ""))
      OpCase vars -> withResp (send (AMakeCase i vars)) $ \rs ->
        case [ (v, cs) | RMakeCase v cs <- rs ] of
          (_, cs) : _ -> OutText (applyMakeCase user sp cs)
          [] -> OutError "Case split produced no clauses."
      OpAuto -> withResp (send (AAutoOne i)) $ \rs ->
        case [ gr | RGiveAction _ gr <- rs ] of
          gr : _ -> OutText (replaceSpan sp (giveText gr "") user)
          [] -> case [ s | RMimer (Just s) <- rs ] of
            s : _ -> OutText (replaceSpan sp s user)
            [] -> case [ m | RDisplay (DAuto m) <- rs ] of
              m : _ -> OutInfo "Auto" (if T.null m then "No solution found." else m)
              [] -> OutInfo "Auto" "No solution found."
      OpInfer n e -> withResp (send (AInfer (rewriteOf n) i e)) $ \rs ->
        case [ t | RDisplay (DGoalSpecific _ (GIInferred t)) <- rs ] ++ [ t | RDisplay (DInferred t) <- rs ] of
          t : _ -> OutInfo ("Type of " <> e) t
          [] -> OutError "Could not infer a type."
      OpNormalise e -> withResp (send (ACompute i e)) $ \rs ->
        case [ t | RDisplay (DGoalSpecific _ (GINormalForm t)) <- rs ] ++ [ t | RDisplay (DNormalForm t) <- rs ] of
          t : _ -> OutInfo ("Normal form of " <> e) t
          [] -> OutError "Could not normalise."
      OpHelperType f -> withResp (send (AHelperFunction Normalised i f)) $ \rs ->
        case [ s | RDisplay (DGoalSpecific _ (GIHelper s)) <- rs ] of
          s : _ -> OutInfo ("Helper " <> f) s
          [] -> OutError "No helper type returned."
  giveLike sp e action = withResp action $ \rs ->
    case [ gr | RGiveAction _ gr <- rs ] of
      gr : _ -> OutText (replaceSpan sp (giveText gr e) user)
      [] -> OutError "Agda did not accept the expression."
  withResp action k = do
    r <- action
    pure $ case r of
      Left e -> OutError e
      Right rs -> case [ m | RDisplay (DError m _) <- rs ] of
        m : _ -> OutError m
        [] -> k rs

giveText :: GiveResult -> Text -> Text
giveText (GiveString s) _ = s
giveText GiveParen e      = "(" <> e <> ")"
giveText GiveNoParen e    = e

-- | Replace a code-point span of the text.
replaceSpan :: Span -> Text -> Text -> Text
replaceSpan (Span a b) new t = T.take a t <> new <> T.drop b t

-- | agda-mode's make-case edit: replace the goal's line, from its first
-- non-blank character to its end, with the clauses joined by newlines at the
-- same indentation.
applyMakeCase :: Text -> Span -> [Text] -> Text
applyMakeCase t (Span a _) clauses =
  let before = T.take a t
      lineStart = maybe 0 (+ 1) (lastIndexOf '\n' before)
      after = T.drop a t
      lineEnd = a + maybe (T.length after) id (T.findIndex (== '\n') after)
      line = T.take (lineEnd - lineStart) (T.drop lineStart t)
      indent = T.length (T.takeWhile (== ' ') line)
      body = T.intercalate ("\n" <> T.replicate indent " ") clauses
  in T.take (lineStart + indent) t <> body <> T.drop lineEnd t
 where
  lastIndexOf c s = case mapMaybe (\(i, ch) -> if ch == c then Just i else Nothing) (zip [0 ..] (T.unpack s)) of
    [] -> Nothing
    is -> Just (last is)
