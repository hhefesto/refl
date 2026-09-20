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
import           Refl.Protocol hiding (Failed)
import           Style.Dashboard             (dashboardCss)
import           Theme                       (themeToggle)
import           Widgets.Common              (Widget')

svgNS :: Maybe Text
svgNS = Just "http://www.w3.org/2000/svg"

tshow :: Show a => a -> Text
tshow = T.pack . show

data DashboardState = Loading Int | Ready Summary | Disabled | Failed Text

ranges :: [(Int, Text)]
ranges = [(30, "30 days"), (90, "90 days"), (365, "a year")]

dashboardPage :: Widget' t m => m ()
dashboardPage = elClass "div" "dash" $ mdo
  el "style" (text dashboardCss)
  pb <- getPostBuild
  (daysE, refreshE, retryE) <- elClass "div" "dash-top" $ do
    el "h1" (text "The Refl Game — dashboard")
    elClass "span" "when" $ dynText $ ffor statsDyn $ \case
      Ready s -> suFrom s <> " to " <> suTo s
      _ -> ""
    elClass "span" "grow" blank
    picked <- elClass "div" "ranges" $ do
      evs <- forM ranges $ \(n, label) -> do
        (b, _) <- elDynAttr' "button"
          (ffor daysDyn $ \d -> "type" =: "button" <> "class" =: (if d == n then "on" else "") <> "aria-pressed" =: (if d == n then "true" else "false"))
          (text label)
        pure (n <$ domEvent Click b)
      pure (leftmost evs)
    -- Both controls sit with the range buttons: a Refresh floating above the
    -- tiles reads as part of the report rather than as a control of it.
    (refresh, retry) <- elClass "div" "acts" $ do
      r <- button "Refresh"
      rt <- switchDyn <$> widgetHold (pure never) (ffor (updated statsDyn) $ \case
        Failed _ -> button "Retry"
        _ -> pure never)
      pure (r, rt)
    -- the toggle is what applies the stored theme at all: without it the
    -- dashboard would always render dark for someone who chose light
    themeToggle
    elAttr "a" ("href" =: "/") (text "← the game")
    pure (picked, refresh, retry)
  daysDyn <- holdDyn 30 daysE
  autoRefresh <- tickLossyFromPostBuildTime 60
  let requestDays = leftmost [30 <$ pb, daysE, tagPromptlyDyn daysDyn (leftmost [refreshE, retryE, () <$ autoRefresh])]
  serial <- count requestDays
  let requests = attachPromptlyDynWith (\i d -> (i,d)) serial requestDays
  replies <- fetchStats requests
  expired <- delay 20 ((\(i,_) -> (i, Left "Dashboard request timed out.")) <$> requests)
  let results = leftmost [replies, expired]
      start (i,_) _ = Loading i
      finish (i,result) old = case old of
        Loading current | i == current -> either Failed (\s -> if suEnabled s then Ready s else Disabled) result
        _ -> old
  statsDyn <- foldDyn ($) (Loading 0) (leftmost [start <$> requests, finish <$> results])
  let statsE = fforMaybe (updated statsDyn) $ \case Ready s -> Just (Just s); _ -> Nothing
  worldE <- fetchWorld pb
  worldDyn <- holdDyn mempty (fmapMaybe id worldE)
  namesDyn <- countryNames statsE
  dyn_ $ ffor ((,,) <$> statsDyn <*> worldDyn <*> namesDyn) $ \(ms, shapes, names) ->
    case ms of
      Loading _ -> elAttr "p" ("role" =: "status") (text "Loading…")
      Failed err -> elAttr "p" ("role" =: "alert") (text err)
      Disabled -> elAttr "p" ("role" =: "status") (text "Analytics collection is disabled.")
      Ready s -> report shapes names s

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
    tile False "Active now (5 min)" (suActive s) 0 ("Period peak: " <> tshow (suPeak s))
    tile (suComparable s) "Browser identities" (toVisitors t) (toVisitors p) (tshow (toNew t) <> " first-time")
    tile (suComparable s) "In-app navigations" (toViews t) (toViews p) (tshow (toLoads t) <> " documents served")
    tile (suComparable s) "Countries" (toCountries t) (toCountries p) (if suGeo s then "" else "no geolocation database loaded")
    tile (suComparable s) "Exercise completions" (toSolves t) (toSolves p) (tshow (toBots t) <> " crawler visits excluded")
    -- The one tile that is about the machine rather than the audience: a
    -- reader costs nothing, a held prover costs one of very few slots.
    tile False "Prover sessions" (suSessions s) 0
      ("of " <> tshow (suSessionsMax s) <> " · peak " <> tshow (suSessionPeak s)
       <> " · " <> tshow (suRejected s) <> " turned away")
  elClass "p" "muted" $ text
    ("Active browsers are cookie identities seen within five minutes. Visible game tabs send a minute heartbeat; multiple tabs count once. "
     <> "Older history without heartbeats can undercount readers. Snapshot: " <> suAsOf s <> ". Refreshes each minute.")
  if suComparable s then blank else elClass "p" "coverage" $ text
    ("Comparison unavailable: incomplete recorded history (" <> tshow (suCoveredDays s) <> " complete UTC days).")
  elClass "p" "muted" $ text
    ("A prover session is one open level holding one checker process. Turned away counts connections refused "
     <> "because every slot was busy; if that number is not zero, raise --max-sessions or the server is the limit. ")
  elClass "p" "muted" $ text
    ("Completions count each browser, lesson and language once per period; Agda and Lean count separately. "
     <> tshow (suUnknown s) <> " unclassified legacy events excluded from browser metrics.")
  elClass "div" "panels" $ do
    panelWide "Browser identities and daily peak" (lineChart (suDaily s))
    panelWide "Where from" $ elClass "div" "geo-row" $ do
      el "div" (geoMap shapes names (suCountries s))
      el "div" $ do
        el "h3" (text "Most visits")
        countryTable names (suCountries s)
        missingNote shapes (suCountries s)
    panelTwo "Exercises opened and solved" $ do
      el "p" (text "Distinct browser–language pairs per lesson. A check also counts as opening.")
      levelBars (suLevels s)
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

tile :: Widget' t m => Bool -> Text -> Int -> Int -> Text -> m ()
tile comparable k v prev note = elClass "div" "tile" $ do
  elClass "div" "k" (text k)
  elClass "div" "v" (text (tshow v))
  if comparable && prev > 0 then elClass "div" ("d" <> dir) (text delta) else blank
  if T.null note then blank else elClass "div" "note" (text note)
  where
   pct = if prev == 0 then 0
         else round ((fromIntegral v - fromIntegral prev) / fromIntegral prev * 100 :: Double) :: Int
   dir | pct > 0 = " up" | pct < 0 = " down" | otherwise = ""
   delta = (if pct > 0 then "+" else "") <> tshow pct <> "% on the period before"

-- ---------------------------------------------------------------------------
-- Daily identities and peak active browsers share a count axis.
-- ---------------------------------------------------------------------------

lineChart :: Widget' t m => [DayPoint] -> m ()
lineChart pts
  | null pts || all (\d -> dpVisitors d == 0 && dpPeak d == 0) pts = elClass "p" "empty" (text "No visits recorded yet.")
  | otherwise = elClass "div" "chart" $ do
      elClass "div" "keys" $ do
        elClass "span" "k" (text "Solid: daily browser identities")
        elClass "span" "k" (text "Dashed: peak active (5 min)")
      _ <- elDynAttrNS' svgNS "svg" (constDyn ("viewBox" =: "0 0 960 250" <> "xmlns" =: ns)) $ do
        forM_ [0, 1, 2 :: Int] $ \i -> do
          let y = top + plotH * fromIntegral i / 2
              v = round (peak * (1 - fromIntegral i / 2)) :: Int
          line' "grid" left y (left + plotW) y
          svgText "tick" (left - 8) (y + 4) "end" (tshow v)
        _ <- elDynAttrNS' svgNS "path" (constDyn ("class" =: "area" <> "d" =: areaPath)) blank
        _ <- elDynAttrNS' svgNS "path" (constDyn ("class" =: "line" <> "d" =: linePath)) blank
        _ <- elDynAttrNS' svgNS "path" (constDyn ("class" =: "concurrent" <> "d" =: seriesPath dpPeak)) blank
        forM_ (zip [0 ..] pts) $ \(i, d) -> do
          _ <- elDynAttrNS' svgNS "rect"
            (constDyn ("class" =: "hit" <> "x" =: num (xAt i - slot / 2) <> "y" =: num top
                       <> "width" =: num slot <> "height" =: num plotH)) $
            elDynAttrNS' svgNS "title" (constDyn mempty)
              (text (dpDay d <> ": " <> tshow (dpVisitors d) <> " visitors, "
                     <> tshow (dpViews d) <> " navigations, peak active: " <> tshow (dpPeak d)))
          pure ()
        let lastI = length pts - 1
            lastD = last pts
        _ <- elDynAttrNS' svgNS "circle"
          (constDyn ("class" =: "dot" <> "cx" =: num (xAt lastI) <> "cy" =: num (yAt lastD) <> "r" =: "3.5")) blank
        svgText "last" (xAt lastI - 6) (yAt lastD - 9) "end" (tshow (dpVisitors lastD))
        svgText "tick" left 243 "start" (dpDay (head pts))
        svgText "tick" (left + plotW) 243 "end" (dpDay lastD)
      el "details" $ do
        el "summary" (text "Daily chart values")
        elClass "div" "daily-values" $ el "table" $ do
          el "thead" $ el "tr" $ forM_ ["UTC day", "Browser identities", "Document loads", "Navigations", "Peak active (5 min)", "Peak prover sessions"] (el "th" . text)
          el "tbody" $ forM_ pts $ \d -> el "tr" $
            forM_ [dpDay d, tshow (dpVisitors d), tshow (dpLoads d), tshow (dpViews d), tshow (dpPeak d), tshow (dpSessions d)] (el "td" . text)
 where
  ns = "http://www.w3.org/2000/svg" :: Text
  left = 44; top = 14; plotW = 900; plotH = 196 :: Double
  n = length pts
  peak = fromIntegral (maximum (1 : concat [[dpVisitors d, dpPeak d] | d <- pts])) :: Double
  slot = if n > 1 then plotW / fromIntegral (n - 1) else plotW
  xAt i = if n > 1 then left + plotW * fromIntegral i / fromIntegral (n - 1) else left + plotW / 2
  yValue v = top + plotH * (1 - fromIntegral v / peak)
  yAt = yValue . dpVisitors
  seriesPath field = T.unwords ("M" : concat
    [ [num (xAt i), num (yValue (field d))] ++ (if i == n - 1 then [] else ["L"]) | (i, d) <- zip [0 ..] pts ])
  linePath = seriesPath dpVisitors
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
 where top = sortOn (Down . buCount) cs

-- | Natural Earth's 1:110m outlines omit the microstates (Singapore, Malta,
-- Monaco). A visit from one must still be visible, so say so rather than
-- letting the map quietly lose it.
missingNote :: Widget' t m => M.Map Text Text -> [Bucket] -> m ()
missingNote shapes _ | M.null shapes = blank
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
