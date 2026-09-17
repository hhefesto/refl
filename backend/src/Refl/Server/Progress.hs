-- | Player progress: completed levels per language and per-level drafts, in
-- one JSON file written atomically.
module Refl.Server.Progress
  ( ProgressStore
  , openStore
  , getProgress
  , markSolved
  , saveDraft
  , draftFor
  ) where

import           Control.Concurrent.MVar
import           Control.Exception       (SomeException, try)
import           Data.Aeson              (decodeStrict, encode)
import qualified Data.ByteString         as BS
import qualified Data.ByteString.Lazy    as BL
import           Data.List               (nub)
import qualified Data.Map                as M
import           Data.Text               (Text)
import           System.Directory        (createDirectoryIfMissing,
                                          doesFileExist, renameFile)
import           System.FilePath         (takeDirectory)

import           Refl.Protocol.Types

data ProgressStore = ProgressStore
  { psPath :: FilePath
  , psVar  :: MVar Progress
  }

openStore :: FilePath -> IO ProgressStore
openStore path = do
  exists <- doesFileExist path
  p <- if not exists then pure emptyProgress else do
    r <- try (BS.readFile path)
    pure $ case r of
      Left (_ :: SomeException) -> emptyProgress
      Right bytes -> maybe emptyProgress id (decodeStrict bytes)
  ProgressStore path <$> newMVar p

getProgress :: ProgressStore -> IO Progress
getProgress = readMVar . psVar

persist :: ProgressStore -> Progress -> IO ()
persist st p = do
  createDirectoryIfMissing True (takeDirectory (psPath st))
  let tmp = psPath st ++ ".tmp"
  BL.writeFile tmp (encode p)
  renameFile tmp (psPath st)

markSolved :: ProgressStore -> LangId -> Text -> IO Progress
markSolved st lang key = modifyMVar (psVar st) $ \p -> do
  let done = nub (key : M.findWithDefault [] lang (prCompleted p))
      p' = p { prCompleted = M.insert lang done (prCompleted p) }
  persist st p'
  pure (p', p')

saveDraft :: ProgressStore -> Text -> LangId -> Text -> IO ()
saveDraft st key lang txt = modifyMVar_ (psVar st) $ \p -> do
  let p' = p { prDrafts = M.insertWith M.union key (M.singleton lang txt) (prDrafts p) }
  persist st p'
  pure p'

draftFor :: ProgressStore -> Text -> LangId -> IO (Maybe Text)
draftFor st key lang = do
  p <- readMVar (psVar st)
  pure (M.lookup key (prDrafts p) >>= M.lookup lang)
