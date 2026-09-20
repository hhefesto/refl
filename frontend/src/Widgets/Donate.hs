-- | The support page. Deliberately not dressed as a level: this is the one
-- page meant to stop a reader, so it gets its own type scale, a hero, and a
-- decorative proof path whose last rung is left open — the game's own idiom
-- for "this step is yours".
--
-- The addresses are never written here. They come from @donations.json@, the
-- same file the website derivation reads to generate the QR codes and the
-- spec reads to re-verify every checksum.
module Widgets.Donate (donatePage) where

import           Control.Monad               (forM_, void)
import           Data.Text                   (Text)
import qualified Data.Text                   as T
import           Language.Javascript.JSaddle (eval, liftJSM)
import           Reflex.Dom.Core

import           Client                      (backendBase, fetchDonations)
import           Refl.Protocol
import           Widgets.Common              (Widget')

svgNS :: Maybe Text
svgNS = Just "http://www.w3.org/2000/svg"

tshow :: Show a => a -> Text
tshow = T.pack . show

donatePage :: Widget' t m => m ()
donatePage = elClass "div" "donate" $ do
  base <- backendBase
  pb <- getPostBuild
  loaded <- fetchDonations pb
  dDyn <- holdDyn Nothing loaded
  elClass "section" "donate-hero" $ do
    elClass "div" "hero-text" $ do
      el "h1" $ do
        text "Every step is free."
        el "br" blank
        elClass "span" "accented" (text "The last one is yours.")
      elClass "p" "lede" $ dynText (maybe placeholder dnIntro <$> dDyn)
    heroMotif
  elClass "div" "chains" $ dyn_ $ ffor dDyn $ \case
    Nothing -> forM_ [0 .. 4 :: Int] placeholderCard
    Just d  -> forM_ (zip [0 ..] (dnChains d)) (chainCard base)
  elClass "p" "donate-note" $ do
    text "Send only assets on the network named on the card. "
    text "Anything sent on another chain is unrecoverable."
 where
  placeholder = "The Refl Game is free and runs real proof assistants for anyone who opens it."

placeholderCard :: Widget' t m => Int -> m ()
placeholderCard i =
  elAttr "article" ("class" =: "chain loading" <> "style" =: ("--i:" <> tshow i)) blank

chainCard :: Widget' t m => Text -> (Int, Chain) -> m ()
chainCard base (i, c) =
  elAttr "article" ("class" =: "chain" <> "style" =: ("--i:" <> tshow i)) $ do
    elClass "header" "chain-head" $ do
      el "h2" (text (cnName c))
      elClass "div" "tokens" $ forM_ (cnTokens c) $ \t ->
        elClass "span" "token" (text t)
    elClass "div" "qr" $ elAttr "img"
      (  "src" =: (base <> "/qr/" <> cnId c <> ".svg")
      <> "alt" =: ("QR code of the " <> cnName c <> " address")
      <> "width" =: "200" <> "height" =: "200"
      <> "loading" =: "lazy") blank
    elClass "div" "addr" $ do
      elClass "code" "mono" (text (cnAddress c))
      copyButton (cnName c) (cnAddress c)
    elClass "div" "chain-foot" $
      forM_ (cnUri c) $ \u ->
        elAttr "a" ("class" =: "wallet" <> "href" =: u) (text "Open in a wallet →")

-- | Copy to the clipboard, and say so. Clipboard access can be refused
-- (insecure origin, permission), so the label only promises what happened
-- after the call did not throw; the address stays selectable either way.
copyButton :: Widget' t m => Text -> Text -> m ()
copyButton name addr = mdo
  (b, _) <- elDynAttr' "button"
    (ffor label $ \l ->
        "type" =: "button"
        <> "class" =: (if l == copied then "copy done" else "copy")
        <> "aria-label" =: ("Copy the " <> name <> " address"))
    (dynText label)
  let clicked = domEvent Click b
  performEvent_ $ ffor clicked $ \_ -> liftJSM $ void $ eval
    ("try { navigator.clipboard.writeText(" <> jsString addr <> "); } catch (_) {}" :: Text)
  back <- delay 1.4 clicked
  label <- holdDyn "Copy" (leftmost [copied <$ clicked, "Copy" <$ back])
  pure ()
 where
  copied = "Copied" :: Text
  -- the addresses are base58/bech32/hex, but quote them properly anyway
  jsString = T.pack . show

-- | A computational path with the final rung unresolved: five nodes, four
-- curves, the last one dashed and open. Decoration only.
heroMotif :: Widget' t m => m ()
heroMotif = elAttr "div" ("class" =: "hero-motif" <> "aria-hidden" =: "true") $ do
  _ <- elDynAttrNS' svgNS "svg" (constDyn
        ("viewBox" =: "14 22 392 126" <> "xmlns" =: "http://www.w3.org/2000/svg")) $ do
    forM_ (zip3 [0 :: Int ..] xs (drop 1 xs)) $ \(k, a, b) -> do
      let cls = if k == length xs - 2 then "rung open" else "rung"
      _ <- elDynAttrNS' svgNS "path"
        (constDyn ("class" =: cls <> "d" =: curve k a b)) blank
      pure ()
    forM_ (zip [0 :: Int ..] xs) $ \(k, x) -> do
      let lastOne = k == length xs - 1
      _ <- elDynAttrNS' svgNS "circle"
        (constDyn ("class" =: (if lastOne then "node last" else "node")
                   <> "cx" =: tshow x <> "cy" =: "85"
                   <> "r" =: (if lastOne then "13" else "7"))) blank
      pure ()
    pure ()
  pure ()
 where
  xs = [34, 128, 222, 312, 386] :: [Int]
  -- alternate the bulge so the chain reads as a walk, not a wire
  curve k a b =
    let d = if even k then (-34) else 34 :: Int
    in T.unwords [ "M", tshow a, "85", "C"
                 , tshow (a + 32), tshow (85 + d) <> ","
                 , tshow (b - 32), tshow (85 - d) <> ","
                 , tshow b, "85" ]
