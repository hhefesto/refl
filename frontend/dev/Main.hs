-- | Native dev runner: serves the reflex app over jsaddle-warp on :3003 so the
-- UI can be iterated without the JS cross-compile. Point it at a running
-- backend with REFL_BACKEND=http://127.0.0.1:8090 (the backend must be
-- started with --dev for CORS).
module Main where

import qualified Language.Javascript.JSaddle.Warp as JW
import           Reflex.Dom.Core                  (mainWidgetWithHead)

import           App                              (bodyW, headW)

main :: IO ()
main = do
  putStrLn "frontend-dev (jsaddle-warp) on http://localhost:3003"
  JW.run 3003 $ mainWidgetWithHead headW bodyW
