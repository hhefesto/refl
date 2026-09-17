-- | Browser entry point (GHC JavaScript backend): on javascript-unknown-ghcjs
-- jsaddle's JSM is IO, so mainWidgetWithHead runs directly as main.
module Main where

import           Reflex.Dom.Core (mainWidgetWithHead)

import           App             (bodyW, headW)

main :: IO ()
main = mainWidgetWithHead headW bodyW
