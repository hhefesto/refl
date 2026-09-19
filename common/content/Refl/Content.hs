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
  -- one rendered doc per language that has it (docs/<lang>/<name>.md)
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
      , lIntroHtml = renderMarkdownOrText (llIntro l)
      , lConclusionHtml = renderMarkdownOrText (llConclusion l)
      , lLearningGoals = map renderMarkdownOrText (lmLearningGoals m)
      , lUnlocks = unlocks (lmUnlocks m)
      , lForbids = lmForbids m
      , lHints = hints (lmHints m)
      , lLanguages = M.mapWithKey (\lang s -> levelLang l s (M.lookup lang (llTeaching l))) (llSources l)
      , lSkeleton = M.null (llSources l)
      }
  hints hs = [ Hint (renderMarkdownOrText (hsText h)) (hsHidden h) | h <- hs ]
  -- The level file is the source of the shared prose; a language page
  -- overrides it field by field (a Lean page with only hints keeps the
  -- level intro, for instance).
  levelLang l s mt = LevelLang
    { llTemplate = lsTemplate s
    , llStatement = lsStatement s
    , llAllowImports = lsAllowImports s
    , llTitle = fromMaybe (lmTitle (llMeta l)) (mt >>= tmTitle . tMeta)
    , llIntroHtml = renderMarkdownOrText (fromMaybe (llIntro l) (nonEmpty . tIntro =<< mt))
    , llConclusionHtml = renderMarkdownOrText (fromMaybe (llConclusion l) (nonEmpty . tConclusion =<< mt))
    , llLearningGoals = map renderMarkdownOrText (fromMaybe (lmLearningGoals (llMeta l)) (mt >>= tmGoals . tMeta))
    , llHints = hints (fromMaybe (lmHints (llMeta l)) (mt >>= tmHints . tMeta))
    , llExampleCode = maybe "" (\e -> lsPrefix e <> lsSolution e) (mt >>= tExample)
    , llExampleHtml = maybe "" renderMarkdownOrText (mt >>= tmExample . tMeta)
    }
  nonEmpty t = if T.null (T.strip t) then Nothing else Just t
  unlocks u =
    [ InventoryItem ItemCommand c (docHtml (Just ("cmd-" <> c))) M.empty (commandIdFromName c)
    | c <- usCommands u ]
    ++
    [ InventoryItem ItemLemma (lsName l) (docHtml (lsDoc l)) (M.mapKeys LangId (lsNames l)) Nothing
    | l <- usLemmas u ]
    ++
    [ InventoryItem ItemSyntax (ssName s) (docHtml (ssDoc s)) (M.mapKeys LangId (ssNames s)) Nothing
    | s <- usSyntax u ]

-- | Authoring laws for the lesson a language actually shows (page fields
-- over the level file): its prose may not mention commands that prover does
-- not offer, and a worked example must be a different problem from the
-- exercise.
teachingProblems :: [LangInfo] -> LoadedGame -> [Text]
teachingProblems langs g = concat
  [ checkLang l lang s (M.lookup lang (llTeaching l))
  | w <- lgWorlds g, l <- lwLevels w, (lang, s) <- M.toList (llSources l) ]
 where
  commandsOf lang = concat [ liCommands li | li <- langs, liId li == lang ]
  checkLang l lang s mt =
    let
        override f g = fromMaybe (g l) (mt >>= f)
        prose = T.unlines $
          [ override (nonEmptyT . tIntro) llIntro
          , override (nonEmptyT . tConclusion) llConclusion
          , maybe "" id (mt >>= tmExample . tMeta) ]
          ++ override (tmGoals . tMeta) (lmLearningGoals . llMeta)
          ++ map hsText (override (tmHints . tMeta) (lmHints . llMeta))
        nonEmptyT t = if T.null (T.strip t) then Nothing else Just t
        commandRefs = [(CmdGive, "Give", "C-c C-SPC"), (CmdRefine, "Refine", "C-c C-r")
          , (CmdCase, "Case split", "C-c C-c"), (CmdAuto, "Auto", "C-c C-a")
          , (CmdInfer, "Infer", "C-c C-d"), (CmdNormalise, "Normalise", "C-c C-n")]
        prefix = T.pack (llPath l) <> " [" <> unLangId lang <> "]: "
    in [ prefix <> "unsupported command reference: " <> label
       | (cmd, label, shortcut) <- commandRefs
       , cmd `notElem` commandsOf lang
       , any (`T.isInfixOf` prose) ["**" <> label <> "**", shortcut] ]
       ++ [ prefix <> "worked example repeats the exercise statement"
          | Just e <- [mt >>= tExample], T.strip (lsStatement s) == T.strip (lsStatement e) ]

-- | (world, level, language) → sources, for the server and the checker.
type SourceIndex = Map (WorldId, LevelId, LangId) LevelSources

sourceIndex :: LoadedGame -> SourceIndex
sourceIndex g = M.fromList
  [ ((WorldId (wmId (lwMeta w)), LevelId (lmId (llMeta l)), lang), s)
  | w <- lgWorlds g, l <- lwLevels w, (lang, s) <- M.toList (llSources l) ]
