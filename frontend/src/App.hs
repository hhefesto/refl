-- | Router shell: the current URI fragment (initial load, link clicks, back/
-- forward) is decoded with Refl.Protocol.Route and `dyn` mounts the page.
module App (headW, bodyW) where

import           Control.Monad   (void)
import qualified Data.Map        as M
import           Data.Maybe      (fromMaybe)
import qualified Data.Text       as T
import           Network.URI     (uriFragment)
import           Language.Javascript.JSaddle (eval, liftJSM)
import           Reflex.Dom.Core

import           Client
import           Refl.Protocol
import           Style           (appCss)
import           Theme
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
  liftJSM $ void $ eval ("console.log('body start')" :: T.Text)
  pb <- getPostBuild
  manifestE <- fetchManifest pb
  progressE <- fetchProgress (leftmost [pb, refreshE, solvedE])
  manifestDyn <- holdDyn Nothing manifestE
  progressDyn <- holdDyn emptyProgress (fmapMaybe id progressE)
  liftJSM $ void $ eval ("console.log('fetches')" :: T.Text)
  hist <- manageHistory never
  routeDyn <- holdUniqDyn (decodeRoute . T.pack . uriFragment . _historyItem_uri <$> hist)
  -- a route change re-reads progress (a level may have just been solved)
  let refreshE = () <$ updated routeDyn
  let routeLang = fmapMaybe (\case Just (RLevel _ _ (Just lg)) -> Just lg; _ -> Nothing)
        (leftmost [tag (current routeDyn) pb, updated routeDyn])
  liftJSM $ void $ eval ("console.log('route')" :: T.Text)
  langDyn <- holdUniqDyn =<< holdDyn (LangId "agda") (leftmost [routeLang, chosenE])
  liftJSM $ void $ eval ("console.log('language')" :: T.Text)
  chosenE <- elClass "header" "top" $ do
    elAttr "a" ("href" =: encodeRoute RWorldMap <> "class" =: "brand") (text "The Refl Game")
    el "nav" $ do
      elAttr "a" ("href" =: encodeRoute RWorldMap) (text "Map")
      elAttr "a" ("href" =: encodeRoute RInventory) (text "Inventory")
    elClass "span" "spacer" blank
    elAttr "label" ("for" =: "language") (text "Language")
    dd <- dropdown "agda" (ffor manifestDyn (maybe (M.singleton "agda" "Agda") (M.fromList . map (\li -> (unLangId (liId li), liName li <> (if liAvailable li then "" else " (soon)"))) . mLanguages)))
      (def & dropdownConfig_setValue .~ (unLangId <$> leftmost [updated langDyn, tagPromptlyDyn langDyn (() <$ updated manifestDyn)])
           & dropdownConfig_attributes .~ constDyn ("id" =: "language"))
    liftJSM $ void $ eval ("console.log('dropdown')" :: T.Text)
    themeToggle
    liftJSM $ void $ eval ("console.log('theme')" :: T.Text)
    pure (LangId <$> _dropdown_change dd)
  performEvent_ $ ffor (attach (current routeDyn) chosenE) $ \(route, lg) ->
    case route of
      Just (RLevel w n _) -> liftJSM $ void $ eval
        ("window.location.hash = '" <> encodeRoute (RLevel w n (Just lg)) <> "'" :: T.Text)
      _ -> pure ()
  liftJSM $ void $ eval ("console.log('header')" :: T.Text)
  pageDyn <- holdUniqDyn $ (\mm mr lg -> (mm, mr, case mr of
    Just (RLevel _ _ ml) -> fromMaybe lg ml
    _ -> lg)) <$> manifestDyn <*> routeDyn <*> langDyn
  liftJSM $ void $ eval ("console.log('page key')" :: T.Text)
  solvedE <- el "main" $ switchHold never =<< dyn (ffor pageDyn $ \(mm, mr, lg) ->
    case mm of
      Nothing -> el "p" (text "Loading the game…") >> pure never
      Just m -> case mr of
        Nothing -> el "p" (text "404 — no such page.") >> pure never
        Just RWorldMap -> worldMap m progressDyn langDyn >> pure never
        Just (RWorld w) -> worldPage m progressDyn langDyn w >> pure never
        Just (RLevel w n _) -> levelPage m (() <$ updated pageDyn) lg w n
        Just RInventory -> inventoryPage m progressDyn langDyn >> pure never)
  liftJSM $ void $ eval ("console.log('body end')" :: T.Text)
  void (pure hist)
