-- Real HTTP/WebSocket contract checks, also run inside the NixOS VM.
module Main (main) where
import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (withAsync)
import Control.Concurrent.MVar
import Control.Exception (SomeException, bracket, try)
import Control.Monad (unless, void, replicateM_)
import Data.Aeson (encode, eitherDecode)
import qualified Data.ByteString.Char8 as BS
import qualified Data.ByteString.Lazy as BL
import qualified Data.Map as M
import qualified Data.Text as T
import Network.HTTP.Client hiding (port)
import Network.HTTP.Types (statusCode)
import qualified Network.WebSockets as WS
import System.Environment (getArgs)
import System.Timeout (timeout)
import Refl.Protocol.Types

assert label ok = unless ok (fail label)
main = do
  args <- getArgs
  let port = case args of [p] -> read p; _ -> 8125
      base = "http://127.0.0.1:" ++ show port
      origin = BS.pack base
  manager <- newManager defaultManagerSettings
  let get path cookie = do
        req <- parseRequest (base ++ path)
        httpLbs req { requestHeaders = [("Cookie", cookie) | not (BS.null cookie)] } manager
      socket cookie ori = WS.runClientWith "127.0.0.1" port "/ws" WS.defaultConnectionOptions
        [("Cookie", cookie), ("Origin", ori)]
      send c = WS.sendTextData c . encode
      receive c = do
        raw <- WS.receiveData c
        either fail pure (eitherDecode raw :: Either String ServerMsg)
      open c = do
        send c (OpenSession (LangId "agda") (WorldId "tutorial") (LevelId "refl"))
        receive c >>= \case
          SessionOpened _ _ t -> pure t
          other -> fail ("expected session: " ++ show other)
      rejected label action = do
        r <- timeout 10000000 (try @SomeException action)
        assert label (case r of Just (Left _) -> True; _ -> False)
      cookie = do
        r <- get "/api/progress" ""
        assert "HTTP success" (statusCode (responseStatus r) == 200)
        let value = maybe "" id (lookup "Set-Cookie" (responseHeaders r))
        assert "secure host-only cookie" (all (`BS.isInfixOf` value) ["__Host-refl=", "; Secure", "; HttpOnly", "; SameSite=Strict", "; Path=/"] && not ("Domain=" `BS.isInfixOf` value))
        pure (BS.takeWhile (/= ';') value)
  a <- cookie
  b <- cookie
  assert "independent random identities" (a /= b)
  rejected "cross-origin rejected" (socket a "https://attacker.invalid" (const (pure ())))
  rejected "missing identity rejected" (socket "" origin (const (pure ())))
  socket a origin $ \c -> do
    _ <- open c
    send c (Check "two-plus-two = refl\n")
    receive c >>= \case
      Checked r -> assert "proof solved" (crVerdict r == Solved)
      _ -> fail "expected Checked"
    send c (SaveDraft "two-plus-two = ?\n-- identity A draft\n")
    send c Ping
    receive c >>= assert "draft committed before next message" . (== Pong)
  threadDelay 300000
  socket b origin $ \c -> do
    t <- open c
    assert "draft isolation" (not ("identity A" `T.isInfixOf` t))
  threadDelay 300000
  socket a origin $ \c -> do
    t <- open c
    assert "draft restored across sockets" ("identity A" `T.isInfixOf` t)
  pa <- get "/api/progress" a
  pb <- get "/api/progress" b
  let decodeP r = either fail pure (eitherDecode (responseBody r) :: Either String Progress)
  progressA <- decodeP pa
  progressB <- decodeP pb
  assert "HTTP progress isolation" (not (M.null (prCompleted progressA)) && M.null (prCompleted progressB))
  threadDelay 500000
  let holds 0 action = action
      holds n action = do
        ready <- newEmptyMVar
        release <- newEmptyMVar
        withAsync (socket a origin (\_ -> putMVar ready () >> takeMVar release)) $ \_ -> do
          arrived <- timeout 5000000 (takeMVar ready)
          assert "capacity socket admitted" (arrived == Just ())
          holds (n-1) action
          putMVar release ()
  holds (4 :: Int) (rejected "fifth concurrent connection rejected" (socket b origin (const (pure ()))))
  threadDelay 500000
  socket a origin $ \c -> do
    send c Ping
    receive c >>= assert "capacity released" . (== Pong)
    WS.sendTextData c (BL.replicate 65537 120)
    rejected "oversized message closes socket" (receive c)
  threadDelay 300000
  socket a origin $ \c -> rejected "idle timeout closes socket" (receive c)
  putStrLn "security: cookies, origins, progress/drafts, concurrency, message and idle limits passed"
