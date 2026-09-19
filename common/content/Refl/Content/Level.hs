-- | One level: its Markdown page (front matter + intro + conclusion) and one
-- source file per language.
module Refl.Content.Level
  ( LevelMeta (..)
  , UnlockSpec (..)
  , LemmaSpec (..)
  , SyntaxSpec (..)
  , HintSpec (..)
  , LevelSources (..)
  , LoadedLevel (..)
  , Teaching (..)
  , TeachingMeta (..)
  , loadLevel
  , languageComment
  , languageExt
  , knownLanguages
  ) where

import           Data.Aeson             (FromJSON (..), withObject, (.!=), (.:), (.:?))
import qualified Data.Aeson.Key         as K
import           Data.Map               (Map)
import qualified Data.Map               as M
import           Data.Maybe             (fromMaybe)
import           Data.Text              (Text)
import qualified Data.Text              as T
import           System.Directory       (doesFileExist)
import           System.FilePath        ((<.>), (</>))

import           Refl.Content.Frontmatter
import           Refl.Content.Regions
import           Refl.Protocol.Types

-- | Front matter of @levels/NN-<id>.md@.
data LevelMeta = LevelMeta
  { lmId            :: Text
  , lmIndex         :: Int
  , lmTitle         :: Text
  , lmLearningGoals :: [Text]
  , lmUnlocks       :: UnlockSpec
  , lmForbids       :: [Text]
  , lmAllowImports  :: Bool
  , lmHints         :: [HintSpec]
  } deriving (Eq, Show)

instance FromJSON LevelMeta where
  parseJSON = withObject "level" $ \o ->
    LevelMeta <$> o .: "id" <*> o .: "index" <*> o .: "title"
              <*> o .:? "learning_goals" .!= []
              <*> o .:? "unlocks" .!= UnlockSpec [] [] []
              <*> o .:? "forbids" .!= []
              <*> o .:? "allow_imports" .!= False
              <*> o .:? "hints" .!= []

data UnlockSpec = UnlockSpec
  { usCommands :: [Text]        -- ^ names of 'CommandId's: load goal give refine case auto infer normalise solveall
  , usLemmas   :: [LemmaSpec]
  , usSyntax   :: [SyntaxSpec]
  } deriving (Eq, Show)

instance FromJSON UnlockSpec where
  parseJSON = withObject "unlocks" $ \o ->
    UnlockSpec <$> o .:? "commands" .!= [] <*> o .:? "lemmas" .!= [] <*> o .:? "syntax" .!= []

-- | A lemma unlock: the game-wide name, its spelling per language, and a doc file.
data LemmaSpec = LemmaSpec
  { lsName  :: Text
  , lsNames :: Map Text Text   -- ^ language id → identifier
  , lsDoc   :: Maybe Text      -- ^ path relative to games/<game>/docs, (no inline markdown: an item without a doc shows a placeholder)
  } deriving (Eq, Show)

instance FromJSON LemmaSpec where
  parseJSON = withObject "lemma" $ \o -> do
    name <- o .: "name"
    doc  <- o .:? "doc"
    names <- M.fromList . concat <$> mapM (\l -> maybe [] (\v -> [(l, v)]) <$> o .:? K.fromText l) knownLanguages
    pure (LemmaSpec name names doc)

data SyntaxSpec = SyntaxSpec
  { ssName :: Text
  , ssDoc  :: Maybe Text
  , ssNames :: Map Text Text
  } deriving (Eq, Show)

instance FromJSON SyntaxSpec where
  parseJSON = withObject "syntax" $ \o -> do
    name <- o .: "name"
    doc <- o .:? "doc"
    names <- M.fromList . concat <$> mapM (\l -> maybe [] (\v -> [(l, v)]) <$> o .:? K.fromText l) knownLanguages
    pure (SyntaxSpec name doc names)

data HintSpec = HintSpec
  { hsText   :: Text
  , hsHidden :: Bool
  } deriving (Eq, Show)

instance FromJSON HintSpec where
  parseJSON = withObject "hint" $ \o -> HintSpec <$> o .: "text" <*> o .:? "hidden" .!= False

-- | What the server keeps per level and language: fixed prefix (prelude +
-- statement), the template, the model solution, and a language-supplied
-- suffix (e.g. Lean's @#print axioms@).
data LevelSources = LevelSources
  { lsLang         :: LangId
  , lsWorld        :: WorldId
  , lsLevel        :: LevelId
  , lsModuleName   :: Text     -- ^ Agda: from the prelude's @module@ line
  , lsPrefix       :: Text
  , lsStatement    :: Text     -- ^ display copy of the statement region
  , lsTemplate     :: Text
  , lsSolution     :: Text
  , lsForbidsNames :: [Text]
  , lsAllowImports :: Bool
  , lsOptions      :: [Text]   -- ^ world-level compiler options (informational)
  } deriving (Eq, Show)

data LoadedLevel = LoadedLevel
  { llMeta       :: LevelMeta
  , llIntro      :: Text                     -- ^ markdown
  , llConclusion :: Text                     -- ^ markdown
  , llSources    :: Map LangId LevelSources  -- ^ one per language file present
  , llPath       :: FilePath                 -- ^ the .md path, for messages
  , llTeaching   :: Map LangId Teaching
  } deriving (Eq, Show)

-- | A playable language has its own teaching and independently checked example.
-- No translation fallback: missing pages are authoring errors.
-- | The optional per-language lesson page @levels/NN-id/<lang>.md@: every
-- field overrides the level's own when present. @example_explanation@ goes
-- with the sibling @<lang>-example.<ext>@, a similar problem worked out.
data TeachingMeta = TeachingMeta
  { tmTitle :: Maybe Text
  , tmGoals :: Maybe [Text]
  , tmHints :: Maybe [HintSpec]
  , tmExample :: Maybe Text
  } deriving (Eq, Show)

instance FromJSON TeachingMeta where
  parseJSON = withObject "teaching" $ \o ->
    TeachingMeta <$> o .:? "title" <*> o .:? "learning_goals"
                 <*> o .:? "hints" <*> o .:? "example_explanation"

data Teaching = Teaching
  { tMeta :: TeachingMeta
  , tIntro :: Text              -- ^ empty: use the level's
  , tConclusion :: Text         -- ^ empty: use the level's
  , tExample :: Maybe LevelSources
  } deriving (Eq, Show)

knownLanguages :: [Text]
knownLanguages = ["agda", "lean", "bend2"]

languageExt :: LangId -> Text
languageExt (LangId l) = case l of
  "agda"  -> "agda"
  "lean"  -> "lean"
  "bend2" -> "bend"
  other   -> other

languageComment :: LangId -> Text
languageComment (LangId l) = case l of
  "bend2" -> "#"
  _       -> "--"

-- | @loadLevel worldId worldOptions mdPath@ reads the page and every sibling
-- source file @<base>.<ext>@ for the known languages.
loadLevel :: WorldId -> Map Text [Text] -> FilePath -> IO (Either Text LoadedLevel)
loadLevel wid worldOptions mdPath = do
  doc <- readFileUtf8 mdPath
  case parseFrontmatter doc of
    Left err -> pure (Left (T.pack mdPath <> ": " <> err))
    Right (meta, body) -> do
      let (intro, conclusion) = splitConclusion body
          base = take (length mdPath - 3) mdPath
      srcs <- mapM (loadSource meta base) knownLanguages
      pages <- mapM (\(lang, result) -> case result of
        Right (Just s) -> fmap (fmap (fmap (\t -> (LangId lang, t)))) (loadTeaching base lang s)
        _ -> pure (Right Nothing)) (zip knownLanguages srcs)
      case (,) <$> sequence srcs <*> sequence pages of
        Left err -> pure (Left (T.pack mdPath <> ": " <> err))
        Right (ms, ts) -> pure $ Right LoadedLevel
          { llMeta = meta
          , llIntro = intro
          , llConclusion = conclusion
          , llSources = M.fromList [ (LangId l, s) | (l, Just s) <- zip knownLanguages ms ]
          , llPath = mdPath
          , llTeaching = M.fromList [t | Just t <- ts]
          }
 where
  -- Neither file is required: the level file is the source and a page only
  -- overrides fields. A page without an example may not explain one; an
  -- example must come with its explanation.
  loadTeaching base lang src = do
    let page = base </> T.unpack lang <.> "md"
        example = base </> T.unpack lang <> "-example" <.> T.unpack (languageExt (lsLang src))
    exists <- doesFileExist page
    exampleExists <- doesFileExist example
    if not exists && not exampleExists then pure (Right Nothing) else do
      doc <- if exists then readFileUtf8 page else pure ""
      code <- if exampleExists then Just <$> readFileUtf8 example else pure Nothing
      pure $ do
        (meta, body) <- if exists then parseFrontmatter doc else Right (TeachingMeta Nothing Nothing Nothing Nothing, "")
        ex <- case code of
          Nothing -> Right Nothing
          Just c -> do
            r <- parseRegions (languageComment (lsLang src)) c
            Right $ Just src
              { lsModuleName = fromMaybe "Example" (moduleNameOf (rPrelude r))
              , lsPrefix = rPrelude r <> rStatement r
              , lsStatement = rStatement r
              , lsTemplate = rTemplate r
              , lsSolution = rSolution r
              }
        let (intro, conclusion) = splitConclusion body
            explained = maybe False (not . T.null . T.strip) (tmExample meta)
        case (ex, explained) of
          (Just _, False) -> Left ("worked example without example_explanation: " <> T.pack page)
          (Nothing, True) -> Left ("example_explanation without a worked example: " <> T.pack example)
          _ -> Right (Just (Teaching meta (T.strip intro) (T.strip conclusion) ex))
  splitConclusion body =
    case T.breakOn "<!-- @conclusion -->" body of
      (intro, rest) | T.null rest -> (intro, "")
                    | otherwise   -> (intro, T.drop (T.length "<!-- @conclusion -->") rest)
  loadSource meta base lang = do
    let lid = LangId lang
        path = base <.> T.unpack (languageExt lid)
    exists <- doesFileExist path
    if not exists then pure (Right Nothing) else do
      src <- readFileUtf8 path
      pure $ case parseRegions (languageComment lid) src of
        Left err -> Left (T.pack path <> ": " <> err)
        Right r  -> Right $ Just LevelSources
          { lsLang = lid
          , lsWorld = wid
          , lsLevel = LevelId (lmId meta)
          , lsModuleName = fromMaybe "Level" (moduleNameOf (rPrelude r))
          , lsPrefix = rPrelude r <> rStatement r
          , lsStatement = rStatement r
          , lsTemplate = rTemplate r
          , lsSolution = rSolution r
          , lsForbidsNames = lmForbids meta
          , lsAllowImports = lmAllowImports meta
          , lsOptions = fromMaybe [] (M.lookup lang worldOptions)
          }
