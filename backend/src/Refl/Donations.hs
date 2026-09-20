-- | Checking @donations.json@. A mistyped address silently sends money
-- nowhere, so the file is not trusted: every entry declares the checksum it
-- must satisfy ('cnKind') and CI re-derives it.
--
-- The checksums are written out here rather than taken from a library
-- because @bech32@ and @keccak@ are both marked broken in the pinned
-- nixpkgs, and because none of this needs hashing: bech32/bech32m is a
-- 30-bit polymod, Solana is base58 length, and the Ethereum address is
-- all-lowercase, which makes EIP-55 vacuous on it.
module Refl.Donations
  ( Bech32Variant (..)
  , bech32Decode
  , base58Decode
  , checkChain
  , checkDonations
  ) where

import           Data.Bits    (shiftL, shiftR, testBit, xor, (.&.))
import           Data.Char    (isDigit, ord)
import           Data.List    (foldl')
import qualified Data.Map     as M
import           Data.Text    (Text)
import qualified Data.Text    as T
import           Data.Word    (Word32, Word8)

import           Refl.Protocol.Donate

data Bech32Variant = Bech32 | Bech32m deriving (Eq, Show)

-- ---------------------------------------------------------------------------
-- bech32 (BIP-173) and bech32m (BIP-350)
-- ---------------------------------------------------------------------------

charset :: String
charset = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"

polymod :: [Word8] -> Word32
polymod = foldl' step 1
 where
  gen = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3] :: [Word32]
  step chk v =
    let b = chk `shiftR` 25
        chk' = ((chk .&. 0x1ffffff) `shiftL` 5) `xor` fromIntegral v
    in foldl' (\acc (i, g) -> if testBit b i then acc `xor` g else acc) chk' (zip [0 :: Int ..] gen)

hrpExpand :: String -> [Word8]
hrpExpand s =
  [fromIntegral (ord c `shiftR` 5) | c <- s] ++ [0] ++ [fromIntegral (ord c .&. 31) | c <- s]

-- | The human-readable part and the variant, or why it is not an address.
-- Case is all-or-nothing and the separator is the /last/ @1@, both per BIP-173.
bech32Decode :: Text -> Either String (Text, Bech32Variant)
bech32Decode addr
  | T.null addr = Left "empty"
  | T.any (\c -> c < '!' || c > '~') addr = Left "character outside printable ASCII"
  | T.toLower addr /= addr && T.toUpper addr /= addr = Left "mixed case"
  | T.null before = Left "no separator"
  | T.null hrp = Left "empty human-readable part"
  | T.length body < 6 = Left "checksum too short"
  | not (null bad) = Left ("character outside the bech32 charset: " ++ bad)
  | chk == 1 = Right (hrp, Bech32)
  | chk == 0x2bc830a3 = Right (hrp, Bech32m)
  | otherwise = Left "checksum does not verify"
 where
  low = T.toLower addr
  (before, body) = T.breakOnEnd "1" low
  hrp = if T.null before then "" else T.init before
  bad = [c | c <- T.unpack body, c `notElem` charset]
  values = [fromIntegral i | c <- T.unpack body
                           , Just i <- [lookup c (zip charset [0 :: Int ..])]]
  chk = polymod (hrpExpand (T.unpack hrp) ++ values)

-- ---------------------------------------------------------------------------
-- base58 (Bitcoin alphabet, as Solana uses it)
-- ---------------------------------------------------------------------------

b58Alphabet :: String
b58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

-- | The decoded bytes. Leading @1@s are leading zero bytes, as usual.
--
-- Note what this cannot do: base58 is not base58check, and a Solana address
-- is a raw ed25519 public key, so there is no checksum to verify — only the
-- length. A single mistyped character still decodes to 32 bytes. What
-- actually guards Solana here is that the address is written twice, in
-- 'cnAddress' and at the end of 'cnUri', and 'checkChain' requires them to
-- agree.
base58Decode :: Text -> Either String [Word8]
base58Decode t
  | T.null t = Left "empty"
  | not (null bad) = Left ("character outside the base58 alphabet: " ++ bad)
  | otherwise = Right (replicate pad 0 ++ unroll n)
 where
  s = T.unpack t
  bad = [c | c <- s, c `notElem` b58Alphabet]
  n = foldl' (\acc c -> acc * 58 + maybe 0 toInteger (lookup c (zip b58Alphabet [0 :: Int ..]))) 0 s
  pad = length (takeWhile (== '1') s)
  unroll 0 = []
  unroll k = go k []
   where go 0 acc = acc
         go m acc = go (m `div` 256) (fromIntegral (m `mod` 256) : acc)

-- ---------------------------------------------------------------------------
-- The file's own contract
-- ---------------------------------------------------------------------------

-- | Every problem with one chain entry, empty when it is sound. The kind is
-- @bech32:\<hrp\>@, @bech32m:\<hrp\>@, @base58-32@ or @hex20@.
checkChain :: Chain -> [String]
checkChain c = concat [idOk, tokensOk, uriOk, addressOk]
 where
  name = T.unpack (cnId c)
  -- cnId is interpolated into a shell path by the QR derivation
  idOk = [ name ++ ": id must match [a-z][a-z0-9-]*"
         | not (matchesSlug (T.unpack (cnId c))) ]
  tokensOk = [ name ++ ": no tokens listed" | null (cnTokens c) ]
  uriOk = [ name ++ ": the wallet URI does not end in the address"
          | Just u <- [cnUri c], not (cnAddress c `T.isSuffixOf` u) ]
  addressOk = case T.splitOn ":" (cnKind c) of
    ["bech32", hrp]  -> bech32 Bech32 hrp
    ["bech32m", hrp] -> bech32 Bech32m hrp
    ["base58-32"] -> case base58Decode (cnAddress c) of
      Left e -> [name ++ ": " ++ e]
      Right bs | length bs == 32 -> []
               | otherwise -> [name ++ ": base58 decodes to " ++ show (length bs) ++ " bytes, expected 32"]
    ["hex20"] ->
      let a = cnAddress c
          rest = T.drop 2 a
      in [ name ++ ": expected 0x followed by 40 lowercase hex digits"
         | not (T.isPrefixOf "0x" a) || T.length rest /= 40
           || not (T.all (\x -> isDigit x || (x >= 'a' && x <= 'f')) rest) ]
    _ -> [name ++ ": unknown kind " ++ T.unpack (cnKind c)]
  bech32 want hrp = case bech32Decode (cnAddress c) of
    Left e -> [name ++ ": " ++ e]
    Right (gotHrp, gotVariant) -> concat
      [ [ name ++ ": expected " ++ show want ++ ", got " ++ show gotVariant | gotVariant /= want ]
      , [ name ++ ": expected the prefix " ++ T.unpack hrp ++ ", got " ++ T.unpack gotHrp | gotHrp /= hrp ]
      ]
  matchesSlug (x : xs) = x >= 'a' && x <= 'z'
    && all (\y -> (y >= 'a' && y <= 'z') || isDigit y || y == '-') xs
  matchesSlug [] = False

-- | Every problem with the file. Empty means the addresses are shippable.
checkDonations :: Donations -> [String]
checkDonations d = duplicates ++ concatMap checkChain (dnChains d)
 where
  duplicates =
    [ "duplicate id " ++ T.unpack i ++ " (the QR codes would overwrite each other)"
    | (i, n) <- M.toList (M.fromListWith (+) [(cnId c, 1 :: Int) | c <- dnChains d]), n > 1 ]
