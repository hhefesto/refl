-- | agda-mode's @\@ input method as a pure function over (text, cursor).
--
-- After a backslash, the characters typed so far form a sequence. When the
-- sequence is a key of the table and nothing longer starts with it, the
-- backslash and sequence are replaced immediately. When the sequence is a
-- key but longer keys exist (@to@ vs @top@), the replacement waits for the
-- next character that cannot extend it, which is then kept as typed.
module Widgets.InputMethod
  ( Table
  , mkTable
  , applyInput
  , pending
  , utf16ToCp
  , cpToUtf16
  ) where

import           Data.Char  (isSpace)
import qualified Data.Map   as M
import           Data.Maybe (isJust)
import           Data.Text  (Text)
import qualified Data.Text  as T

type Table = M.Map Text [Text]

mkTable :: [(Text, [Text])] -> Table
mkTable = M.fromList

-- | The @\sequence@ immediately before the cursor, if any (sequence may be empty).
pending :: Text -> Int -> Maybe (Int, Text)
pending t cur =
  let before = T.take cur t
      seqRev = T.takeWhile (\c -> not (isSpace c) && c /= '\\') (T.reverse before)
      s = T.reverse seqRev
      start = cur - T.length s - 1
  in if start >= 0 && T.index t start == '\\' then Just (start, s) else Nothing

-- | Longer keys that start with this sequence exist.
extendable :: Table -> Text -> Bool
extendable tbl s = case M.lookupGT s tbl of
  Just (k, _) -> s `T.isPrefixOf` k
  Nothing -> False

-- | Called after each input event with the current text and cursor (code
-- points). Returns the new text and cursor if a translation fires.
applyInput :: Table -> Text -> Int -> Maybe (Text, Int)
applyInput tbl t cur =
  case pending t cur of
    Just (start, s)
      | not (T.null s)
      , Just (v : _) <- M.lookup s tbl
      , not (extendable tbl s) -> Just (replaceRange start cur v t, start + T.length v)
    _ ->
      -- the character just typed may have terminated a complete sequence
      let justTyped = if cur > 0 then Just (T.index t (cur - 1)) else Nothing
      in case (justTyped, pending t (cur - 1)) of
           (Just c, Just (start, s))
             | not (T.null s)
             , Just (v : _) <- M.lookup s tbl
             , not (isJust (M.lookup (s `T.snoc` c) tbl) || extendable tbl (s `T.snoc` c)) ->
                 Just (replaceRange start (cur - 1) v t, start + T.length v + 1)
           _ -> Nothing
 where
  replaceRange a b new s = T.take a s <> new <> T.drop b s

-- | JS selection offsets are UTF-16 units; Text offsets are code points.
utf16ToCp :: Text -> Int -> Int
utf16ToCp t n = go 0 0 (T.unpack t)
 where
  go cp u (c : cs) | u < n = go (cp + 1) (u + width c) cs
  go cp _ _ = cp
  width c = if fromEnum c > 0xFFFF then 2 else 1

cpToUtf16 :: Text -> Int -> Int
cpToUtf16 t n = sum (map width (T.unpack (T.take n t)))
 where
  width c = if fromEnum c > 0xFFFF then 2 else 1
