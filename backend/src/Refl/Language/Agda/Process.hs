-- | One @agda --interaction-json@ subprocess.
--
-- Framing (verified against Agda 2.8.0): before reading each command Agda
-- prints the prompt @JSON> @ (no newline) and flushes; the responses to a
-- command follow as one JSON object per line, the first of them on the same
-- line as the prompt. A command is therefore complete when, after consuming
-- every full line, the unconsumed tail of the stream is exactly the prompt.
module Refl.Language.Agda.Process
  ( AgdaProc
  , startAgda
  , sendCmd
  , stopAgda
  ) where

import           Control.Concurrent.MVar
import           Control.Exception          (SomeException, try, mask, onException)
import           Control.Monad              (void, when)
import           Data.Aeson                 (eitherDecodeStrict)
import qualified Data.ByteString            as BS
import qualified Data.ByteString.Char8      as BC
import           Data.IORef
import           Data.Text                  (Text)
import qualified Data.Text                  as T
import qualified Data.Text.Encoding         as TE
import           Data.Text.Encoding.Error   (lenientDecode)
import qualified Data.Text.IO               as TIO
import           System.Environment         (getEnvironment)
import           System.IO
import           System.Process
import           System.Timeout             (timeout)

import           Refl.Language.Agda.IOTCM
import           Refl.Language.Agda.Response
import           Refl.Process

data AgdaProc = AgdaProc
  { apIn     :: Handle
  , apOut    :: Handle
  , apProc   :: ProcessHandle
  , apBuf    :: IORef BS.ByteString
  , apLock   :: MVar ()
  , apLog    :: Text -> IO ()
  }

prompt :: BS.ByteString
prompt = "JSON> "

-- | Spawn agda in @cwd@ with extra environment, and wait for the first prompt.
startAgda :: (Text -> IO ()) -> FilePath -> [(String, String)] -> FilePath -> IO (Either Text AgdaProc)
startAgda logf exe extraEnv cwd = do
  r <- trySync $ mask $ \restore -> do
    env0 <- getEnvironment
    let env' = extraEnv ++ filter ((`notElem` map fst extraEnv) . fst) env0
    (Just hin, Just hout, _, ph) <- createProcess (proc exe ["--interaction-json"])
      { std_in = CreatePipe, std_out = CreatePipe, std_err = Inherit
      , cwd = Just cwd, env = Just env', create_group = True }
    hSetBinaryMode hout True
    hSetBuffering hin LineBuffering
    hSetEncoding hin utf8
    buf <- newIORef BS.empty
    lock <- newMVar ()
    let p = AgdaProc hin hout ph buf lock logf
    ok <- restore (timeout (60 * 1000000) (readUntilPrompt p)) `onException` stopProcess ph
    case ok of
      Nothing -> stopAgda p >> fail "agda did not print its prompt"
      Just (Left e) -> stopAgda p >> fail (T.unpack e)
      Just (Right _) -> pure p
  pure $ case r of
    Left (e :: SomeException) -> Left ("could not start agda: " <> T.pack (show e))
    Right p -> Right p

-- | Send one command and collect its responses (until the next prompt).
-- Times out with 'Left' after the given number of seconds; the caller should
-- then abort/kill the process.
sendCmd :: AgdaProc -> Int -> FilePath -> Cmd -> IO (Either Text [AgdaResponse])
sendCmd p secs file cmd = withMVar (apLock p) $ \_ -> do
  let line = renderIOTCM file cmd
  apLog p ("→ " <> line)
  r <- try $ do
    TIO.hPutStrLn (apIn p) line
    hFlush (apIn p)
  case r of
    Left (e :: SomeException) -> pure (Left ("agda stdin closed: " <> T.pack (show e)))
    Right () -> do
      res <- timeout (secs * 1000000) (readUntilPrompt p)
      pure $ case res of
        Nothing -> Left "agda timed out; retry the session"
        Just (Left e) -> Left e
        Just (Right rs) -> Right rs

-- | Read lines until the stream's tail is a bare prompt. Each complete line
-- (with a leading prompt stripped) is decoded as one response.
readUntilPrompt :: AgdaProc -> IO (Either Text [AgdaResponse])
readUntilPrompt p = go []
 where
  go acc = do
    buf <- readIORef (apBuf p)
    let (ls, rest) = splitLines buf
    rs <- mapM decodeLine ls
    writeIORef (apBuf p) rest
    let acc' = acc ++ concat rs
    if rest == prompt
      then writeIORef (apBuf p) BS.empty >> pure (Right acc')
      else do
        chunk <- BS.hGetSome (apOut p) 65536
        if BS.null chunk
          then pure (Left ("agda exited; last output: " <> TE.decodeUtf8With lenientDecode (BS.take 2000 rest)))
          else modifyIORef' (apBuf p) (<> chunk) >> go acc'
  decodeLine l0 = do
    let l = stripPrompt l0
    if BS.null (BC.strip l) then pure [] else
      case eitherDecodeStrict l of
        Left err -> do
          let message = "agda: unparsable line: " <> T.pack err <> ": " <> TE.decodeUtf8With lenientDecode (BS.take 300 l)
          apLog p message
          pure [ROther message]
        Right v -> do
          let r = decodeResponse v
          when False (apLog p (T.pack (show r)))
          pure [r]
  stripPrompt l | prompt `BS.isPrefixOf` l = BS.drop (BS.length prompt) l
                | otherwise = l

-- | Complete lines and the unterminated tail.
splitLines :: BS.ByteString -> ([BS.ByteString], BS.ByteString)
splitLines bs = case BC.elemIndexEnd '\n' bs of
  Nothing -> ([], bs)
  Just i  -> (BC.lines (BS.take i bs), BS.drop (i + 1) bs)

stopAgda :: AgdaProc -> IO ()
stopAgda p = do
  void (try (TIO.hPutStrLn (apIn p) (renderIOTCM "" AExit) >> hFlush (apIn p)) :: IO (Either SomeException ()))
  r <- timeout (2 * 1000000) (waitForProcess (apProc p))
  case r of
    Just _  -> pure ()
    Nothing -> stopProcess (apProc p)
  void (try (hClose (apIn p)) :: IO (Either SomeException ()))
  void (try (hClose (apOut p)) :: IO (Either SomeException ()))
