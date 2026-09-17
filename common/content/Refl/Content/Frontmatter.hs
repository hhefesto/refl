-- | YAML front matter (@---@ … @---@) followed by a Markdown body.
module Refl.Content.Frontmatter
  ( splitFrontmatter
  , parseFrontmatter
  , readFileUtf8
  , writeFileUtf8
  ) where

import           Data.Aeson      (FromJSON)
import qualified Data.ByteString as BS
import           Data.Text       (Text)
import qualified Data.Text       as T
import qualified Data.Text.Encoding as TE
import qualified Data.Yaml       as Y

-- | Locale-independent UTF-8 file I/O (the nix sandbox has no UTF-8 locale).
readFileUtf8 :: FilePath -> IO Text
readFileUtf8 = fmap TE.decodeUtf8 . BS.readFile

writeFileUtf8 :: FilePath -> Text -> IO ()
writeFileUtf8 p = BS.writeFile p . TE.encodeUtf8

-- | Split a document into (yaml, body). A document without front matter is
-- all body with empty yaml.
splitFrontmatter :: Text -> (Text, Text)
splitFrontmatter doc =
  case T.lines doc of
    ("---" : rest) ->
      case break (== "---") rest of
        (yaml, _ : body) -> (T.unlines yaml, T.unlines body)
        _                -> ("", doc)
    _ -> ("", doc)

parseFrontmatter :: FromJSON a => Text -> Either Text (a, Text)
parseFrontmatter doc =
  let (yaml, body) = splitFrontmatter doc
      bytes = TE.encodeUtf8 (if T.null (T.strip yaml) then "{}" else yaml) :: BS.ByteString
  in case Y.decodeEither' bytes of
       Left err -> Left (T.pack (Y.prettyPrintParseException err))
       Right a  -> Right (a, body)
