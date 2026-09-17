-- | Content tree → public manifest, plus the private per-level sources.
module Refl.Content
  ( module Refl.Content.Level
  , module Refl.Content.World
  , module Refl.Content.Regions
  , buildManifest
  , SourceIndex
  , sourceIndex
  , commandIdFromName
  , commandName
  ) where

import           Data.Map               (Map)
import qualified Data.Map               as M
import           Data.Text              (Text)
import qualified Data.Text              as T

import           Refl.Content.Level
import           Refl.Content.Regions
import           Refl.Content.World
import           Refl.Markdown          (renderMarkdownOrText)
import           Refl.Protocol.Manifest
import           Refl.Protocol.Types

commandIdFromName :: Text -> Maybe CommandId
commandIdFromName = \case
  "load"      -> Just CmdLoad
  "goal"      -> Just CmdGoal
  "give"      -> Just CmdGive
  "refine"    -> Just CmdRefine
  "case"      -> Just CmdCase
  "auto"      -> Just CmdAuto
  "infer"     -> Just CmdInfer
  "normalise" -> Just CmdNormalise
  "normalize" -> Just CmdNormalise
  "solveall"  -> Just CmdSolveAll
  _           -> Nothing

commandName :: CommandId -> Text
commandName = \case
  CmdLoad -> "load"; CmdGoal -> "goal"; CmdGive -> "give"; CmdRefine -> "refine"
  CmdCase -> "case"; CmdAuto -> "auto"; CmdInfer -> "infer"; CmdNormalise -> "normalise"
  CmdSolveAll -> "solveall"

-- | The public manifest: markdown rendered, solutions dropped.
buildManifest :: [LangInfo] -> LoadedGame -> Manifest
buildManifest langs g = Manifest
  { mTitle = gmTitle (lgMeta g)
  , mIntroHtml = renderMarkdownOrText (lgIntro g)
  , mLanguages = langs
  , mWorlds = map world (lgWorlds g)
  }
 where
  docs = lgDocs g
  docHtml :: Maybe Text -> Text
  docHtml Nothing = ""
  docHtml (Just d)
    | Just md <- M.lookup (T.replace ".md" "" d) docs = renderMarkdownOrText md
    | otherwise = renderMarkdownOrText d
  world w = World
    { wId = WorldId (wmId (lwMeta w))
    , wTitle = wmTitle (lwMeta w)
    , wIntroHtml = renderMarkdownOrText (lwIntro w)
    , wDeps = map WorldId (wmDependencies (lwMeta w))
    , wLevels = map level (lwLevels w)
    }
  level l =
    let m = llMeta l
    in Level
      { lId = LevelId (lmId m)
      , lIndex = lmIndex m
      , lTitle = lmTitle m
      , lIntroHtml = renderMarkdownOrText (llIntro l)
      , lConclusionHtml = renderMarkdownOrText (llConclusion l)
      , lLearningGoals = lmLearningGoals m
      , lUnlocks = unlocks (lmUnlocks m)
      , lForbids = lmForbids m
      , lHints = [ Hint (renderMarkdownOrText (hsText h)) (hsHidden h) | h <- lmHints m ]
      , lLanguages = M.map levelLang (llSources l)
      , lSkeleton = M.null (llSources l)
      }
  levelLang s = LevelLang
    { llTemplate = lsTemplate s
    , llStatement = lsStatement s
    , llAllowImports = lsAllowImports s
    }
  unlocks u =
    [ InventoryItem ItemCommand c (docHtml (Just ("cmd-" <> c))) M.empty (commandIdFromName c)
    | c <- usCommands u ]
    ++
    [ InventoryItem ItemLemma (lsName l) (docHtml (lsDoc l)) (M.mapKeys LangId (lsNames l)) Nothing
    | l <- usLemmas u ]
    ++
    [ InventoryItem ItemSyntax (ssName s) (docHtml (ssDoc s)) M.empty Nothing
    | s <- usSyntax u ]

-- | (world, level, language) → sources, for the server and the checker.
type SourceIndex = Map (WorldId, LevelId, LangId) LevelSources

sourceIndex :: LoadedGame -> SourceIndex
sourceIndex g = M.fromList
  [ ((WorldId (wmId (lwMeta w)), LevelId (lmId (llMeta l)), lang), s)
  | w <- lgWorlds g, l <- lwLevels w, (lang, s) <- M.toList (llSources l) ]
