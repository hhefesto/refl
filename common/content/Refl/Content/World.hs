-- | A world directory: @world.md@ plus @levels/*.md@ (with sibling sources).
module Refl.Content.World
  ( WorldMeta (..)
  , LoadedWorld (..)
  , GameMeta (..)
  , LoadedGame (..)
  , loadWorld
  , loadGame
  ) where

import           Data.Aeson               (FromJSON (..), withObject, (.!=), (.:), (.:?))
import           Data.List                (isSuffixOf, sort, sortOn)
import           Data.Map                 (Map)
import qualified Data.Map                 as M
import           Data.Text                (Text)
import qualified Data.Text                as T
import           System.Directory         (doesDirectoryExist, doesFileExist,
                                           listDirectory)
import           System.FilePath          ((</>))

import           Refl.Content.Frontmatter
import           Refl.Content.Level
import           Refl.Protocol.Types

data WorldMeta = WorldMeta
  { wmId           :: Text
  , wmTitle        :: Text
  , wmDependencies :: [Text]
  , wmOptions      :: Map Text [Text]   -- ^ language id → compiler options
  } deriving (Eq, Show)

instance FromJSON WorldMeta where
  parseJSON = withObject "world" $ \o ->
    WorldMeta <$> o .: "id" <*> o .: "title"
              <*> o .:? "dependencies" .!= []
              <*> o .:? "options" .!= M.empty

data LoadedWorld = LoadedWorld
  { lwMeta   :: WorldMeta
  , lwIntro  :: Text
  , lwLevels :: [LoadedLevel]   -- ^ sorted by index
  , lwDir    :: FilePath
  } deriving (Eq, Show)

data GameMeta = GameMeta
  { gmTitle  :: Text
  , gmWorlds :: [Text]   -- ^ world ids in display order
  } deriving (Eq, Show)

instance FromJSON GameMeta where
  parseJSON = withObject "game" $ \o -> GameMeta <$> o .: "title" <*> o .:? "worlds" .!= []

data LoadedGame = LoadedGame
  { lgMeta   :: GameMeta
  , lgIntro  :: Text
  , lgWorlds :: [LoadedWorld]   -- ^ in the order of 'gmWorlds' (then the rest, sorted)
  , lgDocs   :: Map Text Text   -- ^ docs/<name>.md → markdown
  , lgDir    :: FilePath
  } deriving (Eq, Show)

loadWorld :: FilePath -> IO (Either Text LoadedWorld)
loadWorld dir = do
  let mdPath = dir </> "world.md"
  exists <- doesFileExist mdPath
  if not exists then pure (Left (T.pack mdPath <> ": missing")) else do
    doc <- readFileUtf8 mdPath
    case parseFrontmatter doc of
      Left err -> pure (Left (T.pack mdPath <> ": " <> err))
      Right (meta, intro) -> do
        let levelsDir = dir </> "levels"
        hasLevels <- doesDirectoryExist levelsDir
        files <- if hasLevels then sort . filter (".md" `isSuffixOf`) <$> listDirectory levelsDir else pure []
        lvls <- mapM (loadLevel (WorldId (wmId meta)) (wmOptions meta) . (levelsDir </>)) files
        pure $ case sequence lvls of
          Left err -> Left err
          Right ls -> Right LoadedWorld
            { lwMeta = meta
            , lwIntro = intro
            , lwLevels = sortOn (lmIndex . llMeta) ls
            , lwDir = dir
            }

-- | Load @games/<game>/@: @game.md@, @worlds/*/@, @docs/*.md@.
loadGame :: FilePath -> IO (Either Text LoadedGame)
loadGame dir = do
  doc <- readFileUtf8 (dir </> "game.md")
  case parseFrontmatter doc of
    Left err -> pure (Left (T.pack (dir </> "game.md") <> ": " <> err))
    Right (meta, intro) -> do
      wdirs <- sort <$> listDirectory (dir </> "worlds")
      worlds <- mapM (loadWorld . ((dir </> "worlds") </>)) wdirs
      docsExist <- doesDirectoryExist (dir </> "docs")
      docFiles <- if docsExist then fmap concat $ mapM (\lang -> do
        let sub = dir </> "docs" </> T.unpack lang
        exists <- doesDirectoryExist sub
        fs <- if exists then filter (".md" `isSuffixOf`) <$> listDirectory sub else pure []
        pure [T.unpack lang </> f | f <- fs]) knownLanguages else pure []
      docs <- mapM (\f -> (,) (T.pack (take (length f - 3) f)) <$> readFileUtf8 (dir </> "docs" </> f)) docFiles
      pure $ case sequence worlds of
        Left err -> Left err
        Right ws ->
          let byId = M.fromList [ (wmId (lwMeta w), w) | w <- ws ]
              ordered = [ w | i <- gmWorlds meta, Just w <- [M.lookup i byId] ]
              rest = [ w | w <- ws, wmId (lwMeta w) `notElem` gmWorlds meta ]
          in Right LoadedGame
               { lgMeta = meta
               , lgIntro = intro
               , lgWorlds = ordered ++ rest
               , lgDocs = M.fromList docs
               , lgDir = dir
               }
