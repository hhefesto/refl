-- | Content CI for the donation addresses: @refl-check-donations donations.json@.
-- A wrong address is the one bug in this repo that costs real money, so it is
-- checked from the same file the page and the QR codes are built from.
module Main (main) where

import           Data.Aeson           (eitherDecodeFileStrict)
import qualified Data.Text            as T
import           System.Environment   (getArgs)
import           System.Exit          (exitFailure)
import           System.IO            (hPutStrLn, stderr)

import           Refl.Donations       (checkDonations)
import           Refl.Protocol.Donate

main :: IO ()
main = getArgs >>= \case
  [path] -> do
    parsed <- eitherDecodeFileStrict path
    case parsed of
      Left e -> die ("refl-check-donations: " ++ path ++ ": " ++ e)
      Right d -> case checkDonations d of
        [] -> mapM_ (\c -> putStrLn ("ok  " <> T.unpack (cnId c) <> "  " <> T.unpack (cnKind c)
                                      <> "  " <> T.unpack (cnAddress c))) (dnChains d)
        problems -> mapM_ (hPutStrLn stderr) problems >> exitFailure
  _ -> die "usage: refl-check-donations <donations.json>"
 where
  die m = hPutStrLn stderr m >> exitFailure
