-- Browser acceptance tests. Chrome is driven over CDP from Haskell; there
-- is no Node/WebDriver service. DOM expressions operate the real controls.
module Main (main) where

import Control.Concurrent (threadDelay)
import Control.Exception (bracket, finally)
import Control.Monad (forM_, unless, void, when)
import Data.Aeson
import Data.Aeson.Types (parseMaybe, (.:))
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as B64
import qualified Data.Text.Encoding as TE
import Data.IORef
import qualified Data.Map as M
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Encoding as TLE
import Network.URI (parseURI, uriPath, uriAuthority, uriPort)
import qualified Network.WebSockets as WS
import System.Directory
import System.Environment (getArgs, lookupEnv)
import System.FilePath ((</>))
import System.IO (IOMode (WriteMode), hClose, openFile, openTempFile)
import System.Process
import System.Timeout (timeout)

import Refl.Content
import Refl.Protocol.Types

main :: IO ()
main = do
  chrome : site : games : extra <- getArgs
  skipLean <- (== Just "1") <$> lookupEnv "REFL_BROWSER_SKIP_LEAN"
  artifacts <- lookupEnv "REFL_BROWSER_ARTIFACTS"
  tmp <- getTemporaryDirectory
  (dir, h) <- openTempFile tmp "refl-browser"
  hClose h
  removeFile dir
  createDirectory dir
  let launch = do
        -- The server's output goes to ours: a closed stdout would kill it on
        -- its first banner line, and the log is the only diagnostic in CI.
        (_, _, _, p) <- createProcess (proc site (["--port", "8124", "--data-dir", dir </> "data"] ++ extra))
          { std_out = Inherit, std_err = Inherit }
        pure p
      stop p = terminateProcess p >> void (waitForProcess p)
      readyServer = await "server" $ do
        (c, _, _) <- readProcessWithExitCode "curl" ["-fs", "http://127.0.0.1:8124/api/health"] ""
        pure (show c == "ExitSuccess")
  server <- launch >>= newIORef
  flip finally (readIORef server >>= stop) $ do
    readyServer
    bracket (do
      devNull <- openFile "/dev/null" WriteMode
      (_, _, _, p) <- createProcess (proc chrome
        ["--headless=new", "--no-sandbox", "--disable-dev-shm-usage", "--disable-gpu"
        ,"--remote-debugging-port=0", "--remote-allow-origins=*", "--user-data-dir=" ++ dir </> "chrome", "about:blank"])
        { std_out = UseHandle devNull, std_err = Inherit }   -- Chrome's stderr is the only clue when it dies in a sandbox
      pure p) stop $ \_ -> do
        let portFile = dir </> "chrome" </> "DevToolsActivePort"
        await "Chrome debugging port" (doesFileExist portFile)
        port <- head . lines <$> readFile portFile
        targets <- readProcess "curl" ["-fs", "http://127.0.0.1:" ++ port ++ "/json/list"] ""
        let Just (Array ts) = decode (BL.pack targets)
            -- only the page target: DevTools also lists workers and iframes
            urls = [ u | t <- foldr (:) [] ts
                       , Just ("page" :: T.Text, u) <- [parseMaybe (withObject "target" (\o -> (,) <$> o .: "type" <*> o .: "webSocketDebuggerUrl")) t] ]
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
                      when (parseMaybe (withObject "event" (.: "method")) v `elem` map Just (["Runtime.exceptionThrown", "Runtime.consoleAPICalled", "Log.entryAdded"] :: [T.Text])) $
                        putStrLn ("browser exception: " ++ show v)
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
              -- A synthetic DOM event followed by the next command inside one
              -- DevTools round trip outruns the app's event processing (no
              -- human is that fast): give it a macrotask before continuing.
              settle = void (rpc "Runtime.evaluate"
                (object ["expression" .= ("new Promise(r => setTimeout(r, 150))" :: T.Text), "awaitPromise" .= True]))
              wait label expression = do
                lastV <- newIORef Null
                await' label (do v <- readIORef lastV
                                 snap <- eval "[document.querySelector('.session-status')?.textContent, document.querySelector('.verdict')?.textContent, [...document.querySelectorAll('.diag')].map(d => d.textContent).join(' / '), document.querySelector('.expr input')?.value, document.querySelector('textarea')?.value, 'hash=' + location.hash, 'select=' + document.querySelector('#language')?.value, 'theme=' + document.documentElement.dataset.theme, 'stored=' + (() => { try { return localStorage.getItem('refl-theme'); } catch (e) { return 'ERR'; } })(), document.querySelector('#theme-toggle')?.outerHTML].join(' || ')"
                                 body <- eval "document.body.innerText.slice(0,1200)"
                                 pure (show v ++ "; page: " ++ show snap ++ "; body: " ++ show body)) $ do
                  v <- eval expression
                  writeIORef lastV v
                  pure (v == Bool True)
              js :: T.Text -> T.Text
              js = TL.toStrict . TLE.decodeUtf8 . encode   -- not BL.unpack: that would read UTF-8 bytes as Latin-1
              button label = "[...document.querySelectorAll('button')].find(b => b.textContent === " <> js label <> ")"
              click label = do
                wait (T.unpack label ++ " enabled") ("Boolean(" <> button label <> " && !" <> button label <> ".disabled)")
                run (button label <> ".click(); true")
                settle
              set selector value = do
                run ("(() => {const e=document.querySelector(" <> js selector <> "); e.focus(); e.value=" <> js value <> "; e.dispatchEvent(new Event('input',{bubbles:true})); return true;})()")
                settle
              editor = set ("textarea" :: T.Text)
              expression = set (".expr input" :: T.Text)
              ready = wait "session ready" "document.querySelector('.session-status')?.textContent === 'Ready' && !document.querySelector('textarea')?.dataset.departing"
              routeLang lang n = do
                let hash = "#/w/tutorial/l/" <> T.pack (show (n :: Int)) <> "/" <> lang
                run ("if(location.hash !== " <> js hash <> ") {const e=document.querySelector('textarea'); if(e) e.dataset.departing='true'; location.hash=" <> js hash <> ";} true")
                wait "language and editor agree" ("document.querySelector('#language')?.value === " <> js lang <> " && Boolean(document.querySelector('textarea')) && !document.querySelector('textarea').dataset.departing")
                unless (skipLean && lang == "lean") ready
              route = routeLang "agda"
              choose lang = do
                run ("(() => { const s=document.querySelector('#language'); s.value=" <> js lang <> "; s.dispatchEvent(new Event('change',{bubbles:true})); })(); true")
                wait "header navigates" ("location.hash.endsWith('/" <> lang <> "') && document.querySelector('.pill.on')?.textContent === " <> js lang)
                unless (skipLean && lang == "lean") ready
              tab lang = do
                run ("[...document.querySelectorAll('.nav-row a.pill')].find(a => a.textContent === " <> js lang <> ").click(); true")
                wait "tab synchronizes header" ("document.querySelector('#language')?.value === " <> js lang <> " && document.querySelector('.pill.on')?.textContent === " <> js lang)
                unless (skipLean && lang == "lean") ready
              theme name = wait ("theme " ++ T.unpack name) ("document.documentElement.dataset.theme === " <> js name)
              contrast = do
                result <- eval contrastCheck
                unless (result == Array mempty) (fail ("Insufficient theme contrast: " ++ show result))
              snapshot name = forM_ artifacts $ \out -> do
                createDirectoryIfMissing True out
                reply <- rpc "Page.captureScreenshot" (object ["format" .= ("png" :: T.Text), "captureBeyondViewport" .= True])
                let Just bytes = parseMaybe (withObject "reply" (\o -> o .: "result" >>= withObject "result" (.: "data"))) reply :: Maybe T.Text
                raw <- either fail pure (B64.decode (TE.encodeUtf8 bytes))
                BS.writeFile (out </> name ++ ".png") raw
              -- a fresh document: mark the old one and wait until the mark is gone
              reload = do
                run "window.__reflOld = true; true"
                void (rpc "Page.reload" (object []))
                await "new document after reload" ((== Bool True) <$> eval "typeof window.__reflOld === 'undefined' && document.readyState === 'complete'")
                ready
              -- reveal one more hidden hint (revealed ones carry .revealed)
              hint = do
                before <- eval "document.querySelectorAll('.hints .hint.revealed').length"
                run "[...document.querySelectorAll('.hints button')][0].click(); true"
                wait "hint revealed" ("document.querySelectorAll('.hints .hint.revealed').length === " <> T.pack (show (asInt before + 1)))
              asInt v = case v of Number n -> (round n :: Int); _ -> 0
              verdict cls = wait ("verdict " ++ cls) ("Boolean(document.querySelector('.verdict." <> T.pack cls <> "'))")
          void (rpc "Runtime.enable" (object []))
          -- Page.addScriptToEvaluateOnNewDocument is honoured only with Page events enabled
          void (rpc "Page.enable" (object []))
          void (rpc "Page.navigate" (object ["url" .= ("http://127.0.0.1:8124/#/w/tutorial/l/1/agda" :: T.Text)]))
          wait "first Check enabled" ("Boolean(" <> button ("Check" :: T.Text) <> " && !" <> button ("Check" :: T.Text) <> ".disabled)")
          theme "dark"
          contrast
          wait "default dark colors" "getComputedStyle(document.body).backgroundColor === 'rgb(21, 25, 31)'"
          wait "example collapsed" "document.querySelector('.worked-example')?.open === false"
          click "Check"
          verdict "unsolved"
          hint
          editor "two-plus-two = ?\n-- retained help\n"
          wait "edits retain hints" "document.querySelectorAll('.hints .hint.revealed').length === 1"
          run "document.querySelector('.worked-example summary').click(); true"
          wait "example source is a different problem" "document.querySelector('.worked-example code').textContent.includes('3 + 1') && !document.querySelector('.worked-example code').textContent.includes('two-plus-two')"
          snapshot "dark-help"
          click "Theme: Dark"
          theme "light"
          contrast
          snapshot "light-help"
          wait "light colors" "getComputedStyle(document.body).backgroundColor === 'rgb(251, 250, 247)'"
          reload
          theme "light"
          click "Theme: Light"
          theme "dark"
          reload
          theme "dark"
          run "localStorage.setItem('refl-theme','invalid'); true"
          reload
          theme "dark"
          -- Storage can be unavailable even in an otherwise functional browser.
          blocked <- rpc "Page.addScriptToEvaluateOnNewDocument" (object ["source" .= ("Object.defineProperty(window, 'localStorage', {get() {throw new Error('storage unavailable')}});" :: T.Text)])
          reload
          theme "dark"
          click "Theme: Dark"
          theme "light"
          let Just blockedId = parseMaybe (withObject "reply" (\o -> o .: "result" >>= withObject "result" (.: "identifier"))) blocked :: Maybe T.Text
          void (rpc "Page.removeScriptToEvaluateOnNewDocument" (object ["identifier" .= blockedId]))
          reload
          theme "dark"
          click "Check"
          verdict "unsolved"
          click "Goal"
          wait "goal shown" "document.querySelector('.goal .ty')?.textContent.includes('≡') === true"
          expression "refl"
          click "Give"
          verdict "solved"
          snapshot "dark-solved"
          wait "Give edits the textarea" "document.querySelector('textarea').value.includes('refl')"
          editor "two-plus-two = zero\n"
          click "Check"
          verdict "failed"
          snapshot "dark-error"
          editor "two-plus-two = ?\n-- λ → ℕ 😀\n"
          click "Check"
          verdict "unsolved"
          -- Debounced draft restoration across route teardown.
          threadDelay 2300000
          route 2
          route 1
          wait "Unicode draft restored" "document.querySelector('textarea').value.includes('λ → ℕ 😀')"
          choose "lean"
          wait "Lean instructions and commands" "document.querySelector('.col-left').textContent.includes('rfl') && !document.querySelector('.expr') && [...document.querySelectorAll('.commands button')].map(b => b.textContent).join(',') === 'Check,Goal'"
          wait "language change resets help" "document.querySelectorAll('.hints .hint.revealed').length === 0 && !document.querySelector('.worked-example').open"
          unless skipLean $ do
            click "Check"
            verdict "unsolved"
            hint
            reload
            wait "Lean deep link synchronizes header" "document.querySelector('#language')?.value === 'lean' && document.querySelector('.col-left')?.textContent.includes('rfl') === true"
          unless skipLean $ do
            editor "  sorry\n  -- Lean draft\n"
            click "Check"
            verdict "unsolved"
            snapshot "lean-goal"
            run "(() => { const t=document.querySelector('textarea'); t.focus(); t.setSelectionRange(2,2); t.dispatchEvent(new Event('keyup',{bubbles:true})); })(); true"
            settle
            click "Goal"
            wait "Lean goal shown" "Boolean(document.querySelector('.goal .ty'))"
            editor "  rfl\n  -- Lean draft\n"
            click "Check"
            verdict "solved"
            threadDelay 2300000
          tab "bend2"
          wait "Bend instructions and commands" "document.querySelector('.col-left').textContent.includes('{==}') && document.querySelector('.expr input').placeholder.includes('Bend') && [...document.querySelectorAll('.commands button')].map(b => b.textContent).join(',') === 'Check,Goal,Give'"
          click "Check"
          verdict "unsolved"
          click "Goal"
          wait "Bend goal" "document.querySelector('.goal .ty')?.textContent.includes('Nat') === true"
          snapshot "bend-goal"
          expression "{==}"
          click "Give"
          verdict "solved"
          editor "def two_plus_two():\n  {==}\n# Bend draft\n"
          click "Check"
          verdict "solved"
          threadDelay 2300000
          run "history.back(); true"
          wait "back restores Lean selector" "document.querySelector('#language')?.value === 'lean' && document.querySelector('.pill.on')?.textContent === 'lean'"
          unless skipLean $ wait "Lean draft isolated" "document.querySelector('textarea')?.value.includes('Lean draft') === true && !document.querySelector('textarea').value.includes('Bend draft')"
          run "history.forward(); true"
          wait "forward restores Bend selector" "document.querySelector('#language')?.value === 'bend2' && document.querySelector('textarea')?.value.includes('Bend draft') === true"
          tab "agda"
          wait "Agda draft isolated" "document.querySelector('textarea').value.includes('λ → ℕ 😀') && !document.querySelector('textarea').value.includes('Bend draft')"
          -- An unavailable translation must never mount another language's editor.
          run "location.hash='#/w/addition/l/1/lean'; true"
          wait "unavailable language" "Boolean(document.querySelector('.unavailable')) && !document.querySelector('textarea') && document.querySelector('#language').value === 'lean'"
          routeLang "bend2" 1
          run "location.hash='#/inventory'; true"
          wait "Bend inventory" "document.querySelector('.inventory')?.textContent.includes('{==}') === true && !document.querySelector('.inventory').textContent.includes('Refine')"
          run "document.querySelectorAll('.inventory details').forEach(d => d.open=true); true"
          snapshot "dark-inventory"
          run "(() => { const s=document.querySelector('#language'); s.value='lean'; s.dispatchEvent(new Event('change',{bubbles:true})); })(); true"
          -- the app must have taken the selection before the next navigation,
          -- or it will follow the selector instead of the hash
          wait "inventory follows the selector" "!document.querySelector('.inventory').textContent.includes('{==}')"
          unless skipLean $ wait "Lean inventory" "document.querySelector('.inventory')?.textContent.includes('rfl') === true"
          route 1
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
          -- The pinned Lean server needs host /etc/localtime; CI's sandbox
          -- explicitly skips these sessions, and the host run exercises them.
          forM_ (if skipLean then ["bend2"] else ["lean", "bend2"]) $ \lang ->
            forM_ (lwLevels tutorial) $ \level -> do
              routeLang lang (lmIndex (llMeta level))
              let src = llSources level M.! LangId lang
              editor (lsTemplate src)
              click "Check"
              verdict "unsolved"
              editor (lsSolution src)
              click "Check"
              verdict "solved"
          route 8
          run "location.hash='#/'; true"
          wait "world map" "Boolean(document.querySelector('.map svg'))"
          snapshot "dark-map"
          click "Theme: Dark"
          contrast
          snapshot "light-map"
          click "Theme: Light"
          route 8
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
          putStrLn ("browser: language routes, help, inventory, isolated drafts, themes, prover flows, failure and retry passed" ++ if skipLean then " (Lean prover sessions skipped in sandbox)" else " (all three provers)")

-- WCAG text contrast for semantic surfaces, diagnostics and syntax colors.
-- The probe uses computed browser colors, so unresolved CSS variables fail too.
contrastCheck :: T.Text
contrastCheck = T.unlines
  [ "(() => {"
  , "const probe=document.createElement('span'); document.body.append(probe);"
  , "const rgb=v => {probe.style.color='var('+v+')'; return getComputedStyle(probe).color.match(/[0-9.]+/g).slice(0,3).map(Number);};"
  , "const lum=v => rgb(v).map(x=>{x/=255; return x<=.04045 ? x/12.92 : ((x+.055)/1.055)**2.4;}).reduce((s,x,i)=>s+x*[.2126,.7152,.0722][i],0);"
  , "const pairs=['--bg','--card','--code','--hole','--selection','--active'].flatMap(bg=>[['--ink',bg]]).concat(['--keyword','--type','--function','--literal','--field','--muted'].flatMap(fg=>[[''+fg,'--card'],[fg,'--code']]),[['--ok','--success-bg'],['--warn','--warning-bg'],['--err','--error-bg'],['--accent','--bg'],['--accent-ink','--accent']]);"
  , "const failed=pairs.map(([fg,bg])=>{const a=lum(fg),b=lum(bg);return [fg,bg,(Math.max(a,b)+.05)/(Math.min(a,b)+.05)];}).filter(x=>x[2]<4.5); probe.remove(); return failed;"
  , "})()" ]

await :: String -> IO Bool -> IO ()
await label = await' label (pure "")

-- | Poll until the action says yes; on timeout the failure names what was
-- last observed, so a CI log is enough to see where the page got stuck.
await' :: String -> IO String -> IO Bool -> IO ()
await' label lastSeen action = do
  r <- timeout 60000000 loop
  unless (r == Just ()) $ do
    seen <- lastSeen
    fail ("Timed out waiting for " ++ label ++ (if null seen then "" else "; last observed: " ++ seen))
 where
  loop = action >>= \ok -> unless ok (threadDelay 100000 >> loop)
