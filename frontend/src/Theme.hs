-- | Storage is optional. Absence, invalid values and access errors mean Dark.
module Theme (Theme (..), themeToggle) where

import Control.Monad (void)
import Data.Text (Text)
import Language.Javascript.JSaddle (eval, fromJSVal, liftJSM)
import Reflex.Dom.Core

data Theme = Dark | Light deriving (Eq, Show)

themeToggle :: MonadWidget t m => m ()
themeToggle = mdo
  pb <- getPostBuild
  restored <- performEvent $ ffor pb $ \_ -> liftJSM $ do
    v <- eval ("(() => { try { return localStorage.getItem('refl-theme') === 'light'; } catch (_) { return false; } })()" :: Text)
    light <- fromJSVal v
    pure (if light == Just True then Light else Dark)
  theme <- holdDyn Dark (leftmost [restored, toggle <$> tag (current theme) clicked])
  performEvent_ $ ffor (updated theme) $ \t -> liftJSM $ void $ eval
    ("document.documentElement.dataset.theme='" <> name t <> "'; try { localStorage.setItem('refl-theme','" <> name t <> "'); } catch (_) {}" :: Text)
  (b, _) <- elDynAttr' "button" (ffor theme $ \t ->
    "id" =: "theme-toggle" <> "type" =: "button"
    <> "aria-label" =: (if t == Dark then "Switch to the light theme" else "Switch to the dark theme")
    <> "aria-pressed" =: (if t == Dark then "true" else "false"))
    (dynText ((\t -> if t == Dark then "Theme: Dark" else "Theme: Light") <$> theme))
  let clicked = domEvent Click b
  pure ()
 where
  toggle Dark = Light
  toggle Light = Dark
  name Dark = "dark"
  name Light = "light"
