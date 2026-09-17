-- | Small shared widgets.
module Widgets.Common
  ( rawHtml
  , rawHtmlDyn
  , routeLink
  , routeLinkClass
  , verdictClass
  , verdictText
  , levelRoute
  , cssClasses
  , Widget'
  ) where

import           Data.Text       (Text)
import qualified Data.Text       as T
import           Reflex.Dom.Core

import           Refl.Protocol

-- | Every page widget's constraint set (mirrors xpsoasis Router.PageM).
type Widget' t m = (MonadWidget t m)

-- | Inject pre-rendered (sanitized) HTML.
rawHtml :: Widget' t m => Text -> m ()
rawHtml h = () <$ elDynHtml' "div" (constDyn h)

rawHtmlDyn :: Widget' t m => Dynamic t Text -> m ()
rawHtmlDyn h = () <$ elDynHtml' "div" h

routeLink :: DomBuilder t m => Route -> m a -> m a
routeLink r = elAttr "a" ("href" =: encodeRoute r)

routeLinkClass :: DomBuilder t m => Text -> Route -> m a -> m a
routeLinkClass cls r = elAttr "a" ("href" =: encodeRoute r <> "class" =: cls)

verdictClass :: Verdict -> Text
verdictClass = \case
  Solved -> "solved"
  Unsolved _ -> "unsolved"
  Rejected _ -> "rejected"
  Failed -> "failed"

verdictText :: Verdict -> Text
verdictText = \case
  Solved -> "Solved"
  Unsolved n -> T.pack (show n) <> (if n == 1 then " goal remaining" else " goals remaining")
  Rejected _ -> "Rejected"
  Failed -> "Errors"

levelRoute :: WorldId -> Level -> Maybe LangId -> Route
levelRoute w l = RLevel w (lIndex l)

cssClasses :: [Text] -> Text
cssClasses = T.unwords . filter (not . T.null)
