-- | Router shell: the current URI fragment (initial load, link clicks, back/
-- forward) is decoded with Refl.Protocol.Route and `dyn` mounts the page.
module App (headW, bodyW) where

import           Control.Monad   (forM_, void)
import qualified Data.Map        as M
import           Data.Maybe      (fromMaybe)
import qualified Data.Text       as T
import           Network.URI     (uriFragment)
import           Language.Javascript.JSaddle (eval, fromJSVal, liftJSM)
import           Reflex.Dom.Core

import           Client
import           Refl.Protocol
import           Style           (appCss)
import           Theme
import           Widgets.Dashboard
import           Widgets.Donate
import           Widgets.Inventory
import           Widgets.LevelPage
import           Widgets.WorldMap

headW :: DomBuilder t m => m ()
headW = do
  el "title" (text "The Refl Game")
  elAttr "meta" ("charset" =: "utf-8") blank
  elAttr "meta" ("name" =: "viewport" <> "content" =: "width=device-width, initial-scale=1") blank
  elAttr "link" ("rel" =: "stylesheet" <> "href" =: "/fonts.css") blank
  el "style" (text appCss)

-- | @/dashboard/@ is a path, not a hash route: basic credentials are cached
-- per directory, so the page and its data have to share one. It is mounted
-- straight from the location rather than through 'Route', which is
-- hash-encoded by construction.
bodyW :: Widget x ()
bodyW = do
  path <- getLocationPath
  if path == "/dashboard" || path == "/dashboard/" then dashboardPage else gameW

gameW :: Widget x ()
gameW = mdo
  pb <- getPostBuild
  manifestE <- fetchManifest pb
  progressE <- fetchProgress (leftmost [pb, refreshE, solvedE])
  manifestDyn <- holdDyn Nothing manifestE
  progressDyn <- holdDyn emptyProgress (fmapMaybe id progressE)
  hist <- manageHistory never
  routeDyn <- holdUniqDyn (decodeRoute . T.pack . uriFragment . _historyItem_uri <$> hist)
  -- a route change re-reads progress (a level may have just been solved)
  let refreshE = () <$ updated routeDyn
  -- The language: on a level page it is part of the route (a deep link
  -- carries it), elsewhere it is the last choice. The dropdown never sets it
  -- directly on a level page: it rewrites the hash and the route answers, so
  -- a switch mounts the page exactly once. Nothing here refers forward to an
  -- event that is built later: the dropdown only follows the route.
      routeLang = fmapMaybe (\case Just (RLevel _ _ (Just lg)) -> Just lg; Just (RLesson _ _ (Just lg)) -> Just lg; _ -> Nothing)
        (leftmost [tag (current routeDyn) pb, updated routeDyn])
      onLevel = \case Just (RLevel {}) -> True; Just (RLesson {}) -> True; _ -> False
  -- the language the route asks for, for marking the selected option
  routeLangDyn <- holdDyn "agda" (unLangId <$> routeLang)
  chosenE <- elClass "header" "top" $ do
    elAttr "a" ("href" =: encodeRoute RWorldMap <> "class" =: "brand") (text "The Refl Game")
    el "nav" $ do
      elAttr "a" ("href" =: encodeRoute RWorldMap) (text "Map")
      elAttr "a" ("href" =: encodeRoute RInventory) (text "Inventory")
    elClass "span" "spacer" blank
    -- The one call to action in the chrome: filled, not a nav link, because
    -- a.primary is not button.primary and this must read as a button.
    elAttr "a" ("href" =: encodeRoute RDonate <> "class" =: "support") (text "Support")
    elAttr "label" ("for" =: "language") (text "Language")
    -- a real <select> whose option values are the language ids
    (sel, _) <- selectElement (def
        & selectElementConfig_initialValue .~ "agda"
        & selectElementConfig_setValue .~ (unLangId <$> routeLang)
        & selectElementConfig_elementConfig . elementConfig_initialAttributes .~ ("id" =: "language")) $
      dyn_ $ ffor ((,) <$> manifestDyn <*> routeLangDyn) $ \(mm, cur) ->
        forM_ (maybe [(LangId "agda", "Agda")] (map (\li -> (liId li, liName li <> (if liAvailable li then "" else " (soon)"))) . mLanguages) mm) $ \(lid, label) ->
          elAttr "option" ("value" =: unLangId lid <> (if unLangId lid == cur then "selected" =: "selected" else mempty)) (text label)
    themeToggle
    pure (LangId <$> _selectElement_change sel)
  let chosenElsewhere = gate (not . onLevel <$> current routeDyn) chosenE
      chosenOnLevel = attachWithMaybe
        (\r lg -> case r of
          Just (RLevel w n _) -> Just (RLevel w n (Just lg))
          Just (RLesson w n _) -> Just (RLesson w n (Just lg))
          _ -> Nothing)
        (current routeDyn) chosenE
  langDyn <- holdUniqDyn =<< holdDyn (LangId "agda") (leftmost [routeLang, chosenElsewhere])
  -- Which page was actually looked at. The server sees one document load
  -- per visit and nothing after it, because the route lives in the fragment.
  ticks <- tickLossyFromPostBuildTime 60
  visible <- performEvent $ ffor ticks $ \_ -> liftJSM $ do
    v <- eval ("document.visibilityState === 'visible'" :: T.Text)
    fromJSVal v
  let heartbeat = () <$ ffilter (== Just True) visible
      navigation = leftmost [tag (current routeDyn) pb, updated routeDyn]
  postHit $ fmapMaybe id $ attachWith
    (\lg (beat,mr) -> (\r -> Hit (encodeRoute r) (unLangId lg) beat) <$> mr)
    (current langDyn)
    (leftmost [(False,) <$> navigation, (True,) <$> tag (current routeDyn) heartbeat])
  performEvent_ $ ffor chosenOnLevel $ \r -> liftJSM $ void $ eval
    ("window.location.hash = '" <> encodeRoute r <> "'" :: T.Text)
  pageDyn <- holdUniqDyn $ (\mm mr lg -> (mm, mr, case mr of
    Just (RLevel _ _ ml) -> fromMaybe lg ml
    Just (RLesson _ _ ml) -> fromMaybe lg ml
    _ -> lg)) <$> manifestDyn <*> routeDyn <*> langDyn
  -- The level page flushes its draft and then closes its socket on leaving
  -- (Client.connect); both must run while the page is still mounted, so the
  -- visible page follows the route with a short delay.
  switchE <- delay 0.15 (updated pageDyn)
  initialPage <- sample (current pageDyn)
  shownDyn <- holdDyn initialPage switchE
  let lessonPage m lg wid lid =
        case [lIndex l | w <- mWorlds m, wId w == wid, l <- wLevels w, lId l == lid] of
          n : _ -> levelPage m (() <$ updated pageDyn) lg wid n
          [] -> el "p" (text "No such level.") >> pure never
  solvedE <- el "main" $ switchHold never =<< dyn (ffor shownDyn $ \(mm, mr, lg) ->
    -- Support needs no game data, so it is answered before the manifest: it
    -- must still render when the backend is down or the fetch failed.
    case mr of
     Just RDonate -> donatePage >> pure never
     _ -> case mm of
      Nothing -> el "p" (text "Loading the game…") >> pure never
      Just m -> case mr of
        Nothing -> el "p" (text "404 — no such page.") >> pure never
        Just RWorldMap -> worldMap m progressDyn langDyn >> pure never
        Just (RWorld w) -> worldPage m progressDyn langDyn w >> pure never
        Just (RLevel w n _) ->
          case if w == WorldId "tutorial" then legacyTutorialLevel n else Nothing of
            Just lid -> lessonPage m lg w lid
            Nothing -> levelPage m (() <$ updated pageDyn) lg w n
        Just (RLesson w lid _) -> lessonPage m lg w lid
        Just RInventory -> inventoryPage m progressDyn langDyn >> pure never)
  void (pure hist)
