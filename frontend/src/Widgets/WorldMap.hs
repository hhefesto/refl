-- | The world map (an SVG DAG) and the world page (its level list).
module Widgets.WorldMap
  ( worldMap
  , worldPage
  , levelDone
  , worldDone
  , worldState
  , WorldState (..)
  ) where

import           Control.Monad       (forM_)
import qualified Data.Map            as M
import           Data.Maybe          (fromMaybe)
import           Data.Text           (Text)
import qualified Data.Text           as T
import           Reflex.Dom.Core

import           Refl.Protocol
import           Refl.Protocol.Graph (layout)
import           Widgets.Common

data WorldState = WDone | WOpen | WLocked | WSkeleton
  deriving (Eq, Show)

levelDone :: Progress -> LangId -> WorldId -> Level -> Bool
levelDone p lang w l = levelKey w (lId l) `elem` fromMaybe [] (M.lookup lang (prCompleted p))

worldDone :: Progress -> LangId -> World -> Bool
worldDone p lang w = not (null playable) && all (levelDone p lang (wId w)) playable
 where
  playable = [ l | l <- wLevels w, lang `M.member` lLanguages l ]

worldState :: Manifest -> Progress -> LangId -> World -> WorldState
worldState m p lang w
  | null [ l | l <- wLevels w, lang `M.member` lLanguages l ] = WSkeleton
  | worldDone p lang w = WDone
  | all depDone (wDeps w) = WOpen
  | otherwise = WLocked
 where
  byId = M.fromList [ (wId x, x) | x <- mWorlds m ]
  depDone d = maybe True (worldPrerequisiteDone p lang) (M.lookup d byId)

svgNS :: Maybe Text
svgNS = Just "http://www.w3.org/2000/svg"

worldMap :: Widget' t m => Manifest -> Dynamic t Progress -> Dynamic t LangId -> m ()
worldMap m progress langDyn = do
  elClass "div" "card prose" $ rawHtml (mIntroHtml m)
  elClass "div" "map" $ do
    let deps = M.fromList [ (wId w, wDeps w) | w <- mWorlds m ]
        pos = layout deps
        byId = M.fromList [ (wId w, w) | w <- mWorlds m ]
        colW = 190 :: Int
        rowH = 120 :: Int
        xy i = case M.lookup i pos of
          Just (layer, col) -> (col * colW + 100, layer * rowH + 60)
          Nothing -> (100, 60)
        maxCol = maximum (0 : [ c | (_, c) <- M.elems pos ])
        maxLayer = maximum (0 : [ l | (l, _) <- M.elems pos ])
        width = (maxCol + 1) * colW + 20
        height = (maxLayer + 1) * rowH + 20
        attrs = "viewBox" =: T.unwords (map tshow [0, 0, width, height]) <> "xmlns" =: "http://www.w3.org/2000/svg"
    _ <- elDynAttrNS' svgNS "svg" (constDyn attrs) $ do
      forM_ (mWorlds m) $ \w -> forM_ (wDeps w) $ \d -> do
        let (x1, y1) = xy d; (x2, y2) = xy (wId w)
        _ <- elDynAttrNS' svgNS "path" (constDyn ("class" =: "edge" <> "d" =: curve x1 y1 x2 y2)) blank
        pure ()
      forM_ (mWorlds m) $ \w -> do
        let (x, y) = xy (wId w)
            cls = ffor ((,) <$> progress <*> langDyn) $ \(p, lang) ->
              "node " <> case worldState m p lang w of
                WDone -> "done"; WOpen -> "open"; WLocked -> "locked"; WSkeleton -> "skeleton"
            done = ffor ((,) <$> progress <*> langDyn) $ \(p, lang) ->
              length [ l | l <- wLevels w, levelDone p lang (wId w) l ]
        _ <- elDynAttrNS' svgNS "a" (constDyn ("href" =: encodeRoute (RWorld (wId w)))) $
          elDynAttrNS' svgNS "g" (ffor cls (\c -> "class" =: c)) $ do
            _ <- elDynAttrNS' svgNS "circle" (constDyn ("cx" =: tshow x <> "cy" =: tshow y <> "r" =: "26")) blank
            _ <- elDynAttrNS' svgNS "text" (constDyn ("x" =: tshow x <> "y" =: tshow (y + 44))) (text (wTitle w))
            _ <- elDynAttrNS' svgNS "text" (constDyn ("x" =: tshow x <> "y" =: tshow (y + 60) <> "class" =: "count")) $
              dynText (ffor done (\d -> tshow d <> " / " <> tshow (length (wLevels w))))
            pure ()
        pure ()
      pure ()
    pure ()
    _ <- pure byId
    pure ()
 where
  tshow :: Show a => a -> Text
  tshow = T.pack . show
  curve x1 y1 x2 y2 = T.unwords
    [ "M", tshow x1, tshow (y1 + 26), "C", tshow x1, tshow (y1 + 70) <> ",", tshow x2, tshow (y2 - 70) <> ",", tshow x2, tshow (y2 - 26) ]

worldPage :: Widget' t m => Manifest -> Dynamic t Progress -> Dynamic t LangId -> WorldId -> m ()
worldPage m progress langDyn wid =
  case [ w | w <- mWorlds m, wId w == wid ] of
    [] -> el "p" (text "No such world.")
    (w : _) -> do
      elClass "div" "nav-row" $ routeLink RWorldMap (text "← World map")
      el "h1" (text (wTitle w))
      elClass "div" "card prose" $ rawHtml (wIntroHtml w)
      el "h2" (text "Levels")
      elClass "ol" "levels" $ forM_ (wLevels w) $ \l -> el "li" $ do
        elClass "span" "idx" (text (T.pack (show (lIndex l))))
        let lang = langDyn
            available = ffor lang $ \lg -> lg `M.member` lLanguages l
        dyn_ $ ffor ((,) <$> available <*> lang) $ \(ok, lg) ->
          if ok then routeLink (levelRoute wid l (Just lg)) (text (maybe (lTitle l) llTitle (M.lookup lg (lLanguages l))))
          else if lSkeleton l then elClass "span" "muted" (text (lTitle l <> " (planned)"))
          else elClass "span" "muted" (text (lTitle l))
        dyn_ $ ffor ((,) <$> progress <*> lang) $ \(p, lg) ->
          if levelDone p lg wid l then elClass "span" "done" (text "✓") else blank
        elClass "span" "langs" $ text (T.intercalate " · " (map unLangId (M.keys (lLanguages l))))
