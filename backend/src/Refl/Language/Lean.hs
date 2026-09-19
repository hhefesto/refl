-- | The Lean 4 plugin: one @lean --server@ per session (LSP over stdio), the
-- level re-sent with @didChange@ on every check, goals via @$/lean/plainGoal@.
--
-- Lean has no hole ids, so hole operations are addressed by cursor offset
-- ('TargetPos'); only 'CmdLoad' and 'CmdGoal' are offered. A level is solved
-- when there are no errors, no @sorry@ warnings, and the @#print axioms@ line
-- the server appends reports only the standard axioms.
module Refl.Language.Lean
  ( lean
  , leanVerdict
  , theoremName
  , parseGoalText
  ) where

import           Control.Exception            (SomeException, try, mask, onException)
import           Control.Monad                (void)
import           Data.Aeson
import qualified Data.Aeson.KeyMap            as KM
import           Data.IORef
import           Data.List                    (isPrefixOf)
import           Data.Maybe                   (fromMaybe, mapMaybe)
import           Data.Text                    (Text)
import qualified Data.Text                    as T
import qualified Data.UUID                    as UUID
import qualified Data.UUID.V4                 as UUID
import qualified Data.Vector                  as V
import           System.Directory             (createDirectoryIfMissing,
                                               removeDirectoryRecursive)
import           System.FilePath              ((</>))

import           Refl.Content.Splice
import           Refl.Content.Frontmatter     (writeFileUtf8)
import           Refl.Language
import           Refl.Language.Lean.Rpc
import           Refl.Protocol.Types
import           Refl.Verify

lean :: Language
lean = Language
  { langInfo = LangInfo (LangId "lean") "Lean 4" "lean" "lean" True commands
  , langCommands = commands
  , langStaticRules = \src user ->
      leanRules src user ++ forbiddenIdentifiers "--" (lsForbidsNames src) user
  , langStart = start
  }
 where
  commands = [CmdLoad, CmdGoal]

data St = St
  { stRpc     :: Rpc
  , stDir     :: FilePath
  , stUri     :: Text
  , stVersion :: IORef Int
  , stLoaded  :: IORef (Maybe Text)
  }

allowedAxioms :: [Text]
allowedAxioms = ["propext", "Classical.choice", "Quot.sound", "sorryAx"]  -- sorryAx is reported as Unsolved via the warning

-- | The declaration the statement introduces, for @#print axioms@.
theoremName :: Text -> Maybe Text
theoremName stmt =
  case [ n | l <- T.lines stmt, (kw : n : _) <- [T.words l], kw `elem` ["theorem", "lemma"] ]
       ++ [ n | l <- T.lines stmt, (kw : n : _) <- [T.words l], kw == "def" ] of
    (n : _) -> Just n
    []      -> Nothing

suffixFor :: LevelSources -> Text
suffixFor src = maybe "" (\n -> "\n#print axioms " <> n <> "\n") (theoremName (lsStatement src))

start :: Env -> LevelSources -> IO (Either Text ProverSession)
start env src = case envLean env of
  Nothing -> pure (Left "Lean is not configured on this server (--lean).")
  Just exe -> mask $ \restore -> do
    uuid <- UUID.nextRandom
    let dir = envWorkRoot env </> ("lean-" ++ UUID.toString uuid)
        file = dir </> "Level.lean"
        uri = "file://" <> T.pack file
    createDirectoryIfMissing True dir
    let initial = splice src (suffixFor src) (lsTemplate src)
    writeFileUtf8 file initial
    let extra = maybe [] (\p -> [("LEAN_PATH", p)]) (envLeanPath env)
    r <- startRpc (logMsg env) exe ["--server"] extra dir
    case r of
      Left e -> pure (Left e)
      Right rpc -> do
        ini <- restore (request rpc 60 "initialize" $ object
          [ "processId" .= Null
          , "rootUri" .= ("file://" <> T.pack dir)
          , "capabilities" .= object []
          ]) `onException` stopRpc rpc
        case ini of
          Left e -> stopRpc rpc >> pure (Left e)
          Right _ -> do
            notify rpc "initialized" (object [])
            notify rpc "textDocument/didOpen" $ object
              [ "textDocument" .= object
                  [ "uri" .= uri, "languageId" .= ("lean4" :: Text), "version" .= (1 :: Int), "text" .= initial ] ]
            ver <- newIORef 1
            loaded <- newIORef Nothing
            let st = St rpc dir uri ver loaded
            pure $ Right ProverSession
              { psCheck = check env src st
              , psHole = hole env src st
              , psClose = do
                  stopRpc rpc
                  void (try (removeDirectoryRecursive dir) :: IO (Either SomeException ()))
              }

-- ---------------------------------------------------------------------------
-- Check
-- ---------------------------------------------------------------------------

check :: Env -> LevelSources -> St -> Text -> IO CheckResult
check env src st user = do
  let vs = langStaticRules lean src user
  if not (null vs) then pure (rejected vs) else do
    let full = splice src (suffixFor src) user
    v <- atomicModifyIORef' (stVersion st) (\n -> (n + 1, n + 1))
    notify (stRpc st) "textDocument/didChange" $ object
      [ "textDocument" .= object [ "uri" .= stUri st, "version" .= v ]
      , "contentChanges" .= [ object [ "text" .= full ] ] ]
    r <- request (stRpc st) 120 "textDocument/waitForDiagnostics" $ object
      [ "uri" .= stUri st, "version" .= v ]
    case r of
      Left e -> do
        logMsg env ("lean: " <> e)
        pure (CheckResult [] [Diagnostic SevError Nothing e] [] Failed ("Lean: " <> e) Null)
      Right _ -> do
        dv <- latestDiagnostics (stRpc st) (stUri st)
        let ds = maybe [] diagnosticsOf dv
            res = leanVerdict src user ds
        writeIORef (stLoaded st) (Just user)
        pure res

-- | (severity 1..4, start (line, char), end, message)
type LspDiag = (Int, (Int, Int), (Int, Int), Text)

diagnosticsOf :: Value -> [LspDiag]
diagnosticsOf (Object o) = case KM.lookup "diagnostics" o of
  Just (Array ds) -> mapMaybe one (V.toList ds)
  _ -> []
 where
  one (Object d) = do
    String msg <- KM.lookup "message" d
    let sev = case KM.lookup "severity" d of
          Just (Number n) -> round n
          _ -> 1 :: Int
    Object rng <- KM.lookup "range" d
    s <- pos =<< KM.lookup "start" rng
    e <- pos =<< KM.lookup "end" rng
    pure (sev, s, e, msg)
  one _ = Nothing
  pos (Object p) = do
    Number l <- KM.lookup "line" p
    Number c <- KM.lookup "character" p
    pure (round l, round c)
  pos _ = Nothing
diagnosticsOf _ = []

-- | Verdict from Lean diagnostics. "unsolved goals" errors and "sorry"
-- warnings mean the proof is incomplete, not wrong.
leanVerdict :: LevelSources -> Text -> [LspDiag] -> CheckResult
leanVerdict src user ds = CheckResult
  { crHoles = []
  , crDiagnostics = diags
  , crHighlight = []
  , crVerdict = verdict
  , crStatus = status
  , crExtras = object [ "axioms" .= axioms ]
  }
 where
  prefixLines = length (T.lines (lsPrefix src))
  userLines = T.splitOn "\n" user
  toUserSpan (l1, c1) (l2, c2) =
    let l1' = l1 - prefixLines; l2' = l2 - prefixLines
    in if l1' < 0 || l1' >= length userLines then Nothing
       else Just (Span (lineOffset l1' + c1) (min (T.length user) (lineOffset (min l2' (length userLines - 1)) + c2)))
  lineOffset n = sum (map ((+ 1) . T.length) (take n userLines))
  isUnsolved m = "unsolved goals" `T.isPrefixOf` m
              || ("declaration uses" `T.isInfixOf` m && "sorry" `T.isInfixOf` m)
  axiomLine = [ m | (_, _, _, m) <- ds, "depends on axioms" `T.isInfixOf` m || "does not depend on any axioms" `T.isInfixOf` m ]
  axioms = concatMap parseAxioms axiomLine
  parseAxioms m = case T.breakOn "[" m of
    (_, rest) | T.null rest -> []
              | otherwise -> map T.strip (T.splitOn "," (T.takeWhile (/= ']') (T.drop 1 rest)))
  badAxioms = filter (`notElem` allowedAxioms) axioms
  diags =
    [ Diagnostic (sevOf sev m) (toUserSpan s e) m
    | (sev, s, e, m) <- ds
    , not ("depends on axioms" `T.isInfixOf` m), not ("does not depend on any axioms" `T.isInfixOf` m) ]
    ++ [ Diagnostic SevError Nothing ("The proof uses forbidden axioms: " <> T.intercalate ", " badAxioms)
       | not (null badAxioms) ]
  sevOf sev m
    | isUnsolved m = SevInfo
    | sev == 1 = SevError
    | sev == 2 = SevWarning
    | otherwise = SevInfo
  unsolvedCount = sum [ max 1 (T.count "⊢" m) | (_, _, _, m) <- ds, isUnsolved m ]
  verdict = verdictFrom [] diags unsolvedCount
  status = case verdict of
    Solved -> "All goals solved"
    Unsolved n -> T.pack (show n) <> " open goal" <> (if n == 1 then "" else "s")
    Failed -> "Error"
    Rejected _ -> "Rejected"

-- ---------------------------------------------------------------------------
-- Goals
-- ---------------------------------------------------------------------------

hole :: Env -> LevelSources -> St -> Text -> Target -> HoleOp -> IO HoleOutcome
hole env src st user target op = do
  loaded <- readIORef (stLoaded st)
  case loaded of
    Just t | t == user -> pure ()
    _ -> void (check env src st user)
  case (target, op) of
    (TargetPos p, OpGoal _) -> do
      let (line, ch) = positionOf src user p
      r <- request (stRpc st) 30 "$/lean/plainGoal" $ object
        [ "textDocument" .= object [ "uri" .= stUri st ]
        , "position" .= object [ "line" .= line, "character" .= ch ] ]
      pure $ case r of
        Left e -> OutError e
        Right Null -> OutInfo "Goal" "No goal at this position (place the cursor inside the tactic block)."
        Right (Object o) ->
          let goals = case KM.lookup "goals" o of
                Just (Array gs) -> [ g | String g <- V.toList gs ]
                _ -> []
              rendered = case KM.lookup "rendered" o of
                Just (String s) -> s
                _ -> ""
          in case goals of
               [] -> OutInfo "Goal" (if T.null rendered then "No goals." else rendered)
               (g : _) -> let (ctx, ty) = parseGoalText g
                          in OutGoal (Goal target ty ctx (object [ "goals" .= goals, "rendered" .= rendered ]))
        Right v -> OutInfo "Goal" (T.pack (show v))
    (_, OpGoal _) -> pure (OutError "Lean goals are addressed by cursor position.")
    _ -> pure (OutError "Lean levels are edited directly; only Goal is available.")

-- | LSP position (line, UTF-16 character) of a code-point offset in the user region.
positionOf :: LevelSources -> Text -> Int -> (Int, Int)
positionOf src user p =
  let prefixLines = length (T.lines (lsPrefix src))
      before = T.take p user
      ls = T.splitOn "\n" before
      line = prefixLines + length ls - 1
      col = utf16Length (last ls)
  in (line, col)
 where
  utf16Length = sum . map (\c -> if fromEnum c > 0xFFFF then 2 else 1) . T.unpack

-- | Split a plain goal (@h : T\n⊢ goal@) into context entries and the goal.
parseGoalText :: Text -> ([ContextEntry], Text)
parseGoalText g =
  let ls = T.lines g
      (ctxLines, rest) = break ("⊢" `T.isPrefixOf`) ls
      goal = T.strip (T.unlines (map (T.dropWhile (== ' ') . T.dropWhile (== '⊢')) rest))
      entries = mapMaybe entry (joinContinuations ctxLines)
  in (entries, goal)
 where
  entry l = case T.breakOn " : " l of
    (n, rest) | T.null rest -> Nothing
              | otherwise -> Just (ContextEntry (T.strip n) (T.strip (T.drop 3 rest)) True)
  joinContinuations = foldr step []
   where
    step l acc | " " `isPrefixOf` T.unpack l, (a : as) <- acc = (l <> " " <> a) : as
               | otherwise = l : acc

_unused :: Maybe Int -> Int
_unused = fromMaybe 0
