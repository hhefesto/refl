-- | refl-gen-input-table AGDA_INPUT_EL OUT.hs
module Main (main) where

import qualified Data.Text.IO       as TIO
import           System.Environment (getArgs)
import           System.Exit        (exitFailure)
import           System.IO          (hPutStrLn, stderr)

import           Refl.InputTable

main :: IO ()
main = do
  args <- getArgs
  case args of
    [inp, out] -> do
      src <- TIO.readFile inp
      let entries = parseAgdaInputEl src
      TIO.writeFile out (renderInputModule entries)
      putStrLn ("wrote " ++ out ++ " with " ++ show (length entries) ++ " entries from agda-input.el")
    _ -> hPutStrLn stderr "usage: refl-gen-input-table agda-input.el Widgets/InputTable.hs" >> exitFailure
