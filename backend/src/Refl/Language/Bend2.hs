-- | Bend2 is unreleased (github.com/bendlang/bend is a "Coming soon" README as
-- of 2026-09-16). This plugin occupies the slot so the UI can list it and so
-- nothing else in the engine has to change when it ships; see
-- @languages/bend2/README.md@ for what to implement.
module Refl.Language.Bend2 (bend2) where

import           Refl.Language
import           Refl.Protocol.Types

bend2 :: Language
bend2 = Language
  { langInfo = LangInfo (LangId "bend2") "Bend2" "bend" "agda" False
  , langCommands = []
  , langStaticRules = \_ _ -> []
  , langStart = \_ _ -> pure (Left "Bend2 is not released yet; this language will light up when it ships.")
  }
