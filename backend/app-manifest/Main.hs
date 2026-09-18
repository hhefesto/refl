-- | refl-build-manifest GAMES -o manifest.json
--
-- Loads the content tree, validates it, and writes the public manifest.
module Main (main) where

import           Control.Monad          (forM_, unless)
import           Data.Aeson             (encode)
import qualified Data.ByteString.Lazy   as BL
import qualified Data.Map               as M
import qualified Data.Set               as S
import qualified Data.Text              as T
import qualified Data.Text.IO           as TIO
import           Options.Applicative
import           System.Exit            (exitFailure)
import           System.IO              (stderr)

import           Refl.Content
import           Refl.Language.Registry (languageInfos)

data Opts = Opts { oGames :: FilePath, oOut :: FilePath }

main :: IO ()
main = do
  o <- execParser $ info
    (Opts <$> strArgument (metavar "GAMES") <*> strOption (long "output" <> short 'o' <> value "manifest.json" <> showDefault) <**> helper)
    (fullDesc <> progDesc "Compile the content tree into the public manifest")
  r <- loadGame (oGames o)
  case r of
    Left err -> TIO.hPutStrLn stderr err >> exitFailure
    Right g -> do
      let problems = validate g
      forM_ problems (TIO.hPutStrLn stderr . ("error: " <>))
      unless (null problems) exitFailure
      BL.writeFile (oOut o) (encode (buildManifest languageInfos g))
      putStrLn ("wrote " ++ oOut o ++ ": " ++ show (length (lgWorlds g)) ++ " worlds, "
                ++ show (sum (map (length . lwLevels) (lgWorlds g))) ++ " levels")

validate :: LoadedGame -> [T.Text]
validate g =
  teachingProblems languageInfos g ++ [ "duplicate world id " <> i | i <- dups (map (wmId . lwMeta) ws) ]
  ++ [ "world " <> wmId (lwMeta w) <> " depends on unknown world " <> d
     | w <- ws, d <- wmDependencies (lwMeta w), d `S.notMember` ids ]
  ++ [ "world " <> wmId (lwMeta w) <> ": duplicate level id " <> i
     | w <- ws, i <- dups (map (lmId . llMeta) (lwLevels w)) ]
  ++ [ "world " <> wmId (lwMeta w) <> ": duplicate level index " <> T.pack (show i)
     | w <- ws, i <- dups (map (lmIndex . llMeta) (lwLevels w)) ]
  ++ [ "world " <> wmId (lwMeta w) <> " level " <> lmId (llMeta l) <> ": unknown command unlock " <> c
     | w <- ws, l <- lwLevels w, c <- usCommands (lmUnlocks (llMeta l)), commandIdFromName c == Nothing ]
  ++ [ "world " <> wmId (lwMeta w) <> " level " <> lmId (llMeta l) <> ": doc not found in any docs/<lang>/: " <> d
     | w <- ws, l <- lwLevels w, sp <- usLemmas (lmUnlocks (llMeta l)), Just d <- [lsDoc sp]
     , ".md" `T.isSuffixOf` d, null [ () | lang <- knownLanguages, (lang <> "/" <> T.replace ".md" "" d) `M.member` lgDocs g ] ]
  ++ [ "world " <> wmId (lwMeta w) <> " has no levels" | w <- ws, null (lwLevels w) ]
 where
  ws = lgWorlds g
  ids = S.fromList (map (wmId . lwMeta) ws)
  dups xs = S.toList (S.fromList [ x | x <- xs, length (filter (== x) xs) > 1 ])
