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
  , teachingProblems
  ) where

import           Data.Map               (Map)
import qualified Data.Map               as M
import           Data.Maybe             (fromMaybe)
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
  docHtml :: Maybe Text -> Map LangId Text
  docHtml Nothing = M.empty
  docHtml (Just d) = M.fromList
    [ (LangId lang, renderMarkdownOrText md)
    | lang <- knownLanguages
    , Just md <- [M.lookup (lang <> "/" <> T.replace ".md" "" d) docs] ]
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
      , lIntroHtml = if M.null (llSources l) then renderMarkdownOrText (llIntro l) else ""
      , lConclusionHtml = ""
      , lLearningGoals = []
      , lUnlocks = unlocks (lmUnlocks m)
      , lForbids = lmForbids m
      , lHints = []
      , lLanguages = M.intersectionWith levelLang (llSources l) (llTeaching l)
      , lSkeleton = M.null (llSources l)
      }
  levelLang s t = LevelLang
    { llTemplate = lsTemplate s
    , llStatement = lsStatement s
    , llAllowImports = lsAllowImports s
    , llTitle = tmTitle (tMeta t)
    , llIntroHtml = renderMarkdownOrText (tIntro t)
    , llConclusionHtml = renderMarkdownOrText (tConclusion t)
    , llLearningGoals = tmGoals (tMeta t)
    , llHints = [Hint (renderMarkdownOrText (hsText h)) (hsHidden h) | h <- tmHints (tMeta t)]
    , llExampleCode = lsPrefix (tExample t) <> lsSolution (tExample t)
    , llExampleHtml = renderMarkdownOrText (tmExample (tMeta t))
    }
  unlocks u =
    [ InventoryItem ItemCommand c (docHtml (Just ("cmd-" <> c))) M.empty (commandIdFromName c)
    | c <- usCommands u ]
    ++
    [ InventoryItem ItemLemma (lsName l) (docHtml (Just (fromMaybe (lsName l) (lsDoc l)))) (M.mapKeys LangId (lsNames l)) Nothing
    | l <- usLemmas u ]
    ++
    [ InventoryItem ItemSyntax (ssName s) (docHtml (ssDoc s)) (M.mapKeys LangId (ssNames s)) Nothing
    | s <- usSyntax u ]

-- | Authoring laws: playable versions have complete teaching, and references
-- resolve within the chosen language. A missing translation is never Agda.
teachingProblems :: LoadedGame -> [Text]
teachingProblems g = concat
  [ missingPages l ++ concat [checkPage l lang t | (lang, t) <- M.toList (llTeaching l)]
  | w <- lgWorlds g, l <- lwLevels w ]
 where
  missingPages l = [T.pack (llPath l) <> ": missing teaching page for " <> unLangId lang
                   | lang <- M.keys (llSources l), M.notMember lang (llTeaching l)]
  checkPage l lang t =
    let u = lmUnlocks (llMeta l)
        referenced = ["cmd-" <> c | c <- usCommands u, Just cmd <- [commandIdFromName c], cmd `elem` supportedCommands lang]
          ++ [fromMaybe (lsName s) (lsDoc s) | s <- usLemmas u]
          ++ [fromMaybe (ssName s) (ssDoc s) | s <- usSyntax u]
        prose = T.unlines (tIntro t : tConclusion t : tmExample (tMeta t) : tmGoals (tMeta t) ++ map hsText (tmHints (tMeta t)))
        commandRefs = [(CmdGive, "Give", "C-c C-SPC"), (CmdRefine, "Refine", "C-c C-r")
          , (CmdCase, "Case split", "C-c C-c"), (CmdAuto, "Auto", "C-c C-a")
          , (CmdInfer, "Infer", "C-c C-d"), (CmdNormalise, "Normalise", "C-c C-n")]
        prefix = T.pack (llPath l) <> " [" <> unLangId lang <> "]: "
    in [prefix <> "missing inventory translation: " <> d | d <- referenced
       , M.notMember (unLangId lang <> "/" <> T.replace ".md" "" d) (lgDocs g)]
       ++ [prefix <> "unsupported command reference: " <> label | (cmd, label, shortcut) <- commandRefs
          , cmd `notElem` supportedCommands lang
          , any (`T.isInfixOf` prose) ["**" <> label <> "**", shortcut]]
       ++ [prefix <> "worked example repeats the exercise statement"
          | Just s <- [M.lookup lang (llSources l)], T.strip (lsStatement s) == T.strip (lsStatement (tExample t))]

-- | (world, level, language) → sources, for the server and the checker.
type SourceIndex = Map (WorldId, LevelId, LangId) LevelSources

sourceIndex :: LoadedGame -> SourceIndex
sourceIndex g = M.fromList
  [ ((WorldId (wmId (lwMeta w)), LevelId (lmId (llMeta l)), lang), s)
  | w <- lgWorlds g, l <- lwLevels w, (lang, s) <- M.toList (llSources l) ]
