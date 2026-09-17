-- | Client-side routes, encoded in the URL fragment so deep links work even
-- from a dumb static server. Pure codec, round-trip tested.
module Refl.Protocol.Route
  ( Route (..)
  , encodeRoute
  , decodeRoute
  ) where

import           Data.Text           (Text)
import qualified Data.Text           as T
import           Text.Read           (readMaybe)

import           Refl.Protocol.Types

data Route
  = RWorldMap
  | RWorld WorldId
  | RLevel WorldId Int (Maybe LangId)
  | RInventory
  deriving (Eq, Show)

-- | @#/@, @#/w/<world>@, @#/w/<world>/l/<n>[/<lang>]@, @#/inventory@.
encodeRoute :: Route -> Text
encodeRoute = \case
  RWorldMap                -> "#/"
  RWorld (WorldId w)       -> "#/w/" <> w
  RLevel (WorldId w) n ml  ->
    "#/w/" <> w <> "/l/" <> T.pack (show n)
      <> maybe "" (\(LangId l) -> "/" <> l) ml
  RInventory               -> "#/inventory"

decodeRoute :: Text -> Maybe Route
decodeRoute frag =
  case filter (not . T.null) (T.splitOn "/" (T.dropWhile (== '#') frag)) of
    []                        -> Just RWorldMap
    ["w", w]                  -> Just (RWorld (WorldId w))
    ["w", w, "l", n]          -> RLevel (WorldId w) <$> readInt n <*> pure Nothing
    ["w", w, "l", n, l]       -> RLevel (WorldId w) <$> readInt n <*> pure (Just (LangId l))
    ["inventory"]             -> Just RInventory
    _                         -> Nothing
 where
  readInt = readMaybe . T.unpack
