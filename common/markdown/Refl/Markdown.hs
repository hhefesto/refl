{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}

-- | Markdown → sanitized HTML for level prose (introductions, hints,
-- conclusions, inventory docs).
--
-- Adapted from xpsoasis's @Xpsoasis.Markdown@: commonmark's parser is
-- polymorphic in the output type, so sanitization happens BY CONSTRUCTION
-- ('SafeHtml'): raw HTML nodes are re-emitted as escaped text and link/image
-- URLs are scheme-allowlisted. Level authors are trusted, but the same
-- renderer will later show player-authored notes, so the posture stays.
--
-- Code spans and fenced blocks are exactly what the game is about, so they are
-- passed through commonmark's own escaping untouched; a fence with an info
-- string (@```agda@) gets the class @language-agda@ as commonmark does.
module Refl.Markdown
  ( renderMarkdown
  , renderMarkdownOrText
  , sanitizeUrl
  ) where

import           Commonmark       (Html, IsBlock (..), IsInline (..),
                                   ParseError, commonmark, escapeHtml,
                                   renderHtml)
import           Commonmark.Types (HasAttributes (..), Rangeable (..))
import           Data.Char        (isAlpha, isAlphaNum, isSpace)
import           Data.Text        (Text)
import qualified Data.Text        as T
import qualified Data.Text.Lazy   as TL
import qualified Data.Text.Lazy.Builder as TB

-- | Render Markdown to sanitized HTML; @Left@ carries the parse error.
renderMarkdown :: Text -> Either Text Text
renderMarkdown src =
  case commonmark "level" src :: Either ParseError SafeHtml of
    Left err           -> Left (T.pack (show err))
    Right (SafeHtml h) -> Right (TL.toStrict (renderHtml h))

-- | Render, or fall back to the escaped source in a @<pre>@ if it does not parse.
renderMarkdownOrText :: Text -> Text
renderMarkdownOrText src = case renderMarkdown src of
  Right h -> h
  Left _  -> "<pre>" <> TL.toStrict (TB.toLazyText (escapeHtml src)) <> "</pre>"

newtype SafeHtml = SafeHtml (Html ())
  deriving newtype (Show, Semigroup, Monoid)

instance Rangeable SafeHtml where
  ranged sr (SafeHtml h) = SafeHtml (ranged sr h)

instance HasAttributes SafeHtml where
  addAttributes as (SafeHtml h) = SafeHtml (addAttributes as h)

instance IsInline SafeHtml where
  lineBreak                    = SafeHtml lineBreak
  softBreak                    = SafeHtml softBreak
  str t                        = SafeHtml (str t)
  entity t                     = SafeHtml (entity t)
  escapedChar c                = SafeHtml (escapedChar c)
  emph (SafeHtml h)            = SafeHtml (emph h)
  strong (SafeHtml h)          = SafeHtml (strong h)
  code t                       = SafeHtml (code t)
  link dst title (SafeHtml h)  = SafeHtml (link (sanitizeUrl dst) title h)
  image src title (SafeHtml h) = SafeHtml (image (sanitizeUrl src) title h)
  rawInline _ t                = SafeHtml (str t)

instance IsBlock SafeHtml SafeHtml where
  paragraph (SafeHtml h)            = SafeHtml (paragraph h)
  plain (SafeHtml h)                = SafeHtml (plain h)
  thematicBreak                     = SafeHtml thematicBreak
  blockQuote (SafeHtml h)           = SafeHtml (blockQuote h)
  codeBlock info t                  = SafeHtml (codeBlock info t)
  heading lvl (SafeHtml h)          = SafeHtml (heading lvl h)
  referenceLinkDefinition l dt      = SafeHtml (referenceLinkDefinition l dt)
  list lt ls items                  = SafeHtml (list lt ls [h | SafeHtml h <- items])
  rawBlock _ t                      = SafeHtml (paragraph (str t))

-- | Allow http, https, mailto and relative URLs; anything else becomes empty.
sanitizeUrl :: Text -> Text
sanitizeUrl raw
  | disallowed = ""
  | otherwise  = raw
  where
    cleaned    = T.filter (>= ' ') (T.dropWhile (\c -> isSpace c || c < ' ') raw)
    disallowed = case T.break (== ':') cleaned of
      (scheme, rest)
        | T.null rest          -> False
        | not (schemey scheme) -> False
        | otherwise            -> T.toLower scheme `notElem` allowed
    allowed = ["http", "https", "mailto"]
    schemey s = not (T.null s)
             && isAlpha (T.head s)
             && T.all (\c -> isAlphaNum c || c == '+' || c == '.' || c == '-') s
