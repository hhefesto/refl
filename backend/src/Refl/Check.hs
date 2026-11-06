-- | Content CI: every level × language must (a) accept its model solution as
-- Solved and (b) leave its template Unsolved with no errors. Also generates
-- the per-world Agda support modules from the level sources.
module Refl.Check
  ( Outcome (..)
  , checkGame
  , emitWorldModules
  , emitLeanWorldModules
  , emitBendWorldModules
  , worldModuleName
  , renderWorldModule
  , exampleProblems
  ) where

import           Control.Exception      (SomeException, try)
import           Control.Monad          (forM)
import           Data.Char              (toUpper)
import           Data.List              (nub)
import qualified Data.Map               as M
import           Data.Text              (Text)
import qualified Data.Text              as T
import           System.Directory       (createDirectoryIfMissing)
import           System.FilePath        (takeDirectory, (</>))

import           Refl.Content
import           Refl.Content.Splice (forbiddenIdentifiers)
import           Refl.Content.Frontmatter     (writeFileUtf8)
import           Refl.Language
import           Refl.Language.Registry
import           Refl.Protocol.Types
import           Refl.Server                 (restrictedSources)

data Outcome = Outcome
  { oWorld :: Text
  , oLevel :: Text
  , oLang  :: Text
  , oOk    :: Bool
  , oNotes :: [Text]
  } deriving (Show)

checkGame :: Env -> Maybe LangId -> [LangId] -> LoadedGame -> IO [Outcome]
checkGame env only skip game
  | not (null problems) = pure [Outcome "content" "teaching" "all" False problems]
  | otherwise = fmap concat . forM (lgWorlds game) $ \w ->
      fmap concat . forM (lwLevels w) $ \l ->
        fmap concat $ forM [ s | (lang, s) <- M.toList (llSources l), maybe True (== lang) only, lang `notElem` skip ] $ \src -> do
          exercise <- checkLevel True env (wmId (lwMeta w)) (lmId (llMeta l)) (restrictedSources game src)
          -- a worked example is a solved level in its own right: its solution
          -- must check with the same earned vocabulary
          examples <- forM [ e | Just t <- [M.lookup (lsLang src) (llTeaching l)], Just e <- [tExample t] ] $ \e ->
            let effective = restrictedSources game e
                errors = exampleProblems src effective
                label = lmId (llMeta l) <> " / worked example"
            in if null errors then checkLevel False env (wmId (lwMeta w)) label effective
               else pure (Outcome (wmId (lwMeta w)) label (unLangId (lsLang e)) False errors)
          pure (exercise : examples)
 where
  problems = teachingProblems languageInfos game

-- | Examples have a different statement, but no extra imports, compiler
-- privileges or unearned vocabulary hidden in their fixed regions.
exampleProblems :: LevelSources -> LevelSources -> [Text]
exampleProblems exercise example =
  map vMessage (forbiddenIdentifiers comment (lsForbidsNames example) complete)
  ++ ["worked example adds a privileged directive: " <> line
     | line <- directives (lsPrefix example), line `notElem` directives (lsPrefix exercise)]
  ++ case lookupLanguage (lsLang example) of
    Nothing -> ["unknown example language"]
    Just lang -> map vMessage (langStaticRules lang example checked)
 where
  comment = languageComment (lsLang example)
  complete = lsPrefix example <> lsSolution example
  directives = filter privileged . map T.strip . T.lines
  privileged line = any (`T.isPrefixOf` line)
    ["import ", "open import ", "{-# OPTIONS", "{-# BUILTIN"]
  -- Trusted directives are compared verbatim above. Lean's indentation law
  -- applies to the proof, not the example's theorem declaration.
  body = T.unlines (filter (not . privileged . T.strip) (T.lines complete))
  checked | lsLang example == LangId "lean" = T.unlines (map ("  " <>) (T.lines body))
          | otherwise = body

checkLevel :: Bool -> Env -> Text -> Text -> LevelSources -> IO Outcome
checkLevel exercise env world level src = do
  let lang = lsLang src
      out ok notes = Outcome world level (unLangId lang) ok notes
  case lookupLanguage lang of
    Nothing -> pure (out False ["unknown language"])
    Just l | not (liAvailable (langInfo l)) -> pure (out True ["skipped: language unavailable"])
    Just l -> do
      r <- try (langStart l env src)
      case r of
        Left (e :: SomeException) -> pure (out False ["could not start prover: " <> T.pack (show e)])
        Right (Left e) -> pure (out False ["could not start prover: " <> e])
        Right (Right prover) -> do
          sol <- psCheck prover (lsSolution src)
          tpl <- if exercise then psCheck prover (lsTemplate src) else pure sol
          psClose prover
          let solNotes = case crVerdict sol of
                Solved -> []
                v -> ["solution is not Solved: " <> T.pack (show v) <> "; " <> crStatus sol]
                     ++ map diagMessage (crDiagnostics sol)
              tplNotes = case crVerdict tpl of
                Unsolved n | n > 0 -> []
                Solved -> ["template is already solved"]
                v -> ["template does not load cleanly: " <> T.pack (show v) <> "; " <> crStatus tpl]
                     ++ map diagMessage (crDiagnostics tpl)
              notes = solNotes ++ (if exercise then tplNotes else [])
          pure (out (null notes) notes)

-- ---------------------------------------------------------------------------
-- World support modules
-- ---------------------------------------------------------------------------

-- | @tutorial@ → @Tutorial@, @multiplication-power@ → @MultiplicationPower@.
worldModuleName :: Text -> Text
worldModuleName = T.concat . map cap . T.splitOn "-"
 where
  cap t = case T.unpack t of
    [] -> ""
    (c : cs) -> T.pack (toUpper c : cs)

-- | The statements and model solutions of a world's levels in one language.
worldSources :: LangId -> LoadedWorld -> [(LoadedLevel, LevelSources)]
worldSources lang w = [ (l, s) | l <- lwLevels w, Just s <- [M.lookup lang (llSources l)] ]

-- | The prelude lines of those levels that a world module needs too: everything
-- but what the predicate rules out, and each line once.
preludeLines :: (Text -> Bool) -> [(LoadedLevel, LevelSources)] -> [Text]
preludeLines keep srcs = nub
  [ line
  | (_, s) <- srcs
  , line <- T.lines (T.take (T.length (lsPrefix s) - T.length (lsStatement s)) (lsPrefix s))
  , not (T.null (T.strip line))
  , keep (T.strip line)
  ]

-- | One module per world with an Agda source: the union of the levels'
-- prelude lines (minus OPTIONS, module headers and self-imports) followed by
-- every statement and model solution, so later levels can @open import@ them.
renderWorldModule :: LoadedWorld -> Maybe Text
renderWorldModule w
  | null srcs = Nothing
  | otherwise = Just $ T.unlines $
      [ "{-# OPTIONS " <> T.unwords opts <> " #-}"
      , "-- Generated by refl-check-levels --emit-world-modules; do not edit."
      , "module Refl.World." <> modName <> " where"
      , "" ]
      ++ imports
      ++ concat
        [ [ "", "-- " <> lmTitle (llMeta l), lsStatement s, lsSolution s ]
        | (l, s) <- srcs ]
 where
  modName = worldModuleName (wmId (lwMeta w))
  opts = case M.lookup "agda" (wmOptions (lwMeta w)) of
    Just os | not (null os) -> os
    _ -> ["--safe", "--without-K"]
  srcs = worldSources (LangId "agda") w
  imports = preludeLines keep srcs
  keep line = not ("{-#" `T.isPrefixOf` line)
    && not ("module " `T.isPrefixOf` line)
    && not (("Refl.World." <> modName) `T.isInfixOf` line)

-- | The same for Lean. A Lean import brings in every name a module has, so a
-- level importing its own world would clash with its own theorem. Hence the
-- namespace: a level says @open Refl.World.Addition (add_comm)@, which is
-- Agda's @using@. Imports have to come first in a file, whatever the order of
-- the levels' preludes.
renderLeanWorldModule :: LoadedWorld -> Maybe Text
renderLeanWorldModule w
  | null srcs = Nothing
  | otherwise = Just $ T.unlines $
      [ "-- Generated by refl-check-levels --emit-lean-world-modules; do not edit." ]
      ++ filter ("import " `T.isPrefixOf`) prelude
      ++ [""]
      ++ filter (not . ("import " `T.isPrefixOf`)) prelude
      ++ [ "", "namespace " <> space ]
      ++ concat
        [ [ "", "-- " <> lmTitle (llMeta l), lsStatement s, lsSolution s ]
        | (l, s) <- srcs ]
      ++ [ "", "end " <> space ]
 where
  space = "Refl.World." <> worldModuleName (wmId (lwMeta w))
  srcs = worldSources (LangId "lean") w
  prelude = preludeLines (not . (space `T.isInfixOf`)) srcs

-- | The same for Bend, whose modules are flat files. A level names a lemma of
-- its own world @Addition.add_comm@, because it needs that world's file for the
-- earlier levels; inside that file the prefix has to go.
renderBendWorldModule :: LoadedWorld -> Maybe Text
renderBendWorldModule w
  | null srcs = Nothing
  | otherwise = Just $ T.unlines $
      [ "# Generated by refl-check-levels --emit-bend-world-modules; do not edit." ]
      ++ preludeLines (not . (("as " <> modName) `T.isSuffixOf`)) srcs
      ++ concat
        [ [ "", "# " <> lmTitle (llMeta l), own (lsStatement s), own (lsSolution s) ]
        | (l, s) <- srcs ]
 where
  modName = worldModuleName (wmId (lwMeta w))
  own = T.replace (modName <> ".") ""
  srcs = worldSources (LangId "bend2") w

emitWorldModules :: LoadedGame -> FilePath -> IO [FilePath]
emitWorldModules = emitWith renderWorldModule (\m -> "Refl" </> "World" </> m ++ ".agda")

emitLeanWorldModules :: LoadedGame -> FilePath -> IO [FilePath]
emitLeanWorldModules = emitWith renderLeanWorldModule (\m -> "Refl" </> "World" </> m ++ ".lean")

emitBendWorldModules :: LoadedGame -> FilePath -> IO [FilePath]
emitBendWorldModules = emitWith renderBendWorldModule (++ ".bend")

emitWith :: (LoadedWorld -> Maybe Text) -> (String -> FilePath) -> LoadedGame -> FilePath -> IO [FilePath]
emitWith render file game dir =
  fmap concat . forM (lgWorlds game) $ \w ->
    case render w of
      Nothing -> pure []
      Just src -> do
        let path = dir </> file (T.unpack (worldModuleName (wmId (lwMeta w))))
        createDirectoryIfMissing True (takeDirectory path)
        writeFileUtf8 path src
        pure [path]
