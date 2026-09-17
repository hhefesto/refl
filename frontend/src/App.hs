-- | Router shell: the current URI fragment (initial load, link clicks, back/
-- forward) is decoded with Refl.Protocol.Route and `dyn` mounts the page.
module App (headW, bodyW) where

import           Control.Monad   (void)
import qualified Data.Map        as M
import           Data.Maybe      (fromMaybe)
import qualified Data.Text       as T
import           Network.URI     (uriFragment)
import           Reflex.Dom.Core

import           Client
import           Refl.Protocol
import           Style           (appCss)
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

bodyW :: Widget x ()
bodyW = mdo
  pb <- getPostBuild
  manifestE <- fetchManifest pb
  progressE <- fetchProgress (leftmost [pb, refreshE])
  manifestDyn <- holdDyn Nothing manifestE
  progressDyn <- holdDyn emptyProgress (fmapMaybe id progressE)
  hist <- manageHistory never
  routeDyn <- holdUniqDyn (decodeRoute . T.pack . uriFragment . _historyItem_uri <$> hist)
  -- a route change re-reads progress (a level may have just been solved)
  let refreshE = () <$ updated routeDyn
  -- header with the language selector
  langDyn <- elClass "header" "top" $ do
    elAttr "a" ("href" =: encodeRoute RWorldMap <> "class" =: "brand") (text "The Refl Game")
    el "nav" $ do
      elAttr "a" ("href" =: encodeRoute RWorldMap) (text "Map")
      elAttr "a" ("href" =: encodeRoute RInventory) (text "Inventory")
    elClass "span" "spacer" blank
    dd <- dropdown "agda" (ffor manifestDyn (maybe (M.singleton "agda" "Agda") (M.fromList . map (\li -> (unLangId (liId li), liName li <> (if liAvailable li then "" else " (soon)"))) . mLanguages))) def
    pure (LangId <$> _dropdown_value dd)
  el "main" $ dyn_ $ ffor ((,) <$> manifestDyn <*> routeDyn) $ \(mm, mr) ->
    case mm of
      Nothing -> el "p" (text "Loading the game…")
      Just m -> case mr of
        Nothing -> el "p" (text "404 — no such page.")
        Just RWorldMap -> worldMap m progressDyn langDyn
        Just (RWorld w) -> worldPage m progressDyn langDyn w
        Just (RLevel w n ml) -> dyn_ $ ffor langDyn $ \lg ->
          levelPage m progressDyn refreshE (fromMaybe lg ml) w n
        Just RInventory -> inventoryPage m progressDyn langDyn
  void (pure hist)
