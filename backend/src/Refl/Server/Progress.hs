-- | Atomic progress per anonymous identity. The shared lock serialises disk
-- transactions; no unbounded in-memory cache or legacy shared progress is used.
module Refl.Server.Progress
  ( ProgressStore, openStore, playerStore, getProgress, markSolved, saveDraft, draftFor
  ) where

import Control.Concurrent.MVar
import Control.Exception (SomeException, toException, try)
import System.IO (hPutStrLn, stderr)
import Data.Aeson (eitherDecodeStrict, encode)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL
import Data.List (nub)
import qualified Data.Map as M
import Data.Text (Text)
import System.Directory (createDirectoryIfMissing, doesFileExist, renameFile)
import System.FilePath (takeDirectory, (</>))
import Refl.Protocol.Types

-- All stores derived from one root share this lock, including separate sockets.
data ProgressStore = ProgressStore FilePath (MVar ())

openStore :: FilePath -> IO ProgressStore
openStore path = ProgressStore path <$> newMVar ()

-- The caller supplies only a validated, randomly generated identity.
playerStore :: ProgressStore -> String -> ProgressStore
playerStore (ProgressStore root lock) player =
  ProgressStore (takeDirectory root </> "players" </> player ++ ".json") lock

readProgress :: ProgressStore -> IO Progress
readProgress (ProgressStore path _) = do
  exists <- doesFileExist path
  if not exists then pure emptyProgress else do
    r <- try (BS.readFile path)
    case r >>= either (Left . toException . userError) Right . eitherDecodeStrict of
      Right p -> pure p
      Left (e :: SomeException) -> do
        -- A damaged file must not lock a player out; it is replaced on the next write.
        hPutStrLn stderr ("progress: ignoring unreadable " ++ path ++ ": " ++ show e)
        pure emptyProgress

getProgress :: ProgressStore -> IO Progress
getProgress st@(ProgressStore _ lock) = withMVar lock (const (readProgress st))

update :: ProgressStore -> (Progress -> Progress) -> IO Progress
update st@(ProgressStore path lock) f = withMVar lock $ \_ -> do
  p <- f <$> readProgress st
  createDirectoryIfMissing True (takeDirectory path)
  BL.writeFile (path ++ ".tmp") (encode p)
  renameFile (path ++ ".tmp") path
  pure p

markSolved :: ProgressStore -> LangId -> Text -> IO Progress
markSolved st lang key = update st $ \p ->
  p { prCompleted = M.insert lang (nub (key : M.findWithDefault [] lang (prCompleted p))) (prCompleted p) }

saveDraft :: ProgressStore -> Text -> LangId -> Text -> IO ()
saveDraft st key lang txt = do
  _ <- update st $ \p -> p { prDrafts = M.insertWith M.union key (M.singleton lang txt) (prDrafts p) }
  pure ()

draftFor :: ProgressStore -> Text -> LangId -> IO (Maybe Text)
draftFor st key lang = do
  p <- getProgress st
  pure (M.lookup key (prDrafts p) >>= M.lookup lang)
