-- | Turn Natural Earth's 1:110m country outlines into the one file the
-- dashboard's map needs: @{"US": "M… Z", …}@, ISO 3166-1 alpha-2 to an SVG
-- path in an equirectangular projection on a 2000x1000 canvas.
--
-- Run by hand, like @refl-gen-input-table@; the /output/ is checked in, so
-- @nix flake check@ needs no network and the browser downloads geometry
-- only when someone opens the dashboard:
--
-- @
-- curl -LO https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_admin_0_countries.geojson
-- refl-gen-world-map ne_110m_admin_0_countries.geojson world-countries.json
-- @
--
-- Natural Earth is public domain. @ISO_A2_EH@ is the field to read: plain
-- @ISO_A2@ is @-99@ for France, Norway and a few others.
module Main (main) where

import           Control.Monad        (guard)
import           Data.Aeson
import           Data.Aeson.Types     (parseMaybe)
import qualified Data.Aeson.KeyMap    as KM
import qualified Data.ByteString.Lazy as BL
import           Data.List            (group)
import qualified Data.Map.Strict      as M
import           Data.Maybe           (mapMaybe)
import           Data.Text            (Text)
import qualified Data.Text            as T
import           Numeric              (showFFloat)
import           System.Environment   (getArgs)
import           System.Exit          (exitFailure)
import           System.IO            (hPutStrLn, stderr)

main :: IO ()
main = getArgs >>= \case
  [inp, outp] -> do
    parsed <- eitherDecodeFileStrict inp
    case parsed >>= \v -> maybe (Left "no features array") Right (features v) of
      Left e -> die ("refl-gen-world-map: " ++ inp ++ ": " ++ e)
      Right fs -> do
        let paths = M.fromListWith (<>) (mapMaybe country fs)
        BL.writeFile outp (encode paths)
        hPutStrLn stderr ("refl-gen-world-map: " ++ show (M.size paths)
                          ++ " countries, " ++ show (sum (map T.length (M.elems paths)))
                          ++ " path characters")
  _ -> die "usage: refl-gen-world-map <ne_110m_admin_0_countries.geojson> <out.json>"
 where
  die m = hPutStrLn stderr m >> exitFailure

features :: Value -> Maybe [Value]
features = parseMaybe (withObject "collection" (.: "features"))

country :: Value -> Maybe (Text, Text)
country v = do
  o <- object' v
  props <- KM.lookup "properties" o >>= object'
  iso <- firstOf [KM.lookup k props >>= text' | k <- ["ISO_A2_EH", "ISO_A2"]]
  guard (T.length iso == 2 && T.all (\c -> c >= 'A' && c <= 'Z') iso)
  geom <- KM.lookup "geometry" o >>= object'
  ty <- KM.lookup "type" geom >>= text'
  coords <- KM.lookup "coordinates" geom
  rings <- case ty of
    "Polygon"      -> parseMaybe parseJSON coords :: Maybe [[[Double]]]
    "MultiPolygon" -> concat <$> (parseMaybe parseJSON coords :: Maybe [[[[Double]]]])
    _              -> Nothing
  let d = T.concat (mapMaybe ring rings)
  guard (not (T.null d))
  pure (iso, d)
 where
  object' (Object o) = Just o
  object' _ = Nothing
  text' (String t) = Just t
  text' _ = Nothing
  firstOf xs = case [x | Just x <- xs] of y : _ -> Just y; [] -> Nothing

-- | One ring as a closed subpath. Holes (Lesotho) are kept as further
-- subpaths and resolved by @fill-rule: evenodd@ at draw time.
ring :: [[Double]] -> Maybe Text
ring pts = case dedup (mapMaybe project pts) of
  ps@((x0, y0) : rest) | length ps >= 3 ->
    Just (T.concat (["M", num x0, " ", num y0]
                    ++ concat [["L", num x, " ", num y] | (x, y) <- rest]
                    ++ ["Z"]))
  _ -> Nothing
 where
  -- equirectangular: 0..2000 west to east, 0..1000 north to south
  project (lon : lat : _) = Just (round1 ((lon + 180) * k), round1 ((90 - lat) * k))
  project _ = Nothing
  k = 1000 / 180 :: Double
  round1 x = fromIntegral (round (x * 10) :: Integer) / 10 :: Double
  dedup = map head . group

-- | One decimal is ~20 km at the equator, far finer than the map is drawn,
-- and dropping a trailing @.0@ takes a fifth off the file.
num :: Double -> Text
num x = let s = showFFloat (Just 1) x ""
        in T.pack (maybe s id (stripSuffix ".0" s))
 where
  stripSuffix suf str =
    let n = length str - length suf
    in if n > 0 && drop n str == suf then Just (take n str) else Nothing
