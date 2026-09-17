-- | All languages, in display order. Adding one is a one-line change here.
module Refl.Language.Registry
  ( languages
  , lookupLanguage
  , languageInfos
  ) where

import           Data.List            (find)

import           Refl.Language
import           Refl.Language.Agda   (agda)
import           Refl.Language.Bend2  (bend2)
import           Refl.Language.Lean   (lean)
import           Refl.Protocol.Types

languages :: [Language]
languages = [agda, lean, bend2]

lookupLanguage :: LangId -> Maybe Language
lookupLanguage l = find ((== l) . liId . langInfo) languages

languageInfos :: [LangInfo]
languageInfos = map langInfo languages
