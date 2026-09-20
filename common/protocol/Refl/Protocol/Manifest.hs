-- | The public game manifest: everything the browser needs to draw the world
-- map, the level pages and the inventory. Markdown is pre-rendered to HTML by
-- @refl-build-manifest@; model solutions are stripped.
module Refl.Protocol.Manifest where

import           Data.Aeson          (FromJSON, ToJSON)
import           Data.Map            (Map)
import qualified Data.Map            as M
import           Data.Text           (Text)
import           GHC.Generics        (Generic)

import           Refl.Protocol.Types

-- | The added introductory exercise does not revoke downstream access from
-- players who completed the original Tutorial. It still counts toward the
-- world's displayed completion; no progress or draft is fabricated/migrated.
worldPrerequisiteDone :: Progress -> LangId -> World -> Bool
worldPrerequisiteDone p lang w = not (null required) && all done required
 where
  required = [l | l <- wLevels w, M.member lang (lLanguages l)
                , (wId w, lId l) /= (WorldId "tutorial", LevelId "meet-in-the-middle")]
  done l = levelKey (wId w) (lId l) `elem` M.findWithDefault [] lang (prCompleted p)

data Manifest = Manifest
  { mTitle     :: Text
  , mIntroHtml :: Text
  , mLanguages :: [LangInfo]
  , mWorlds    :: [World]
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data World = World
  { wId        :: WorldId
  , wTitle     :: Text
  , wIntroHtml :: Text
  , wDeps      :: [WorldId]
  , wLevels    :: [Level]
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data Level = Level
  { lId             :: LevelId
  , lIndex          :: Int
  , lTitle          :: Text
  , lIntroHtml      :: Text
  , lConclusionHtml :: Text
  , lLearningGoals  :: [Text]
  , lUnlocks        :: [InventoryItem]
  , lForbids        :: [Text]
  , lHints          :: [Hint]
  , lLanguages      :: Map LangId LevelLang
  , lSkeleton       :: Bool   -- ^ authored but no sources yet
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data LevelLang = LevelLang
  { llTemplate     :: Text
  , llStatement    :: Text   -- ^ display only; the real one is spliced server-side
  , llAllowImports :: Bool
  , llTitle        :: Text
  , llIntroHtml    :: Text
  , llConclusionHtml :: Text
  , llLearningGoals :: [Text]
  , llHints        :: [Hint]
  , llExampleCode  :: Text
  , llExampleHtml  :: Text
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data Hint = Hint
  { hHtml   :: Text
  , hHidden :: Bool
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data ItemKind = ItemCommand | ItemLemma | ItemSyntax
  deriving stock (Eq, Ord, Show, Bounded, Enum, Generic)
  deriving anyclass (ToJSON, FromJSON)

data InventoryItem = InventoryItem
  { iiKind      :: ItemKind
  , iiName      :: Text
  , iiDocHtml   :: Map LangId Text
  , iiLangNames :: Map LangId Text   -- ^ per-language spelling of a lemma
  , iiCommand   :: Maybe CommandId   -- ^ for 'ItemCommand'
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

-- | The key under which progress and drafts are stored.
levelKey :: WorldId -> LevelId -> Text
levelKey (WorldId w) (LevelId l) = w <> "/" <> l
