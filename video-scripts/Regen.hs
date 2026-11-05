-- | Keeps the video scripts in step with the levels: run it with
--
-- > runghc video-scripts/Regen.hs
--
-- from the repository root. A script's Open, steps and Close are written by
-- hand and stay as they are. Its heading, its length estimate and its finished
-- proof are derived here, the proof from the level's solution, so that it is
-- the proof check-levels runs. The README's tables are derived too. A playable
-- level with no script, or a script with no level, is an error.
module Main (main) where

import           Control.Monad    (forM, unless)
import           Data.Char        (isSpace)
import           Data.List        (dropWhileEnd, intercalate, isInfixOf, isPrefixOf, isSuffixOf, sort, stripPrefix)
import           Data.Maybe       (mapMaybe)
import           System.Directory (doesDirectoryExist, doesFileExist, listDirectory)
import           System.Exit      (die)
import           System.IO

worlds :: [(FilePath, String)]
worlds = [ ("00-tutorial", "Tutorial"), ("01-addition", "Addition")
         , ("02-multiplication", "Multiplication"), ("03-logic", "Logic"), ("04-equality", "Equality") ]

rd :: FilePath -> IO String
rd p = do { h <- openFile p ReadMode; hSetEncoding h utf8; s <- hGetContents h; length s `seq` pure s }

wr :: FilePath -> String -> IO ()
wr p s = do { h <- openFile p WriteMode; hSetEncoding h utf8; hPutStr h s; hClose h }

title :: String -> Maybe String
title md = case mapMaybe (stripPrefix "title: ") (lines md) of
  (t : _) -> Just (filter (/= '"') t)
  []      -> Nothing

solution :: String -> String
solution = strip . unlines . drop 1 . dropWhile (/= "-- @solution") . lines

strip :: String -> String
strip = dropWhileEnd isSpace . dropWhile (== '\n')

-- | The words a script says, plus six seconds for each thing it does.
seconds :: String -> Int
seconds s = max 15 (15 * round (raw / 15))
 where
  said = filter (\l -> any (`isInfixOf` l) ["**Open.**", "**Say:**", "**Close.**"]) (lines s)
  steps = length (filter ("**Do:**" `isInfixOf`) (lines s))
  raw = fromIntegral (length (words (unwords said)) - length said) / 2.4 + 6 * fromIntegral steps :: Double

duration :: Int -> String
duration t | t < 60 = show t ++ " s"
           | otherwise = show (t `div` 60) ++ " min " ++ pad (show (t `mod` 60)) ++ " s"
 where pad x = replicate (2 - length x) '0' ++ x

-- | From the Statement line up to (not including) the finished proof.
middle :: String -> [String]
middle = takeWhile (/= "**Finished proof:**") . dropWhile (not . isStatement) . lines
 where isStatement l = "Statement" `isPrefixOf` l

script :: FilePath -> String -> Int -> FilePath -> IO (String, String, String)
script w name i stem = do
  let root = "games/refl/worlds/" ++ w ++ "/levels/" ++ stem
      out = "video-scripts/" ++ w ++ "/" ++ stem ++ ".md"
  ok <- doesFileExist out
  unless ok (die ("no script for " ++ out))
  md <- rd (root ++ ".md")
  ag <- rd (root ++ ".agda")
  old <- rd out
  let body = middle old
      t = maybe stem id (title md)
      d = duration (seconds (unlines body))
      proof = solution ag
  wr out (unlines
    ([ "# " ++ name ++ " " ++ show i ++ ": " ++ t, "", "About " ++ d ++ ". Agda.", "" ]
     ++ body ++ [ "**Finished proof:**", "", "```agda", proof, "```" ]))
  pure (t, w ++ "/" ++ stem ++ ".md", d)

main :: IO ()
main = do
  old <- rd "video-scripts/README.md"
  tables <- forM worlds $ \(w, name) -> do
    let dir = "games/refl/worlds/" ++ w ++ "/levels"
    stems <- sort . map (reverse . drop 3 . reverse) . filter (".md" `isSuffixOf`) <$> listDirectory dir
    have <- filter (".md" `isSuffixOf`) <$> listDirectory ("video-scripts/" ++ w)
    let extra = filter (\f -> reverse (drop 3 (reverse f)) `notElem` stems) have
    unless (null extra) (die ("scripts with no level in " ++ w ++ ": " ++ intercalate ", " extra))
    rows <- forM (zip [1 :: Int ..] stems) $ \(i, stem) -> do
      (t, path, d) <- script w name i stem
      pure ("| " ++ show i ++ " | [" ++ t ++ "](" ++ path ++ ") | " ++ d ++ " |")
    pure (unlines ([ "## " ++ name ++ " World", "", "| # | Level | Length |", "|---|---|---|" ] ++ rows))
  let intro = unlines (takeWhile (not . ("## " `isPrefixOf`)) (lines old))
  wr "video-scripts/README.md" (intro ++ intercalate "\n" tables)
