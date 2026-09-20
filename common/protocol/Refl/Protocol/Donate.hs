-- | Where donations go. The wire type for @donations.json@, which is the one
-- source of truth: the website derivation reads the same file to generate the
-- QR codes, and a spec re-verifies every address's checksum, so an address
-- exists exactly once and a typo cannot ship.
module Refl.Protocol.Donate where

import           Data.Aeson   (FromJSON, ToJSON)
import           Data.Text    (Text)
import           GHC.Generics (Generic)

-- | One chain, with the assets it accepts. Grouping by chain is what keeps an
-- address from being printed twice: USDC rides on three of these.
data Chain = Chain
  { cnId      :: Text          -- ^ slug; also the QR file name under @/qr@
  , cnName    :: Text
  , cnTokens  :: [Text]        -- ^ what may be sent to this address
  , cnAddress :: Text
  , cnUri     :: Maybe Text    -- ^ wallet URI, where the chain has a scheme
  , cnKind    :: Text          -- ^ the checksum the address must satisfy
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data Donations = Donations
  { dnIntro  :: Text
  , dnChains :: [Chain]
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)
