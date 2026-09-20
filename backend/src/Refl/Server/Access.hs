-- | Dashboard access and the explicit peer trust boundary.
module Refl.Server.Access (dashboardAuth, onDashboard, readSecret, proxyHeaders) where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BC
import Data.Bits (xor, (.|.))
import Data.Char (isSpace)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Word (Word8)
import Network.HTTP.Types (status403, hContentType)
import Network.Wai
import Network.Wai.Middleware.HttpAuth (AuthSettings, basicAuth')
import Network.Wai.Middleware.RealIp (ipInRange, realIpTrusted)
import Text.Read (readMaybe)

-- | No implicit private-network trust, including loopback.
proxyHeaders :: [String] -> Either String Middleware
proxyHeaders peers = do
  ranges <- traverse (maybe (Left "invalid trusted-proxy CIDR") Right . readMaybe) peers
  pure (realIpTrusted "X-Real-IP" (\ip -> any (ipInRange ip) ranges))

readSecret :: FilePath -> IO BS.ByteString
readSecret path = do
  secret <- BC.takeWhile (\c -> c /= '\n' && c /= '\r') <$> BS.readFile path
  if blankSecret secret
    then fail "dashboard password must not be empty or whitespace-only"
    else pure secret

blankSecret :: BS.ByteString -> Bool
blankSecret secret = either (const (BC.all isSpace secret)) (T.all isSpace) (TE.decodeUtf8' secret)

onDashboard :: Request -> Bool
onDashboard req = case pathInfo req of
  "dashboard" : _ -> True
  _ -> False

-- | Authentication precedes identity allocation, redirects, static fallback
-- and API routing. Every outcome is private, including challenges and errors.
dashboardAuth :: Maybe BS.ByteString -> Middleware
dashboardAuth password inner req respond
  | not (onDashboard req) = inner req respond
  | otherwise = case password of
      Nothing -> privateRespond (responseLBS status403 [(hContentType, "text/plain")]
        "refl-server: the dashboard is off (no --dashboard-password-file).")
      Just pw -> basicAuth' (\_ u p -> pure (u == "refl" && not (blankSecret pw) && secretEq p pw))
        ("refl dashboard" :: AuthSettings) inner req privateRespond
 where
  privateRespond = respond . mapResponseHeaders (\hs -> ("Cache-Control", "private, no-store") : filter ((/= "Cache-Control") . fst) hs)

secretEq :: BS.ByteString -> BS.ByteString -> Bool
secretEq a b = BS.length a == BS.length b
  && foldr (.|.) 0 (BS.zipWith xor a b) == (0 :: Word8)
