-- | Client-side routes, encoded in the URL fragment so deep links work even
-- from a dumb static server. Pure codec, round-trip tested.
module Refl.Protocol.Route
  ( Route (..)
  , encodeRoute
  , decodeRoute
  , legacyTutorialLevel
  ) where

import           Data.Text           (Text)
import qualified Data.Text           as T
import           Text.Read           (readMaybe)

import           Refl.Protocol.Types

data Route
  = RWorldMap
  | RWorld WorldId
  | RLevel WorldId Int (Maybe LangId)
  | RLesson WorldId LevelId (Maybe LangId)
  | RInventory
  | RDonate
  deriving (Eq, Show)

-- | @#\/@, @#\/w\/<world>@, @#\/w\/<world>\/l\/<n>[\/<lang>]@, @#\/inventory@,
-- @#\/donate@.
encodeRoute :: Route -> Text
encodeRoute = \case
  RWorldMap                -> "#/"
  RWorld (WorldId w)       -> "#/w/" <> w
  RLevel (WorldId w) n ml  ->
    "#/w/" <> w <> "/l/" <> T.pack (show n)
      <> maybe "" (\(LangId l) -> "/" <> l) ml
  RLesson (WorldId w) (LevelId n) ml ->
    "#/w/" <> w <> "/level/" <> n
      <> maybe "" (\(LangId l) -> "/" <> l) ml
  RInventory               -> "#/inventory"
  RDonate                  -> "#/donate"

decodeRoute :: Text -> Maybe Route
decodeRoute frag =
  case filter (not . T.null) (T.splitOn "/" (T.dropWhile (== '#') frag)) of
    []                        -> Just RWorldMap
    ["w", w]                  -> Just (RWorld (WorldId w))
    ["w", w, "l", n]          -> RLevel (WorldId w) <$> readInt n <*> pure Nothing
    ["w", w, "l", n, l]       -> RLevel (WorldId w) <$> readInt n <*> pure (Just (LangId l))
    ["w", w, "level", n]      -> Just (RLesson (WorldId w) (LevelId n) Nothing)
    ["w", w, "level", n, l]   -> Just (RLesson (WorldId w) (LevelId n) (Just (LangId l)))
    ["inventory"]             -> Just RInventory
    ["donate"]                -> Just RDonate
    _                         -> Nothing
 where
  readInt = readMaybe . T.unpack

-- | Published Tutorial URLs used these indices before the introductory lesson
-- was inserted. Keep their meaning; new links use stable level identifiers.
legacyTutorialLevel :: Int -> Maybe LevelId
legacyTutorialLevel n = lookup n (zip [1..]
  (map LevelId ["refl", "variable", "cong", "rewrite", "refine", "induction", "sym-trans", "reading-analog"]))
