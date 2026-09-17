-- Browser acceptance tests. Chrome is driven over CDP from Haskell; there
-- is no Node/WebDriver service. DOM expressions operate the real controls.
module Main (main) where

import Control.Concurrent (threadDelay)
import Control.Exception (bracket, finally)
import Control.Monad (forM_, unless, void)
import Data.Aeson
import Data.Aeson.Types (parseMaybe, (.:))
import qualified Data.ByteString.Lazy.Char8 as BL
import Data.IORef
import qualified Data.Map as M
import qualified Data.Text as T
import Network.URI (parseURI, uriPath, uriAuthority, uriPort)
import qualified Network.WebSockets as WS
import System.Directory
import System.Environment (getArgs)
import System.FilePath ((</>))
import System.IO (hClose, openTempFile)
import System.Process
import System.Timeout (timeout)

import Refl.Content
import Refl.Protocol.Types

main :: IO ()
main = do
  chrome : site : games : extra <- getArgs
  tmp <- getTemporaryDirectory
  (dir, h) <- openTempFile tmp "refl-browser"
  hClose h
  removeFile dir
  createDirectory dir
  let launch = do
        (_, _, _, p) <- createProcess (proc site (["--port", "8124", "--data-dir", dir </> "data"] ++ extra))
          { std_out = NoStream, std_err = Inherit }
        pure p
      stop p = terminateProcess p >> void (waitForProcess p)
      readyServer = await "server" $ do
        (c, _, _) <- readProcessWithExitCode "curl" ["-fs", "http://127.0.0.1:8124/api/health"] ""
        pure (show c == "ExitSuccess")
  server <- launch >>= newIORef
  flip finally (readIORef server >>= stop) $ do
    readyServer
    bracket (do
      (_, _, _, p) <- createProcess (proc chrome
        ["--headless=new", "--no-sandbox", "--disable-dev-shm-usage", "--disable-gpu"
        ,"--remote-debugging-port=0", "--remote-allow-origins=*", "--user-data-dir=" ++ dir </> "chrome", "about:blank"])
        { std_out = NoStream, std_err = NoStream }
      pure p) stop $ \_ -> do
        let portFile = dir </> "chrome" </> "DevToolsActivePort"
        await "Chrome debugging port" (doesFileExist portFile)
        port <- head . lines <$> readFile portFile
        targets <- readProcess "curl" ["-fs", "http://127.0.0.1:" ++ port ++ "/json/list"] ""
        let Just (Array ts) = decode (BL.pack targets)
            urls = [u | t <- foldr (:) [] ts, Just u <- [parseMaybe (withObject "target" (.: "webSocketDebuggerUrl")) t]]
            Just uri = parseURI (head urls)
            Just authority = uriAuthority uri
        WS.runClient "127.0.0.1" (read (drop 1 (uriPort authority))) (uriPath uri) $ \conn -> do
          serial <- newIORef (0 :: Int)
          let rpc method params = do
                i <- atomicModifyIORef' serial (\n -> (n + 1, n + 1))
                WS.sendTextData conn (encode (object ["id" .= i, "method" .= (method :: T.Text), "params" .= params]))
                let receive = do
                      raw <- WS.receiveData conn
                      v <- either fail pure (eitherDecode raw)
                      if parseMaybe (withObject "reply" (.: "id")) v == Just i
                        then pure v else receive
                r <- timeout 30000000 receive
                maybe (fail ("CDP timeout: " ++ T.unpack method)) pure r
              eval :: T.Text -> IO Value
              eval expression = do
                v <- rpc "Runtime.evaluate" (object ["expression" .= (expression :: T.Text), "returnByValue" .= True])
                case parseMaybe (withObject "reply" (\o -> o .: "result" >>= withObject "result" (\r -> r .: "result" >>= withObject "value" (.: "value")))) v of
                  Just value -> pure value
                  Nothing -> fail ("Browser expression failed: " ++ show v)
              run expression = void (eval expression)
              wait label expression = await label ((== Bool True) <$> eval expression)
              js :: T.Text -> T.Text
              js = T.pack . BL.unpack . encode
              button label = "[...document.querySelectorAll('button')].find(b => b.textContent === " <> js label <> ")"
              click label = do
                wait (T.unpack label ++ " enabled") ("Boolean(" <> button label <> " && !" <> button label <> ".disabled)")
                run (button label <> ".click(); true")
              set selector value = run ("(() => {const e=document.querySelector(" <> js selector <> "); e.focus(); e.value=" <> js value <> "; e.dispatchEvent(new Event('input',{bubbles:true})); return true;})()")
              editor = set ("textarea" :: T.Text)
              expression = set (".expr input" :: T.Text)
              route n = do
                run ("if(location.hash !== '#/w/tutorial/l/" <> T.pack (show (n :: Int)) <> "/agda') {document.querySelector('textarea').dataset.departing='true'; location.hash='#/w/tutorial/l/" <> T.pack (show n) <> "/agda';} true")
                wait "session ready" "document.querySelector('.session-status')?.textContent === 'Ready' && !document.querySelector('textarea')?.dataset.departing"
              verdict cls = wait ("verdict " ++ cls) ("Boolean(document.querySelector('.verdict." <> T.pack cls <> "'))")
          void (rpc "Page.navigate" (object ["url" .= ("http://127.0.0.1:8124/#/w/tutorial/l/1/agda" :: T.Text)]))
          wait "first Check enabled" ("Boolean(" <> button ("Check" :: T.Text) <> " && !" <> button ("Check" :: T.Text) <> ".disabled)")
          click "Check"
          verdict "unsolved"
          click "Goal"
          wait "goal shown" "document.querySelector('.goal .ty')?.textContent.includes('≡') === true"
          expression "refl"
          click "Give"
          verdict "solved"
          wait "Give edits the textarea" "document.querySelector('textarea').value.includes('refl')"
          editor "two-plus-two = zero\n"
          click "Check"
          verdict "failed"
          editor "two-plus-two = ?\n-- λ → ℕ 😀\n"
          click "Check"
          verdict "unsolved"
          -- Debounced draft restoration across route teardown.
          threadDelay 2300000
          route 2
          route 1
          wait "Unicode draft restored" "document.querySelector('textarea').value.includes('λ → ℕ 😀')"
          Right game <- loadGame games
          let tutorial = head [w | w <- lgWorlds game, wmId (lwMeta w) == "tutorial"]
          forM_ (lwLevels tutorial) $ \level -> do
            route (lmIndex (llMeta level))
            let src = llSources level M.! LangId "agda"
            editor (lsTemplate src)
            click "Check"
            verdict "unsolved"
            if lmIndex (llMeta level) == 6 then do
              expression "x"
              click "Case split"
              verdict "unsolved"
              wait "case split clauses" "document.querySelector('textarea').value.includes('suc')"
            else pure ()
            editor (lsSolution src)
            click "Check"
            verdict "solved"
          -- A real server failure must disable commands and offer Retry.
          readIORef server >>= stop
          wait "disconnect" ("Boolean(" <> button ("Retry" :: T.Text) <> ")")
          click "Retry"
          wait "failed connection offers retry" ("Boolean(" <> button ("Retry" :: T.Text) <> ")")
          launch >>= writeIORef server
          readyServer
          click "Retry"
          wait "retry opens prover" "document.querySelector('.session-status')?.textContent === 'Ready'"
          click "Check"
          verdict "solved"
          putStrLn "browser: tutorial, Unicode, goals, Give, case split, errors, drafts, navigation, failure and retry passed"

await :: String -> IO Bool -> IO ()
await label action = do
  r <- timeout 60000000 loop
  unless (r == Just ()) (fail ("Timed out waiting for " ++ label))
 where
  loop = action >>= \ok -> unless ok (threadDelay 100000 >> loop)
