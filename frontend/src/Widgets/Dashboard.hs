-- | The private dashboard at @/dashboard/@. Not a route: it is mounted from
-- the path, so it has its own chrome and none of the game's.
--
-- Everything is drawn from the aggregate the server sends; the page never
-- sees an event, an address or anything that could identify a visitor.
module Widgets.Dashboard (dashboardPage) where

import           Control.Monad               (forM, forM_)
import           Data.Aeson                  (decodeStrict)
import           Data.List                   (sortOn)
import qualified Data.Map                    as M
import           Data.Maybe                  (fromMaybe)
import           Data.Ord                    (Down (..))
import           Data.Text                   (Text)
import qualified Data.Text                   as T
import qualified Data.Text.Encoding          as TE
import           Language.Javascript.JSaddle (eval, fromJSVal, liftJSM)
import           Reflex.Dom.Core

import           Client                      (fetchStats, fetchWorld)
import           Refl.Protocol
import           Style.Dashboard             (dashboardCss)
import           Theme                       (themeToggle)
import           Widgets.Common              (Widget')

svgNS :: Maybe Text
svgNS = Just "http://www.w3.org/2000/svg"

tshow :: Show a => a -> Text
tshow = T.pack . show

ranges :: [(Int, Text)]
ranges = [(30, "30 days"), (90, "90 days"), (365, "a year")]

dashboardPage :: Widget' t m => m ()
dashboardPage = elClass "div" "dash" $ mdo
  el "style" (text dashboardCss)
  pb <- getPostBuild
  daysE <- elClass "div" "dash-top" $ do
    el "h1" (text "The Refl Game — dashboard")
    elClass "span" "when" $ dynText $ ffor statsDyn $ \case
      Just s -> suFrom s <> " to " <> suTo s
      Nothing -> ""
    elClass "span" "grow" blank
    picked <- elClass "div" "ranges" $ do
      evs <- forM ranges $ \(n, label) -> do
        (b, _) <- elDynAttr' "button"
          (ffor daysDyn $ \d -> "type" =: "button" <> "class" =: (if d == n then "on" else ""))
          (text label)
        pure (n <$ domEvent Click b)
      pure (leftmost evs)
    -- the toggle is what applies the stored theme at all: without it the
    -- dashboard would always render dark for someone who chose light
    themeToggle
    elAttr "a" ("href" =: "/") (text "← the game")
    pure picked
  daysDyn <- holdDyn 30 daysE
  statsE <- fetchStats (leftmost [30 <$ pb, daysE])
  statsDyn <- holdDyn Nothing statsE
  worldE <- fetchWorld pb
  worldDyn <- holdDyn mempty (fmapMaybe id worldE)
  namesDyn <- countryNames statsE
  dyn_ $ ffor ((,,) <$> statsDyn <*> worldDyn <*> namesDyn) $ \(ms, shapes, names) ->
    case ms of
      Nothing -> elClass "p" "muted" (text "Loading…")
      Just s -> report shapes names s

-- | Country names without shipping a table of them: every browser has one.
countryNames :: Widget' t m => Event t (Maybe Summary) -> m (Dynamic t (M.Map Text Text))
countryNames e = holdDyn mempty =<< performEvent (ffor (fmapMaybe id e) resolve)
 where
  resolve s = liftJSM $ do
    let codes = T.intercalate "," [buKey b | b <- suCountries s, T.length (buKey b) == 2]
    v <- eval ("(() => { try { const d = new Intl.DisplayNames(['en'], {type:'region'});"
               <> " return JSON.stringify(Object.fromEntries(" <> tshow codes
               <> ".split(',').filter(Boolean).map(c => [c, d.of(c) || c])));"
               <> " } catch (_) { return '{}'; } })()" :: Text)
    mt <- fromJSVal v
    pure (maybe mempty (fromMaybe mempty . decodeStrict . TE.encodeUtf8) (mt :: Maybe Text))

report :: Widget' t m => M.Map Text Text -> M.Map Text Text -> Summary -> m ()
report shapes names s = do
  let t = suTotals s
      p = suPrevious s
  elClass "div" "tiles" $ do
    tile "Visitors" (toVisitors t) (toVisitors p) (tshow (toNew t) <> " first-time")
    tile "Page views" (toViews t) (toViews p) (tshow (toLoads t) <> " documents served")
    tile "Countries" (toCountries t) (toCountries p) (if suGeo s then "" else "no geolocation database loaded")
    tile "Levels solved" (toSolves t) (toSolves p) (tshow (toBots t) <> " crawler visits excluded")
  elClass "div" "panels" $ do
    panelWide "Visitors per day" (lineChart (suDaily s))
    panelWide "Where from" $ elClass "div" "geo-row" $ do
      el "div" (geoMap shapes names (suCountries s))
      el "div" $ do
        el "h3" (text "Most visits")
        countryTable names (suCountries s)
        missingNote shapes (suCountries s)
    panelTwo "Levels opened and solved" $ levelBars (suLevels s)
    panel "Pages" $ bars "" (suPages s)
    panel "Languages" $ bars "b" (suLanguages s)
    panel "Referrers" $ bars "c" (suReferrers s)
    panel "Browsers" $ bars "" (suBrowsers s)
    panel "Device" $ bars "b" (suAgents s)
  elClass "p" "dash-foot" $ do
    text ("No IP address is ever stored; a visitor is the site's own anonymous cookie. "
          <> "Events are kept " <> tshow (suRetention s) <> " days. ")
    elAttr "a" ("href" =: "https://db-ip.com/" <> "rel" =: "noreferrer") (text "IP geolocation by DB-IP")
    text " (CC BY 4.0). Outlines: Natural Earth, public domain."
 where
  panel h inner = elClass "section" "panel" (el "h2" (text h) >> inner)
  panelWide h inner = elClass "section" "panel wide" (el "h2" (text h) >> inner)
  panelTwo h inner = elClass "section" "panel two" (el "h2" (text h) >> inner)

tile :: Widget' t m => Text -> Int -> Int -> Text -> m ()
tile k v prev note = elClass "div" "tile" $ do
  elClass "div" "k" (text k)
  elClass "div" "v" (text (tshow v))
  if prev > 0 then elClass "div" ("d" <> dir) (text delta) else blank
  if T.null note then blank else elClass "div" "note" (text note)
  where
   pct = if prev == 0 then 0
         else round ((fromIntegral v - fromIntegral prev) / fromIntegral prev * 100 :: Double) :: Int
   dir | pct > 0 = " up" | pct < 0 = " down" | otherwise = ""
   delta = (if pct > 0 then "+" else "") <> tshow pct <> "% on the period before"

-- ---------------------------------------------------------------------------
-- Visitors per day: one series, so no legend; the last point is labelled.
-- ---------------------------------------------------------------------------

lineChart :: Widget' t m => [DayPoint] -> m ()
lineChart pts
  | null pts || all ((== 0) . dpVisitors) pts = elClass "p" "empty" (text "No visits recorded yet.")
  | otherwise = elClass "div" "chart" $ do
      _ <- elDynAttrNS' svgNS "svg" (constDyn ("viewBox" =: "0 0 960 250" <> "xmlns" =: ns)) $ do
        forM_ [0, 1, 2 :: Int] $ \i -> do
          let y = top + plotH * fromIntegral i / 2
              v = round (peak * (1 - fromIntegral i / 2)) :: Int
          line' "grid" left y (left + plotW) y
          svgText "tick" (left - 8) (y + 4) "end" (tshow v)
        _ <- elDynAttrNS' svgNS "path" (constDyn ("class" =: "area" <> "d" =: areaPath)) blank
        _ <- elDynAttrNS' svgNS "path" (constDyn ("class" =: "line" <> "d" =: linePath)) blank
        forM_ (zip [0 ..] pts) $ \(i, d) -> do
          _ <- elDynAttrNS' svgNS "rect"
            (constDyn ("class" =: "hit" <> "x" =: num (xAt i - slot / 2) <> "y" =: num top
                       <> "width" =: num slot <> "height" =: num plotH)) $
            elDynAttrNS' svgNS "title" (constDyn mempty)
              (text (dpDay d <> ": " <> tshow (dpVisitors d) <> " visitors, "
                     <> tshow (dpViews d) <> " views"))
          pure ()
        let lastI = length pts - 1
            lastD = last pts
        _ <- elDynAttrNS' svgNS "circle"
          (constDyn ("class" =: "dot" <> "cx" =: num (xAt lastI) <> "cy" =: num (yAt lastD) <> "r" =: "3.5")) blank
        svgText "last" (xAt lastI - 6) (yAt lastD - 9) "end" (tshow (dpVisitors lastD))
        svgText "tick" left 243 "start" (dpDay (head pts))
        svgText "tick" (left + plotW) 243 "end" (dpDay lastD)
      pure ()
 where
  ns = "http://www.w3.org/2000/svg" :: Text
  left = 44; top = 14; plotW = 900; plotH = 196 :: Double
  n = length pts
  peak = fromIntegral (max 1 (maximum (map dpVisitors pts))) :: Double
  slot = if n > 1 then plotW / fromIntegral (n - 1) else plotW
  xAt i = if n > 1 then left + plotW * fromIntegral i / fromIntegral (n - 1) else left + plotW / 2
  yAt d = top + plotH * (1 - fromIntegral (dpVisitors d) / peak)
  linePath = T.unwords ("M" : concat
    [ [num (xAt i), num (yAt d)] ++ (if i == n - 1 then [] else ["L"]) | (i, d) <- zip [0 ..] pts ])
  areaPath = linePath <> " L" <> num (xAt (n - 1)) <> " " <> num (top + plotH)
             <> " L" <> num (xAt 0) <> " " <> num (top + plotH) <> " Z"

line' :: Widget' t m => Text -> Double -> Double -> Double -> Double -> m ()
line' cls x1 y1 x2 y2 = do
  _ <- elDynAttrNS' svgNS "line" (constDyn ("class" =: cls <> "x1" =: num x1 <> "y1" =: num y1
                                            <> "x2" =: num x2 <> "y2" =: num y2)) blank
  pure ()

svgText :: Widget' t m => Text -> Double -> Double -> Text -> Text -> m ()
svgText cls x y anchor body = do
  _ <- elDynAttrNS' svgNS "text" (constDyn ("class" =: cls <> "x" =: num x <> "y" =: num y
                                            <> "text-anchor" =: anchor)) (text body)
  pure ()

num :: Double -> Text
num x = T.pack (show (fromIntegral (round (x * 10) :: Integer) / 10 :: Double))

-- ---------------------------------------------------------------------------
-- The map
-- ---------------------------------------------------------------------------

geoMap :: Widget' t m => M.Map Text Text -> M.Map Text Text -> [Bucket] -> m ()
geoMap shapes names cs
  | M.null shapes = elClass "p" "empty" (text "Country outlines are unavailable.")
  | otherwise = do
      elClass "div" "geo" $ do
        -- cropped north of 84 and south of 60: the poles are empty and
        -- Antarctica would take a quarter of the frame
        _ <- elDynAttrNS' svgNS "svg"
          (constDyn ("viewBox" =: "0 33 2000 800" <> "xmlns" =: "http://www.w3.org/2000/svg"
                     <> "role" =: "img" <> "aria-label" =: "Visitors by country")) $
          forM_ (M.toList shapes) $ \(iso, d) -> do
            _ <- elDynAttrNS' svgNS "path"
              (constDyn ("class" =: ("land " <> bucketClass iso) <> "d" =: d)) $
              elDynAttrNS' svgNS "title" (constDyn mempty)
                (text (M.findWithDefault iso iso names <> ": " <> visits iso))
            pure ()
        pure ()
      elClass "div" "legend" $ do
        text "visits"
        forM_ [0 .. 5 :: Int] $ \q ->
          elAttr "span" ("class" =: "sw" <> "style" =: ("background:var(--seq-" <> tshow q <> ")")) blank
        text (if peak <= 1 then "" else "1 – " <> tshow peak)
 where
  counts = M.fromList [(buKey b, buCount b) | b <- cs]
  peak = maximum (1 : M.elems counts)
  visits iso = maybe "no visits" (\c -> tshow c <> (if c == 1 then " visit" else " visits")) (M.lookup iso counts)
  bucketClass iso = case M.lookup iso counts of
    Nothing -> "q0"
    Just c -> "q" <> tshow (max 1 (min 5 (ceiling (5 * fromIntegral c / fromIntegral peak :: Double) :: Int)))

-- | The map's accessible twin, and the only place a country too small for
-- Natural Earth's 1:110m outlines (Singapore, Malta, Monaco) can appear.
countryTable :: Widget' t m => M.Map Text Text -> [Bucket] -> m ()
countryTable names cs = bars "" [ b { buLabel = M.findWithDefault (buKey b) (buKey b) names } | b <- top ]
 where top = take 8 (sortOn (Down . buCount) cs)

-- | Natural Earth's 1:110m outlines omit the microstates (Singapore, Malta,
-- Monaco). A visit from one must still be visible, so say so rather than
-- letting the map quietly lose it.
missingNote :: Widget' t m => M.Map Text Text -> [Bucket] -> m ()
missingNote shapes cs = case [buKey b | b <- cs, not (M.member (buKey b) shapes), buKey b /= "other"] of
  [] -> blank
  ms -> elClass "p" "empty" $ text
    ("Not drawn on the map (too small for the outline set): " <> T.intercalate ", " ms <> ".")

-- ---------------------------------------------------------------------------
-- Bars
-- ---------------------------------------------------------------------------

bars :: Widget' t m => Text -> [Bucket] -> m ()
bars variant bs
  | null bs = elClass "p" "empty" (text "Nothing yet.")
  | otherwise = elClass "div" "bars" $ forM_ bs $ \b -> elClass "div" "row" $ do
      elAttr "div" ("class" =: "name" <> "title" =: buLabel b) (text (buLabel b))
      elClass "div" "track" $
        elAttr "div" ("class" =: ("fill " <> variant)
                      <> "style" =: ("width:" <> pct (buCount b) <> "%")) blank
      elClass "div" "n" (text (tshow (buCount b)))
 where
  peak = maximum (1 : map buCount bs)
  pct c = tshow (max 2 (round (100 * fromIntegral c / fromIntegral peak :: Double) :: Int))

-- | Two series, so it carries a key as well as the numbers.
levelBars :: Widget' t m => [LevelStat] -> m ()
levelBars ls
  | null ls = elClass "p" "empty" (text "No level has been opened yet.")
  | otherwise = do
      elClass "div" "keys" $ do
        key "" "opened"
        key "solved" "solved"
      elClass "div" "bars" $ forM_ (take 12 (sortOn (Down . lvOpened) ls)) $ \l ->
        elClass "div" "row" $ do
          elAttr "div" ("class" =: "name" <> "title" =: lvKey l) (text (lvKey l))
          -- one scale, two bars: lengths are directly comparable and solved
          -- can never look longer than opened
          elClass "div" "pairtrack" $ do
            elClass "div" "t" $ elAttr "div"
              ("class" =: "f opened" <> "style" =: ("width:" <> pct (lvOpened l) <> "%")) blank
            elClass "div" "t" $ elAttr "div"
              ("class" =: "f solved" <> "style" =: ("width:" <> pct (lvSolved l) <> "%")) blank
          elClass "div" "n" (text (tshow (lvSolved l) <> " / " <> tshow (lvOpened l)))
 where
  peak = maximum (1 : map lvOpened ls)
  pct c = tshow (max 0 (round (100 * fromIntegral c / fromIntegral peak :: Double) :: Int))
  key cls label = elClass "span" "k" $ do
    elAttr "span" ("class" =: "sw" <> "style" =: ("background:var(--" <> (if T.null cls then "cat-1" else "ok") <> ")")) blank
    text label
