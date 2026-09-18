-- | What the player has unlocked: commands, lemmas and syntax, with docs.
module Widgets.Inventory
  ( inventoryPage
  , unlockedItems
  , unlockedCommands
  ) where

import           Control.Monad   (forM_)
import qualified Data.Map        as M
import qualified Data.Set        as S
import           Data.Text       (Text)
import           Reflex.Dom.Core

import           Refl.Protocol
import           Refl.Protocol.Graph (transitiveDeps)
import           Widgets.Common

-- | Items available at a level: unlocks of levels with index ≤ this one in the
-- same world, plus every level of the worlds it transitively depends on.
unlockedItems :: Manifest -> WorldId -> Int -> [InventoryItem]
unlockedItems m wid idx = concat
  [ lUnlocks l
  | w <- mWorlds m
  , wId w `S.member` S.insert wid depWorlds
  , l <- wLevels w
  , wId w /= wid || lIndex l <= idx ]
 where
  deps = M.fromList [ (wId w, wDeps w) | w <- mWorlds m ]
  depWorlds = transitiveDeps deps wid

unlockedCommands :: Manifest -> WorldId -> Int -> [CommandId]
unlockedCommands m wid idx = [ c | i <- unlockedItems m wid idx, Just c <- [iiCommand i] ]

inventoryPage :: Widget' t m => Manifest -> Dynamic t Progress -> Dynamic t LangId -> m ()
inventoryPage m progress langDyn = do
  elClass "div" "nav-row" $ routeLink RWorldMap (text "← World map")
  el "h1" (text "Inventory")
  el "p" $ elClass "span" "muted" (text "Everything unlocked by the levels you have completed, in the order you met it.")
  elClass "div" "inventory" $ dyn_ $ ffor ((,) <$> progress <*> langDyn) $ \(p, lang) -> do
    let doneKeys = S.fromList (M.findWithDefault [] lang (prCompleted p))
        items = [ (w, l, i) | w <- mWorlds m, l <- wLevels w, levelKey (wId w) (lId l) `S.member` doneKeys, i <- lUnlocks l
                , M.member lang (iiDocHtml i), maybe True (`elem` supportedCommands lang) (iiCommand i) ]
    if null items then el "p" (text "Nothing yet. Solve the first level!") else
      forM_ [minBound .. maxBound] $ \kind -> do
        let here = [ x | x@(_, _, i) <- items, iiKind i == kind ]
        if null here then blank else do
          el "h2" (text (kindTitle kind))
          forM_ here $ \(w, l, i) -> elClass "div" "item" $ el "details" $ do
            el "summary" $ do
              elClass "code" "mono" (text (displayName lang i))
              elClass "span" "pill" (text (wTitle w <> " · " <> maybe (lTitle l) llTitle (M.lookup lang (lLanguages l))))
            elClass "div" "prose" $ rawHtml (M.findWithDefault "" lang (iiDocHtml i))
 where
  kindTitle = \case
    ItemCommand -> "Commands"
    ItemLemma -> "Lemmas"
    ItemSyntax -> "Syntax"

displayName :: LangId -> InventoryItem -> Text
displayName lang i = M.findWithDefault (iiName i) lang (iiLangNames i)
