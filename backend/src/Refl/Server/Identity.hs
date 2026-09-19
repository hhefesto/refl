-- | A browser owns an unguessable bearer identity carried in a host-only,
-- HttpOnly, SameSite=Strict cookie. Progress keys remain language/lesson keys.
--
-- Browsers store @Secure@ (and therefore @__Host-@) cookies only for https
-- origins and for loopback hosts, so the cookie's name and flags follow the
-- configured origin: a plain @http://@ origin on a public address gets a
-- non-Secure cookie called @refl@ instead of @__Host-refl@.
module Refl.Server.Identity
  ( CookiePolicy (..), cookiePolicy
  , identity, newIdentity, identityCookie, validOrigin
  ) where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BC
import Data.List (isPrefixOf)
import Network.HTTP.Types (RequestHeaders)
import Numeric (showHex)
import System.IO (withBinaryFile, IOMode(ReadMode))

data CookiePolicy = CookiePolicy
  { cpName   :: BS.ByteString
  , cpSecure :: Bool
  } deriving (Eq, Show)

-- | The policy for the exact browser origin the server is configured with.
cookiePolicy :: String -> CookiePolicy
cookiePolicy origin
  | "https://" `isPrefixOf` origin || loopback = CookiePolicy "__Host-refl" True
  | otherwise = CookiePolicy "refl" False
 where
  authority = drop (length ("http://" :: String)) origin
  host = case authority of
    '[' : rest -> takeWhile (/= ']') rest
    _ -> takeWhile (\c -> c /= ':' && c /= '/') authority
  loopback = host `elem` ["127.0.0.1", "::1", "localhost"]

identity :: CookiePolicy -> RequestHeaders -> Maybe BS.ByteString
identity policy headers = do
  cookies <- lookup "Cookie" headers
  let values = [ BS.drop 1 rest | item <- BC.split ';' cookies
               , let (name, rest) = BC.break (== '=') (BC.dropWhile (== ' ') item)
               , name == cpName policy, not (BS.null rest) ]
  case values of
    [value] | BS.length value == 64 && BC.all (`elem` ("0123456789abcdef" :: String)) value -> Just value
    _ -> Nothing

newIdentity :: IO BS.ByteString
newIdentity = withBinaryFile "/dev/urandom" ReadMode $ \h -> do
  bytes <- BS.hGet h 32
  if BS.length bytes /= 32 then fail "identity entropy unavailable" else
    pure (BC.pack (concatMap (\b -> let s = showHex b "" in replicate (2 - length s) '0' ++ s) (BS.unpack bytes)))

identityCookie :: CookiePolicy -> BS.ByteString -> BS.ByteString
identityCookie policy value =
  cpName policy <> "=" <> value <> "; Path=/;" <> (if cpSecure policy then " Secure;" else "")
    <> " HttpOnly; SameSite=Strict; Max-Age=31536000"

-- Origin is an exact configured origin, never a client-supplied Host or proxy header.
validOrigin :: BS.ByteString -> RequestHeaders -> Bool
validOrigin expected headers = [v | (k,v) <- headers, k == "Origin"] == [expected]
