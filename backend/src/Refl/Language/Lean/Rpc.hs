-- | A minimal LSP client over stdio (Content-Length framing) for
-- @lean --server@. Requests are matched to responses by id; notifications
-- from the server are kept in a per-uri map (diagnostics) or dropped; server
-- requests are answered with @null@ so the server never stalls.
module Refl.Language.Lean.Rpc
  ( Rpc
  , startRpc
  , request
  , notify
  , latestDiagnostics
  , stopRpc
  ) where

import           Control.Concurrent          (forkIO, killThread, ThreadId)
import           Control.Concurrent.MVar
import           Control.Exception           (SomeException, try, mask_)
import           Control.Monad               (forever, void)
import           Data.Aeson
import qualified Data.Aeson.KeyMap           as KM
import qualified Data.ByteString             as BS
import qualified Data.ByteString.Char8       as BC
import qualified Data.ByteString.Lazy        as BL
import           Data.IORef
import qualified Data.Map                    as M
import           Data.Text                   (Text)
import qualified Data.Text                   as T
import qualified Data.Text.Encoding          as TE
import           System.Environment          (getEnvironment)
import           System.IO
import           System.Process
import           System.Timeout              (timeout)
import           Refl.Process

data Rpc = Rpc
  { rIn      :: Handle
  , rOut     :: Handle
  , rProc    :: ProcessHandle
  , rNext    :: IORef Int
  , rPending :: MVar (M.Map Int (MVar Value))
  , rDiags   :: IORef (M.Map Text Value)   -- ^ uri → last publishDiagnostics params
  , rReader  :: ThreadId
  , rWrite   :: MVar ()
  , rLog     :: Text -> IO ()
  }

startRpc :: (Text -> IO ()) -> FilePath -> [String] -> [(String, String)] -> FilePath -> IO (Either Text Rpc)
startRpc logf exe args extraEnv cwd = do
  r <- trySync $ mask_ $ do
    env0 <- getEnvironment
    let env' = extraEnv ++ filter ((`notElem` map fst extraEnv) . fst) env0
    (Just hin, Just hout, _, ph) <- createProcess (proc exe args)
      { std_in = CreatePipe, std_out = CreatePipe, std_err = Inherit
      , cwd = Just cwd, env = Just env', create_group = True }
    hSetBinaryMode hin True
    hSetBinaryMode hout True
    next <- newIORef 1
    pending <- newMVar M.empty
    diags <- newIORef M.empty
    wlock <- newMVar ()
    let rpc0 = Rpc hin hout ph next pending diags undefined wlock logf
    tid <- forkIO (readerLoop rpc0)
    pure rpc0 { rReader = tid }
  pure $ case r of
    Left (e :: SomeException) -> Left ("could not start lean: " <> T.pack (show e))
    Right rpc -> Right rpc

-- | Write one message; a dead server (closed pipe) is reported, not thrown.
writeMessage :: Rpc -> Value -> IO (Either Text ())
writeMessage rpc v = withMVar (rWrite rpc) $ \_ -> do
  let body = BL.toStrict (encode v)
  r <- trySync $ do
    BS.hPut (rIn rpc) (BC.pack ("Content-Length: " ++ show (BS.length body) ++ "\r\n\r\n") <> body)
    hFlush (rIn rpc)
  pure $ case r of
    Left (e :: SomeException) -> Left ("lean: cannot write to the server: " <> T.pack (show e))
    Right () -> Right ()

readMessage :: Handle -> IO (Maybe BS.ByteString)
readMessage h = do
  r <- trySync (headers 0)
  case r of
    Left (_ :: SomeException) -> pure Nothing
    Right Nothing -> pure Nothing
    Right (Just n) -> do
      body <- trySync (BS.hGet h n)
      pure $ case body of
        Left (_ :: SomeException) -> Nothing
        Right b | BS.length b == n -> Just b
                | otherwise -> Nothing
 where
  headers len = do
    eof <- hIsEOF h
    if eof then pure Nothing else do
      l <- BS.hGetLine h
      let l' = BC.filter (/= '\r') l
      if BS.null l' then pure (Just len) else
        case BC.stripPrefix "Content-Length:" l' of
          Just rest -> case BC.readInt (BC.dropWhile (== ' ') rest) of
            Just (n, _) | n >= 0 && n <= 4194304 -> headers n
            Just _ -> fail "oversized Lean response"
            Nothing -> headers len
          Nothing -> headers len

readerLoop :: Rpc -> IO ()
readerLoop rpc = void $ try @SomeException $ forever $ do
  mb <- readMessage (rOut rpc)
  case mb of
    Nothing -> do
      -- process gone: fail every pending request
      ps <- swapMVar (rPending rpc) M.empty
      mapM_ (\mv -> void (tryPutMVar mv (object ["error" .= ("lean exited" :: Text)]))) (M.elems ps)
      fail "eof"
    Just body -> case decodeStrict body of
      Nothing -> rLog rpc ("lean: undecodable message: " <> TE.decodeUtf8 (BS.take 200 body))
      Just (Object o) -> dispatch o
      Just _ -> pure ()
 where
  dispatch o = case (KM.lookup "id" o, KM.lookup "method" o) of
    (Just (Number n), Nothing) -> do
      let i = round n
      mv <- modifyMVar (rPending rpc) $ \m -> pure (M.delete i m, M.lookup i m)
      case mv of
        Just v -> void (tryPutMVar v (Object o))
        Nothing -> pure ()
    (Just i, Just _) ->
      -- a server→client request: answer null
      void (writeMessage rpc (object ["jsonrpc" .= ("2.0" :: Text), "id" .= i, "result" .= Null]))
    (Nothing, Just (String "textDocument/publishDiagnostics")) ->
      case KM.lookup "params" o of
        Just p@(Object po) | Just (String uri) <- KM.lookup "uri" po ->
          modifyIORef' (rDiags rpc) (M.insert uri p)
        _ -> pure ()
    _ -> pure ()

-- | Send a request and wait up to @secs@ for its response object.
request :: Rpc -> Int -> Text -> Value -> IO (Either Text Value)
request rpc secs method params = do
  i <- atomicModifyIORef' (rNext rpc) (\n -> (n + 1, n))
  mv <- newEmptyMVar
  modifyMVar_ (rPending rpc) (pure . M.insert i mv)
  w <- writeMessage rpc (object ["jsonrpc" .= ("2.0" :: Text), "id" .= i, "method" .= method, "params" .= params])
  r <- case w of
    Left e -> modifyMVar_ (rPending rpc) (pure . M.delete i) >> pure (Just (object ["error" .= e]))
    Right () -> timeout (secs * 1000000) (takeMVar mv)
  case r of
    Nothing -> do
      modifyMVar_ (rPending rpc) (pure . M.delete i)
      pure (Left ("lean: timeout on " <> method))
    Just (Object o) -> pure $ case KM.lookup "error" o of
      Just e -> Left ("lean: " <> T.pack (show e))
      Nothing -> Right (maybe Null id (KM.lookup "result" o))
    Just v -> pure (Right v)

notify :: Rpc -> Text -> Value -> IO ()
notify rpc method params =
  void (writeMessage rpc (object ["jsonrpc" .= ("2.0" :: Text), "method" .= method, "params" .= params]))

latestDiagnostics :: Rpc -> Text -> IO (Maybe Value)
latestDiagnostics rpc uri = M.lookup uri <$> readIORef (rDiags rpc)

stopRpc :: Rpc -> IO ()
stopRpc rpc = do
  void (try (request rpc 2 "shutdown" Null) :: IO (Either SomeException (Either Text Value)))
  void (try (notify rpc "exit" Null) :: IO (Either SomeException ()))
  r <- timeout (2 * 1000000) (waitForProcess (rProc rpc))
  case r of
    Just _  -> pure ()
    Nothing -> stopProcess (rProc rpc)
  killThread (rReader rpc)
  void (try (hClose (rIn rpc)) :: IO (Either SomeException ()))
  void (try (hClose (rOut rpc)) :: IO (Either SomeException ()))
