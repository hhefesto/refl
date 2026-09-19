-- | A browser owns an unguessable bearer identity. The host-only cookie is
-- HttpOnly, Secure and SameSite=Strict. Progress keys remain language/lesson keys.
module Refl.Server.Identity (identity, newIdentity, identityCookie, validOrigin) where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BC
import Network.HTTP.Types (RequestHeaders)
import Numeric (showHex)
import System.IO (withBinaryFile, IOMode(ReadMode))

cookieName :: BS.ByteString
cookieName = "__Host-refl"

identity :: RequestHeaders -> Maybe BS.ByteString
identity headers = do
  cookies <- lookup "Cookie" headers
  let values = [ BS.drop 1 rest | item <- BC.split ';' cookies
               , let (name, rest) = BC.break (== '=') (BC.dropWhile (== ' ') item)
               , name == cookieName, not (BS.null rest) ]
  case values of
    [value] | BS.length value == 64 && BC.all (`elem` ("0123456789abcdef" :: String)) value -> Just value
    _ -> Nothing

newIdentity :: IO BS.ByteString
newIdentity = withBinaryFile "/dev/urandom" ReadMode $ \h -> do
  bytes <- BS.hGet h 32
  if BS.length bytes /= 32 then fail "identity entropy unavailable" else
    pure (BC.pack (concatMap (\b -> let s = showHex b "" in replicate (2 - length s) '0' ++ s) (BS.unpack bytes)))

identityCookie :: BS.ByteString -> BS.ByteString
identityCookie value = cookieName <> "=" <> value <> "; Path=/; Secure; HttpOnly; SameSite=Strict; Max-Age=31536000"

-- Origin is an exact configured origin, never a client-supplied Host or proxy header.
validOrigin :: BS.ByteString -> RequestHeaders -> Bool
validOrigin expected headers = [v | (k,v) <- headers, k == "Origin"] == [expected]
