-- | The Bend 2 plugin: a batch driver. Every check writes the spliced level
-- next to the support files and runs @bend Level.bend@; the verdict is read
-- off the exit code and the text report (Bend has no JSON, LSP or REPL).
--
-- Holes are Bend's own: a loud @?name@ fails the check and prints the goal,
-- a quiet @?TODO@ leaves it open. The Goal command asks Bend for a hole's
-- goal by making that hole the only loud one and re-running; Give replaces
-- the hole's text and the server re-checks.
module Refl.Language.Bend2
  ( bend2
  , BendReport (..)
  , parseBendReport
  , reportResult
  , holesIn
  ) where

import           Control.Concurrent           (forkIO)
import           Control.Concurrent.MVar
import           Control.Exception            (SomeException, try)
import           Control.Monad                (forM_, void)
import           Data.Aeson                   (Value (Null))
import qualified Data.ByteString              as BS
import           Data.Char                    (isDigit, isSpace)
import           Data.List                    (find, isSuffixOf)
import           Data.Maybe                   (mapMaybe)
import           Data.Text                    (Text)
import qualified Data.Text                    as T
import qualified Data.Text.Encoding           as TE
import           Data.Text.Encoding.Error     (lenientDecode)
import qualified Data.UUID                    as UUID
import qualified Data.UUID.V4                 as UUID
import           System.Directory             (copyFile, createDirectoryIfMissing,
                                               listDirectory, removeDirectoryRecursive)
import           System.Environment           (getEnvironment)
import           System.Exit                  (ExitCode (..))
import           System.FilePath              ((</>))
import           System.Process
import           System.Timeout               (timeout)

import           Refl.Content.Frontmatter     (writeFileUtf8)
import           Refl.Content.Splice
import           Refl.Language
import           Refl.Protocol.Types
import           Refl.Verify

bend2 :: Language
bend2 = Language
  { langInfo = LangInfo (LangId "bend2") "Bend 2" "bend" "none" True
  , langCommands = [CmdLoad, CmdGoal, CmdGive]
  , langStaticRules = \src user ->
      bendRules src user ++ forbiddenIdentifiers "#" (lsForbidsNames src) user
  , langStart = start
  }

data St = St
  { stDir  :: FilePath
  , stFile :: FilePath
  }

start :: Env -> LevelSources -> IO (Either Text ProverSession)
start env src = case envBend env of
  Nothing -> pure (Left "Bend 2 is not configured on this server (--bend).")
  Just exe -> do
    uuid <- UUID.nextRandom
    let dir = envWorkRoot env </> ("bend-" ++ UUID.toString uuid)
        st = St dir (dir </> "Level.bend")
    createDirectoryIfMissing True (dir </> "home")
    -- the support files (Refl.bend …) sit next to the level: `import ./Refl.bend`
    forM_ (envBendPath env) $ \sup -> do
      fs <- listDirectory sup
      forM_ [ f | f <- fs, ".bend" `isSuffixOf` f ] $ \f -> copyFile (sup </> f) (dir </> f)
    writeFileUtf8 (stFile st) (splice src "" (lsTemplate src))
    pure $ Right ProverSession
      { psCheck = check env exe src st
      , psHole = hole env exe src st
      , psClose = void (try (removeDirectoryRecursive dir) :: IO (Either SomeException ()))
      }

-- ---------------------------------------------------------------------------
-- Running bend
-- ---------------------------------------------------------------------------

-- | @bend Level.bend@ in the session directory, under a timeout; HOME and
-- BEND_LIB point into the session so nothing is written elsewhere.
runBend :: Env -> FilePath -> St -> Text -> IO (Either Text (ExitCode, Text, Text))
runBend env exe st text = do
  writeFileUtf8 (stFile st) text
  env0 <- getEnvironment
  let extra = [ ("HOME", stDir st </> "home"), ("BEND_LIB", stDir st </> "lib"), ("BEND_NO_TELEMETRY", "1") ]
      env' = extra ++ filter ((`notElem` map fst extra) . fst) env0
      cp = (proc exe [stFile st]) { cwd = Just (stDir st), env = Just env'
                                  , std_in = NoStream, std_out = CreatePipe, std_err = CreatePipe }
  r <- try $ withCreateProcess cp $ \_ mout merr ph -> do
    outV <- newEmptyMVar
    errV <- newEmptyMVar
    let slurp mh v = void $ forkIO $ do
          bs <- maybe (pure BS.empty) BS.hGetContents mh
          putMVar v (TE.decodeUtf8With lenientDecode bs)
    slurp mout outV
    slurp merr errV
    done <- timeout (60 * 1000000) (waitForProcess ph)
    case done of
      Nothing -> do
        terminateProcess ph
        void (waitForProcess ph)
        pure (Left "bend took more than 60 seconds; the check was stopped.")
      Just code -> do
        out <- takeMVar outV
        err <- takeMVar errV
        logMsg env ("bend exit " <> T.pack (show code) <> ": " <> T.take 400 err)
        pure (Right (code, out, err))
  pure $ case r of
    Left (e :: SomeException) -> Left ("could not run bend: " <> T.pack (show e))
    Right x -> x

-- ---------------------------------------------------------------------------
-- The report
-- ---------------------------------------------------------------------------

-- | What @bend@ said, structurally.
data BendReport
  = BendOk Text                                    -- ^ stdout ("All terms check." or the program's output)
  | BendTodos Int                                  -- ^ quiet holes / open laws left
  | BendHole Text Text [ContextEntry] (Maybe Int)  -- ^ loud hole: name, expected type, context, file line
  | BendMismatch Text Text [ContextEntry] (Maybe Int)  -- ^ expected, observed, context, file line
  | BendOther Text                                 -- ^ anything else on stderr
  deriving (Eq, Show)

parseBendReport :: ExitCode -> Text -> Text -> BendReport
parseBendReport ExitSuccess out _ = BendOk (T.strip out)
parseBendReport _ _ err = case T.lines (T.strip err) of
  (l : rest)
    | Just n <- todos l -> BendTodos n
    | T.strip l == "Error:" ->
        let field k = mapMaybe (T.stripPrefix ("- " <> k <> " : ")) rest
            ctx = [ ContextEntry (T.strip n) (T.strip (T.drop 3 rest')) True
                  | l' <- takeWhile (/= "Location:") (drop 1 (dropWhile (/= "Context:") (map T.stripEnd rest)))
                  , Just body <- [T.stripPrefix "- " l'], (n, rest') <- [T.breakOn " : " body], not (T.null rest') ]
            line = case mapMaybe markedLine rest of
              n : _ -> Just n
              [] -> Nothing
        in case (field "expected", field "observed") of
          (e : _, o : _) | "?" `T.isPrefixOf` T.strip o -> BendHole (T.strip o) (T.strip e) ctx line
                         | otherwise -> BendMismatch (T.strip e) (T.strip o) ctx line
          (e : _, []) -> BendMismatch (T.strip e) "" ctx line
          _ -> BendOther (T.strip err)
  _ -> BendOther (T.strip err)
 where
  todos l = case T.stripPrefix "Error: " l >>= T.stripSuffix " found." . T.stripEnd of
    Just body | (ds, w) <- T.span isDigit body, not (T.null ds), T.strip w `elem` ["TODO", "TODOs"] -> Just (read (T.unpack ds))
    _ -> Nothing
  -- the listing marks the offending line as @ 7>|@
  markedLine l = let (ds, rest) = T.span isDigit (T.dropWhile isSpace l)
                 in if not (T.null ds) && ">|" `T.isPrefixOf` rest then Just (read (T.unpack ds)) else Nothing

-- | The @?name@ holes of the user region, in order, with code-point spans.
holesIn :: Text -> [(Text, Span)]
holesIn user = go 0
 where
  n = T.length user
  go i | i >= n = []
       | T.index user i == '?' && (i == 0 || isDelim (T.index user (i - 1))) =
           let name = T.takeWhile (not . isDelim) (T.drop (i + 1) user)
           in if T.null name then go (i + 1) else ("?" <> name, Span i (i + 1 + T.length name)) : go (i + 1 + T.length name)
       | otherwise = go (i + 1)
  isDelim c = isSpace c || c `elem` ("()[]{};,\"" :: String)

-- | Assemble the 'CheckResult' for the user region from bend's report.
reportResult :: LevelSources -> Text -> BendReport -> CheckResult
reportResult src user rep = CheckResult
  { crHoles = holes
  , crDiagnostics = diags
  , crHighlight = []
  , crVerdict = verdictFrom [] diags nGoals
  , crStatus = status
  , crExtras = Null
  }
 where
  named = holesIn user
  typeOf name = case rep of
    BendHole h ty _ _ | h == name -> Just ty
    _ -> Nothing
  holes = [ Hole (HoleId i) sp (typeOf name) | (i, (name, sp)) <- zip [0 ..] named ]
  nGoals = case rep of
    BendOk _ -> 0
    BendTodos k -> max k (length named)
    BendHole {} -> max 1 (length named)
    _ -> length named
  prefixLines = T.count "\n" (lsPrefix src)
  lineSpan fileLine =
    let u = fileLine - 1 - prefixLines
        ls = T.splitOn "\n" user
    in if u < 0 || u >= length ls then Nothing
       else let off = sum (map ((+ 1) . T.length) (take u ls)) in Just (Span off (off + T.length (ls !! u)))
  showCtx ctx = T.concat [ "\n" <> ceName c <> " : " <> ceType c | c <- ctx ]
  diags = case rep of
    BendOk _ -> []
    BendTodos k -> [ Diagnostic SevInfo Nothing (T.pack (show k) <> (if k == 1 then " goal left (?TODO)." else " goals left (?TODO).")) ]
    BendHole name ty ctx line ->
      [ Diagnostic SevInfo (line >>= lineSpan) ("Goal " <> name <> " : " <> ty <> showCtx ctx) ]
    BendMismatch e o ctx line ->
      [ Diagnostic SevError (line >>= lineSpan)
          ("expected : " <> e <> (if T.null o then "" else "\nobserved : " <> o) <> showCtx ctx) ]
    BendOther msg -> [ Diagnostic SevError Nothing msg ]
  status = case crVerdict' of
    Solved -> case rep of
      BendOk out | not (T.null out) -> out
      _ -> "All terms check."
    Unsolved k -> T.pack (show k) <> " open goal" <> (if k == 1 then "" else "s")
    Failed -> "Error"
    Rejected _ -> "Rejected"
  crVerdict' = verdictFrom [] diags nGoals

-- ---------------------------------------------------------------------------
-- Check and hole operations
-- ---------------------------------------------------------------------------

check :: Env -> FilePath -> LevelSources -> St -> Text -> IO CheckResult
check env exe src st user = do
  let vs = langStaticRules bend2 src user
  if not (null vs) then pure (rejected vs) else do
    r <- runBend env exe st (splice src "" user)
    pure $ case r of
      Left e -> CheckResult [] [Diagnostic SevError Nothing e] [] Failed ("Bend: " <> e) Null
      Right (code, out, err) -> reportResult src user (parseBendReport code out err)

hole :: Env -> FilePath -> LevelSources -> St -> Text -> Target -> HoleOp -> IO HoleOutcome
hole env exe src st user target op = case op of
  OpGoal _ -> withHole $ \(_, sp) -> do
    -- make this the only loud hole, so bend reports its goal first
    let probe = rebuild 0 (holesIn user)
        rebuild i [] = T.drop i user
        rebuild i ((_, s@(Span a b)) : rest) =
          T.take (a - i) (T.drop i user) <> (if s == sp then "?refl_goal" else "?TODO") <> rebuild b rest
    if not (null (langStaticRules bend2 src probe)) then pure (OutError "Fix the rejected text first.") else do
      r <- runBend env exe st (splice src "" probe)
      pure $ case r of
        Left e -> OutError e
        Right (code, out, err) -> case parseBendReport code out err of
          BendHole "?refl_goal" ty ctx _ -> OutGoal (Goal target ty ctx Null)
          BendOk _ -> OutError "No goal here: the file already checks."
          BendMismatch e o _ _ -> OutError ("The file does not check before this hole: expected " <> e <> ", observed " <> o)
          BendTodos _ -> OutError "Bend did not report this hole; check the file first."
          BendHole h _ _ _ -> OutError ("Bend stopped at " <> h <> " first; fill the earlier holes or ask for that one.")
          BendOther m -> OutError m
  OpGive e -> withHole $ \(_, Span a b) ->
    pure (OutText (T.take a user <> e <> T.drop b user))
  _ -> pure (OutError "Bend 2 levels are edited directly; Check, Goal and Give are available.")
 where
  withHole k = case target of
    TargetHole (HoleId i) -> case drop i (holesIn user) of
      h : _ -> k h
      [] -> pure (OutError "That hole no longer exists; check the file again.")
    TargetPos cur -> case find (\(_, Span a b) -> cur >= a && cur <= b) (holesIn user) of
      Just h -> k h
      Nothing -> pure (OutError "Put the cursor on a hole (?name) first.")
