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
import Data.Maybe (fromMaybe, isNothing)
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
import Refl.Protocol.Stats
import qualified Refl.Server.Analytics as Analytics
import Data.Time (UTCTime (..), fromGregorian)

main :: IO ()
main = do
  chrome : site : games : extra <- getArgs
  skipLean <- (== Just "1") <$> lookupEnv "REFL_BROWSER_SKIP_LEAN"
  artifacts <- lookupEnv "REFL_BROWSER_ARTIFACTS"
  existing <- lookupEnv "REFL_BROWSER_EXISTING_URL"
  let base = fromMaybe "http://127.0.0.1:8124" existing
  tmp <- getTemporaryDirectory
  (dir, h) <- openTempFile tmp "refl-browser"
  hClose h
  removeFile dir
  createDirectory dir
  writeFile (dir </> "dashboard-password") "browser-test\n"
  let launch = if isNothing existing then do
        -- The server's output goes to ours: a closed stdout would kill it on
        -- its first banner line, and the log is the only diagnostic in CI.
        (_, _, _, p) <- createProcess (proc site (["--port", "8124", "--data-dir", dir </> "data", "--dashboard-password-file", dir </> "dashboard-password"] ++ extra))
          { std_out = Inherit, std_err = Inherit }
        pure (Just p)
        else pure Nothing
      stop p = terminateProcess p >> void (waitForProcess p)
      stopServer = mapM_ stop
      readyServer = await "server" $ do
        (c, _, _) <- readProcessWithExitCode "curl" ["-fs", base ++ "/api/health"] ""
        pure (show c == "ExitSuccess")
  server <- launch >>= newIORef
  flip finally (readIORef server >>= stopServer) $ do
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
                let lid = ["meet-in-the-middle", "refl", "variable", "cong", "rewrite", "refine", "induction", "sym-trans", "reading-analog"] !! (n - 1 :: Int)
                    hash = "#/w/tutorial/level/" <> lid <> "/" <> lang
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
              theme name = wait ("theme " ++ T.unpack name) ("document.documentElement?.dataset.theme === " <> js name)
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
              reloadDocument = do
                run "window.__reflOld = true; true"
                void (rpc "Page.reload" (object []))
                await "new document after reload" ((== Bool True) <$> eval "typeof window.__reflOld === 'undefined' && document.readyState === 'complete'")
              reload = reloadDocument >> ready
              -- reveal one more hidden hint (revealed ones carry .revealed)
              hint = do
                before <- eval "document.querySelectorAll('.hints .hint.revealed').length"
                run "[...document.querySelectorAll('.hints button')][0].click(); true"
                wait "hint revealed" ("document.querySelectorAll('.hints .hint.revealed').length === " <> T.pack (show (asInt before + 1)))
              asInt v = case v of Number n -> (round n :: Int); _ -> 0
              verdict cls = wait ("verdict " ++ cls) ("Boolean(document.querySelector('.verdict." <> T.pack cls <> "'))")
              buildingBlocks lang = do
                wait "building blocks before completion" "document.querySelectorAll('.building-blocks details').length === 4"
                let (number, equality, proofSyntax, foreignNumber) = case lang of
                      "agda" -> ("ℕ, zero, suc", "_≡_", "begin, ≡⟨⟩, ∎", "MyNat")
                      "lean" -> ("MyNat, zero, succ", "=", "conv, change", "Zero{}")
                      _ -> ("Nat, Zero{}, Succ{…}", "{a == b : Nat}", "Refl.step, Refl.arrive, Refl.meet", "MyNat")
                wait "language-specific building blocks" ("(() => {const t=document.querySelector('.building-blocks').textContent; return "
                  <> T.intercalate " && " ["t.includes(" <> js s <> ")" | s <- [number, equality, proofSyntax]]
                  <> " && !t.includes(" <> js foreignNumber <> ");})()")
              -- Check the actual authored proofs served in hints, through the
              -- normal server restrictions, rather than a duplicate fixture.
              firstProofs lang wrong = do
                buildingBlocks lang
                count <- eval "document.querySelectorAll('.hints .hint.revealed').length"
                forM_ [asInt count .. 3] $ \_ -> hint
                wait "both sides before the meeting point" "(() => {const h=[...document.querySelectorAll('.hints .hint')]; return h.length===4 && h[0].textContent.includes('one step from the left') && h[1].textContent.includes('one step from the right') && h[2].textContent.includes('same number') && Boolean(h[3].querySelector('pre code'));})()"
                proof <- eval "document.querySelectorAll('.hints .hint')[3].querySelector('pre code').textContent"
                code <- case proof of
                  String code -> pure code
                  _ -> fail "Missing authored proof"
                editor code
                click "Check"
                verdict "solved"
                when (lang == "bend2") $ do
                  native <- eval "document.querySelector('.conclusion pre code').textContent"
                  case native of
                    String nativeCode -> do
                      editor nativeCode
                      click "Check"
                      verdict "solved"
                      editor (T.replace "Succ{Succ{2n}}" "3n" nativeCode)
                      click "Check"
                      verdict "failed"
                    _ -> fail "Missing native rewrite alternative"
                -- Wrong numbers in otherwise well-formed demonstrations must
                -- fail on either path, not merely on supplying a wrong type.
                -- Each term names the step the *player* supplies, never the one
                -- the level already shows, and occurs exactly once in the proof.
                let (leftTerm, leftBad, rightTerm, rightBad, rightHole) = case lang of
                      "agda" -> ("suc (suc 1 + 1)", "zero", "suc (suc 2)", "zero", "?")
                      "lean" -> ( "lhs\n    change succ 1 + succ 1\n    change succ (succ 2)"
                                , "lhs\n    change succ 1 + succ 1\n    change zero"
                                , "rhs\n    change succ 3\n    change succ (succ 2)"
                                , "rhs\n    change succ 3\n    change zero"
                                , "" )
                      _ -> ( "Succ{Succ{Refl.add(2n, 0n)}}", "3n"
                           , "Refl.step(Succ{Succ{2n}}, middle,", "Refl.step(3n, middle,"
                           , "Refl.step(?remaining, middle," )
                    wrongPaths = [T.replace leftTerm leftBad code, T.replace rightTerm rightBad code]
                    partial | lang == "lean" = "  conv =>\n    lhs\n    change succ 1 + succ 1\n    change succ (succ 2)\n  sorry\n"
                            | otherwise = T.replace rightTerm rightHole code
                -- A needle that no longer occurs would silently leave the proof
                -- intact and make "failed" below mean nothing.
                forM_ [leftTerm, rightTerm] $ \needle ->
                  unless (needle `T.isInfixOf` code) (fail ("Authored proof lacks " ++ T.unpack needle))
                forM_ wrongPaths $ \wrongPath -> do
                  editor wrongPath
                  click "Check"
                  verdict "failed"
                editor partial
                click "Check"
                verdict "unsolved"
                editor wrong
                click "Check"
                verdict "failed"
              -- C-c is agda-mode's chord prefix and the browser's Copy. It may
              -- only arm a chord when nothing is selected, and the second key
              -- may only be swallowed when it names a command, or the editor
              -- eats Copy, Paste and Select-all.
              clipboardKeys = do
                let press = "(k,sel) => {const t=document.querySelector('textarea');t.focus();t.setSelectionRange(sel[0],sel[1]);const e=new KeyboardEvent('keydown',{key:k,ctrlKey:true,bubbles:true,cancelable:true});t.dispatchEvent(e);return e.defaultPrevented;}"
                wait "Ctrl+C with a selection stays the clipboard's" ("(() => {const p=" <> press <> "; return p('c',[0,5])===false;})()")
                wait "Ctrl+V is never swallowed" ("(() => {const p=" <> press <> "; p('c',[0,0]); return p('v',[0,0])===false;})()")
                wait "Ctrl+X is never swallowed" ("(() => {const p=" <> press <> "; p('c',[0,0]); return p('x',[0,0])===false;})()")
                wait "C-c C-l is still a chord" ("(() => {const p=" <> press <> "; p('c',[0,0]); return p('l',[0,0])===true;})()")
              -- Dispatch input and navigate in the SAME browser task. No
              -- settle or debounce is allowed between them.
              immediateDraft lang draft = do
                run ("(() => {const e=document.querySelector('textarea'); e.value=" <> js draft
                  <> "; e.dispatchEvent(new Event('input',{bubbles:true})); e.dataset.departing='true'; location.hash="
                  <> js ("#/w/tutorial/level/refl/" <> lang) <> "; return true;})()")
                ready
                routeLang lang 1
                wait "immediate navigation preserves exact draft" ("document.querySelector('textarea').value === " <> js draft)
          void (rpc "Runtime.enable" (object []))
          -- Page.addScriptToEvaluateOnNewDocument is honoured only with Page events enabled
          void (rpc "Page.enable" (object []))
          -- A fresh document must boot without consulting the old, possibly
          -- cached /all.js URL, including after authenticating /dashboard/.
          when (isNothing existing) $ do
            void (rpc "Network.enable" (object []))
            void (rpc "Network.setBlockedURLs" (object ["urls" .= (["*/all.js"] :: [T.Text])]))
          when (isNothing existing) $ void $ rpc "Page.addScriptToEvaluateOnNewDocument" (object
            ["source" .= ("window.__reflHits=[]; const hitOpen=XMLHttpRequest.prototype.open, hitSend=XMLHttpRequest.prototype.send; XMLHttpRequest.prototype.open=function(m,u,...a){this.__hitUrl=u;return hitOpen.call(this,m,u,...a)}; XMLHttpRequest.prototype.send=function(body){if(this.__hitUrl?.includes('/api/hit')) {try{window.__reflHits.push(JSON.parse(body))}catch(_){}} return hitSend.call(this,body)};" :: T.Text)])
          void (rpc "Page.navigate" (object ["url" .= (base ++ "/#/w/tutorial/level/meet-in-the-middle/agda")]))
          wait "first Check enabled" ("Boolean(" <> button ("Check" :: T.Text) <> " && !" <> button ("Check" :: T.Text) <> ".disabled)")
          theme "dark"
          contrast
          wait "default dark colors" "getComputedStyle(document.body).backgroundColor === 'rgb(21, 25, 31)'"
          wait "example collapsed" "document.querySelector('.worked-example')?.open === false"
          -- layout: the lesson reads across the page under a centred title,
          -- and only the working aids share the row with the editor.
          wait "explanation spans the page under a centred title" "(() => {const i=document.querySelector('.level-intro'); if(!i) return false; const h=i.querySelector('h2'); const cs=getComputedStyle(i); return Boolean(h && i.querySelector('.card.prose')) && cs.gridColumnStart==='1' && cs.gridColumnEnd==='-1' && getComputedStyle(h).textAlign==='center';})()"
          wait "working aids sit beside the editor" "(() => {const l=document.querySelector('.col-left'); return Boolean(l && l.querySelector('.hints') && l.querySelector('.building-blocks') && l.querySelector('.worked-example')) && !l.querySelector('.goals');})()"
          wait "the worked example warns before it is opened" "document.querySelector('.worked-example summary .spoiler-tag')?.textContent === 'spoiler'"
          buildingBlocks "agda"
          wait "first lesson does not reveal the shortcut" "![...document.querySelectorAll('.level-intro code, .col-left code')].some(c => ['refl','rfl','{==}'].includes(c.textContent.trim()))"
          hint
          click "Check"
          verdict "unsolved"
          editor "two-plus-two-by-hand = ?\n-- retained help\n"
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
          -- The chain skeleton the level ships: every bracket empty, and a
          -- hole per endpoint asking for the term it lands on, not a proof.
          editor "two-plus-two-by-hand =\n  begin\n    2 + 2           ≡⟨⟩\n    suc 1 + suc 1   ≡⟨⟩\n    ?               ≡⟨⟩   -- walk the left endpoint down to here\n    ?               ≡⟨⟩   -- walk the right endpoint up to here\n    suc 3           ≡⟨⟩\n    4               ∎\n"
          click "Check"
          verdict "unsolved"
          click "Goal"
          wait "the holes ask for a number" "document.querySelector('.goal .ty')?.textContent.includes('ℕ') === true"
          expression "suc (suc 1 + 1)"
          click "Give"
          wait "Give edits the textarea" "document.querySelector('textarea').value.includes('suc (suc 1 + 1)')"
          expression "suc (suc 2)"
          click "Give"
          verdict "solved"
          snapshot "dark-solved"
          clipboardKeys
          verdict "solved"
          -- Reset is the client putting the level's own template back: the
          -- Gives are gone, the two holes are back, the verdict clears, and
          -- because it replaces the stored draft it survives a reload.
          let templateRestored = "(() => {const v=document.querySelector('textarea').value; return v.split('?').length === 3 && v.includes('suc 1 + suc 1') && v.includes('suc 3') && !v.includes('suc (suc 1 + 1)') && !v.includes('suc (suc 2)');})()"
          click "Reset"
          wait "Reset restores the shipped template" templateRestored
          verdict "idle"
          wait "Reset clears holes and goal" "document.querySelectorAll('.holes button').length === 0 && Boolean(document.querySelector('.goal.muted'))"
          reload
          wait "Reset replaced the stored draft" templateRestored
          -- and it is reachable again from a solved state
          click "Check"
          verdict "unsolved"
          firstProofs "agda" "two-plus-two-by-hand = zero\n"
          editor "two-plus-two-by-hand = zero\n"
          click "Check"
          verdict "failed"
          snapshot "dark-error"
          editor "two-plus-two-by-hand = ?\n-- λ → ℕ 😀\n"
          -- Navigate before the former two-second debounce could fire.
          route 2
          route 1
          wait "Unicode draft restored" "document.querySelector('textarea').value.includes('λ → ℕ 😀')"
          forM_ [1 :: Int .. 5] $ \i -> immediateDraft "agda" ("two-plus-two-by-hand = ?\n-- λ → ℕ 😀 immediate " <> T.pack (show i) <> "\n")
          choose "lean"
          wait "Lean instructions and commands" "document.querySelector('.col-left').textContent.includes('conv') && !document.querySelector('.expr') && [...document.querySelectorAll('.commands button')].map(b => b.textContent).join(',') === 'Check,Goal,Reset'"
          wait "language change resets help" "document.querySelectorAll('.hints .hint.revealed').length === 0 && !document.querySelector('.worked-example').open"
          buildingBlocks "lean"
          unless skipLean $ do
            click "Check"
            verdict "unsolved"
            hint
            reload
            wait "Lean deep link synchronizes header" "document.querySelector('#language')?.value === 'lean' && document.querySelector('.col-left')?.textContent.includes('conv') === true"
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
            firstProofs "lean" "  exact (zero : MyNat)\n"
            immediateDraft "lean" "  sorry\n  -- Lean draft\n"
          tab "bend2"
          wait "Bend instructions and commands" "document.querySelector('.col-left').textContent.includes('Refl.step') && document.querySelector('.expr input').placeholder.includes('Bend') && [...document.querySelectorAll('.commands button')].map(b => b.textContent).join(',') === 'Check,Goal,Give,Reset'"
          buildingBlocks "bend2"
          click "Check"
          verdict "unsolved"
          click "Goal"
          wait "Bend goal" "document.querySelector('.goal .ty')?.textContent.includes('Nat') === true"
          snapshot "bend-goal"
          expression "Succ{Succ{Refl.add(2n, 0n)}}"
          click "Give"
          wait "Give edits the textarea" "document.querySelector('textarea').value.includes('Succ{Succ{Refl.add(2n, 0n)}}')"
          verdict "unsolved"
          expression "Succ{Succ{2n}}"
          click "Give"
          verdict "solved"
          -- Definitional equality also permits the later shortcut here.
          editor "def two_plus_two_by_hand():\n  {==}\n# Bend draft\n"
          click "Check"
          verdict "solved"
          firstProofs "bend2" "def two_plus_two_by_hand():\n  Zero{}\n"
          immediateDraft "bend2" "def two_plus_two_by_hand():\n  {==}\n# Bend draft\n"
          -- Return to the selector-created history entry after the draft
          -- navigation stress, then exercise back/forward between languages.
          tab "lean"
          tab "bend2"
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
          -- Reflexivity is documented only in the follow-up lesson. Test its
          -- actual teaching snippet, in addition to private canonical proofs.
          forM_ (if skipLean then ["agda", "bend2"] else ["agda", "lean", "bend2"]) $ \lg -> do
            routeLang lg 2
            forM_ [1 :: Int .. 4] $ \_ -> hint
            short <- eval "document.querySelectorAll('.hints .hint')[3].querySelector('pre code').textContent"
            case short of
              String code -> editor code
              _ -> fail "Missing authored short proof"
            click "Check"
            verdict "solved"
          routeLang "bend2" 2
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
          run "location.hash='#/w/tutorial/l/2/agda'; true"
          wait "legacy bookmark opens variable, not refl" "document.querySelector('.statement')?.textContent.includes('same :') === true"
          route 1
          Right game <- loadGame games
          let tutorial = head [w | w <- lgWorlds game, wmId (lwMeta w) == "tutorial"]
          forM_ (lwLevels tutorial) $ \level -> do
            route (lmIndex (llMeta level))
            let src = llSources level M.! LangId "agda"
            editor (lsTemplate src)
            click "Check"
            verdict "unsolved"
            if lmId (llMeta level) == "induction" then do
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
          route 9
          run "location.hash='#/'; true"
          wait "world map" "Boolean(document.querySelector('.map svg'))"
          snapshot "dark-map"
          click "Theme: Dark"
          contrast
          snapshot "light-map"
          click "Theme: Light"
          -- Support: every chain in donations.json must be on the page with
          -- the address it names and a QR that actually loaded. The page is
          -- the only place the addresses are read by a human, so a card that
          -- silently disagrees with the file is the failure that matters.
          run "location.hash='#/donate'; true"
          run "window.__donations=null; fetch('/donations.json').then(r=>r.json()).then(j=>{window.__donations=j}); true"
          wait "donations.json reaches the page" "Boolean(window.__donations)"
          wait "every chain is shown with the address the file names" "(() => {const cs=window.__donations.dnChains; const cards=[...document.querySelectorAll('.chains .chain')]; if(cards.length!==cs.length||!cs.length) return false; return cs.every((c,i)=>cards[i].querySelector('h2')?.textContent===c.cnName && cards[i].querySelector('.addr code')?.textContent===c.cnAddress);})()"
          wait "every QR image loaded" "(() => {const q=[...document.querySelectorAll('.chain .qr img')]; return q.length===window.__donations.dnChains.length && q.every(i=>i.complete && i.naturalWidth>0);})()"
          wait "the chrome offers Support" "document.querySelector('header.top a.support')?.getAttribute('href') === '#/donate'"
          snapshot "donate"
          route 9
          -- A real server failure must disable commands and offer Retry.
          when (isNothing existing) $ do
            readIORef server >>= stopServer
            wait "disconnect" ("Boolean(" <> button ("Retry" :: T.Text) <> ")")
            click "Retry"
            wait "failed connection offers retry" ("Boolean(" <> button ("Retry" :: T.Text) <> ")")
            launch >>= writeIORef server
            readyServer
            click "Retry"
            wait "retry opens prover" "document.querySelector('.session-status')?.textContent === 'Ready'"
            click "Check"
            verdict "solved"
          when (isNothing existing) $ do
            wait "visible game heartbeat" "window.__reflHits.some(h=>h.hiHeartbeat===true) && window.__reflHits.some(h=>h.hiHeartbeat===false)"
            -- The real server challenges both page and aggregate requests.
            forM_ ["/dashboard/", "/dashboard/data.json"] $ \path -> do
              status <- readProcess "curl" ["-s", "-o", "/dev/null", "-w", "%{http_code}", base ++ path] ""
              unless (status == "401") (fail "dashboard did not challenge anonymous browser")
            void (rpc "Network.enable" (object []))
            void (rpc "Network.setExtraHTTPHeaders" (object ["headers" .= object ["Authorization" .= ("Basic cmVmbDpicm93c2VyLXRlc3Q=" :: T.Text)]]))
            void (rpc "Page.navigate" (object ["url" .= (base ++ "/dashboard/")]))
            wait "disabled analytics" "document.body.innerText.includes('Analytics collection is disabled.')"
            -- Controlled XHR completion lets us reverse responses without
            -- depending on server latency, and exercise actual DOM controls.
            let fixture = (Analytics.aggregate (Analytics.sanitizer [])
                  (UTCTime (fromGregorian 2026 9 20) 43200) 30 400 True False mempty [])
                  { suTotals = Totals 2 1 4 7 1 3 1
                  , suDaily = [DayPoint "2026-09-20" 2 4 7 2 3]
                  , suCountries = [Bucket "SG" "SG" 4]
                  , suLevels = [LevelStat "tutorial/refl" 3 3]
                  , suSessions = 1, suSessionsMax = 4
                  , suSessionPeak = 3, suRejected = 2 }
                fixtureJSON = TL.toStrict (TLE.decodeUtf8 (encode fixture))
                mock = T.unlines
                  [ "window.__dashMode='ready'; window.__dashPending=[];"
                  , "const fixture=" <> fixtureJSON <> ";"
                  , "const open=XMLHttpRequest.prototype.open, send=XMLHttpRequest.prototype.send;"
                  , "XMLHttpRequest.prototype.open=function(m,u,...args){this.__url=u;return open.call(this,m,u,...args)};"
                  , "XMLHttpRequest.prototype.send=function(...args){"
                  , " if(!this.__url.includes('/dashboard/data.json') && !this.__url.includes('/world-countries.json')) return send.apply(this,args);"
                  , " const x=this, d=Number(new URL(x.__url,location.href).searchParams.get('days'));"
                  , " const finish=(mode, label) => {const body={...fixture,suDays:d,suTo:label||('range-'+d),suEnabled:mode!=='disabled'};"
                  , " const text=mode==='invalid'?'broken':JSON.stringify(body);"
                  , " Object.defineProperties(x,{readyState:{value:4},status:{value:mode==='error'?503:mode==='network'?0:200},statusText:{value:''},responseText:{value:text},response:{value:text}});"
                  , " x.dispatchEvent(new Event('readystatechange')); };"
                  , " if(this.__url.includes('/world-countries.json')) {setTimeout(()=>finish('invalid'),0);return;}"
                  , " if(window.__dashMode==='manual') window.__dashPending.push(finish); else setTimeout(()=>finish(window.__dashMode),0);"
                  , "};"
                  ]
            installed <- rpc "Page.addScriptToEvaluateOnNewDocument" (object ["source" .= mock])
            let Just mockId = parseMaybe (withObject "reply" (\o -> o .: "result" >>= withObject "result" (.: "identifier"))) installed :: Maybe T.Text
            reloadDocument
            wait "dashboard ready" "document.querySelectorAll('.tile').length===6"
            wait "missing map retains country values" "document.body.innerText.includes('Country outlines are unavailable.') && document.querySelector('.geo-row').textContent.includes('Singapore')"
            wait "coverage shown" "document.querySelector('.coverage')?.textContent.includes('incomplete recorded history') === true && !document.querySelector('.tile .d')"
            run "document.querySelector('.chart details').open=true; true"
            wait "textual daily chart" "document.querySelector('.daily-values')?.textContent.includes('2026-09-20') === true && document.querySelector('.daily-values').textContent.includes('Peak active (5 min)')"
            wait "capacity tile" "[...document.querySelectorAll('.tile')].some(t=>t.textContent.includes('Prover sessions') && t.textContent.includes('of 4') && t.textContent.includes('peak 3') && t.textContent.includes('2 turned away'))"
            run "window.__dashMode='manual'; true"
            click "90 days"
            wait "90-day request queued" "window.__dashPending.length===1"
            click "a year"
            wait "year request queued" "window.__dashPending.length===2"
            run "window.__dashPending[1]('ready'); true"
            wait "year response displayed" "document.querySelector('.when')?.textContent.includes('range-365') === true"
            run "window.__dashPending[0]('ready'); true"
            settle
            wait "obsolete range ignored" "document.querySelector('.when')?.textContent.includes('range-365') === true && [...document.querySelectorAll('.ranges button')].find(b=>b.textContent==='a year').getAttribute('aria-pressed')==='true'"
            -- Also supersede a refresh of the same range.
            run "window.__dashPending=[]; true"
            click "Refresh"
            wait "first refresh" "window.__dashPending.length===1"
            click "Refresh"
            wait "second refresh" "window.__dashPending.length===2"
            run "window.__dashPending[1]('ready','newest'); true"
            wait "new refresh displayed" "document.querySelector('.when')?.textContent.includes('newest') === true"
            run "window.__dashPending[0]('ready','obsolete'); true"
            settle
            wait "obsolete refresh ignored" "document.querySelector('.when')?.textContent.includes('newest') === true"
            forM_ ["error", "network", "invalid"] $ \mode -> do
              run ("window.__dashMode=" <> js mode <> "; true")
              click "Refresh"
              wait "dashboard error" "Boolean(document.querySelector('[role=alert]'))"
              run "window.__dashMode='ready'; true"
              click "Retry"
              wait "dashboard retry" "document.querySelectorAll('.tile').length===6"
            forM_ ["dark", "light"] $ \theme -> do
              run ("localStorage.setItem('refl-theme'," <> js theme <> "); true")
              reloadDocument
              wait "dashboard stored theme" ("document.documentElement?.dataset.theme===" <> js theme <> " && document.querySelectorAll('.tile').length===6")
              contrast
              void (rpc "Emulation.setDeviceMetricsOverride" (object ["width" .= (320 :: Int), "height" .= (740 :: Int), "deviceScaleFactor" .= (1 :: Int), "mobile" .= True]))
              wait "mobile dashboard fits" "document.documentElement.scrollWidth<=window.innerWidth"
              snapshot ("dashboard-" <> T.unpack theme)
            void (rpc "Emulation.clearDeviceMetricsOverride" (object []))
            void (rpc "Page.removeScriptToEvaluateOnNewDocument" (object ["identifier" .= mockId]))
            putStrLn "browser: dashboard authentication, disabled state, coverage, reversed requests, errors/retry, missing map, themes and mobile layout passed"
          putStrLn ("browser: language routes, help, inventory, isolated drafts, themes and prover flows passed" ++ if skipLean then " (Lean prover sessions skipped in sandbox)" else " (all three provers)")
          putStrLn (if isNothing existing then "browser: failure and retry passed" else "browser: verified existing service; lifecycle checks skipped")

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
