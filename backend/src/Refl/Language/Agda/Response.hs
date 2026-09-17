-- | Decoding of Agda's JSON responses (one object per line, prefixed by the
-- @JSON> @ prompt). Shapes follow @Agda.Interaction.JSONTop@ in 2.8.0; parsing
-- is lenient so an unexpected field never kills a session.
module Refl.Language.Agda.Response
  ( AgdaResponse (..)
  , DisplayInfo (..)
  , GoalInfo (..)
  , GoalEntry (..)
  , GiveResult (..)
  , Msg (..)
  , HL (..)
  , decodeResponse
  ) where

import           Data.Aeson
import           Data.Aeson.Types    (Parser, parseMaybe)
import qualified Data.Aeson.KeyMap   as KM
import           Data.Maybe          (fromMaybe)
import           Data.Text           (Text)
import qualified Data.Text           as T
import qualified Data.Text.Lazy      as TL
import qualified Data.Text.Lazy.Encoding as TLE

import           Refl.Protocol.Types (ContextEntry (..))

data HL = HL { hlFrom :: Int, hlTo :: Int, hlAtoms :: [Text] }
  deriving (Eq, Show)

data Msg = Msg { msgText :: Text, msgRange :: Maybe (Int, Int) }
  deriving (Eq, Show)

data GoalEntry = GoalEntry { geId :: Int, geType :: Text }
  deriving (Eq, Show)

data GiveResult = GiveString Text | GiveParen | GiveNoParen
  deriving (Eq, Show)

data GoalInfo
  = GIGoalType Text [ContextEntry]
  | GICurrentGoal Text
  | GIInferred Text
  | GINormalForm Text
  | GIHelper Text
  | GIOther Value
  deriving (Eq, Show)

data DisplayInfo
  = DAllGoals [GoalEntry] [GoalEntry] [Msg] [Msg]   -- ^ visible, invisible, warnings, errors
  | DError Text [Msg]                              -- ^ error message, warnings
  | DGoalSpecific Int GoalInfo
  | DInferred Text
  | DNormalForm Text
  | DAuto Text
  | DCompilationOk
  | DOtherInfo Text Value
  deriving (Eq, Show)

data AgdaResponse
  = RHighlighting [HL]
  | RStatus Bool                         -- ^ checked?
  | RJumpToError Int
  | RInteractionPoints [(Int, Maybe (Int, Int))]
  | RGiveAction Int GiveResult
  | RMakeCase Text [Text]
  | RSolveAll [(Int, Text)]
  | RMimer (Maybe Text)
  | RDisplay DisplayInfo
  | RRunning Text
  | RClear
  | RDoneExiting
  | RDoneAborting
  | ROther Text
  deriving (Eq, Show)

decodeResponse :: Value -> AgdaResponse
decodeResponse v = fromMaybe (ROther (render v)) (parseMaybe parseResponse v)

render :: Value -> Text
render = TL.toStrict . TLE.decodeUtf8 . encode

parseResponse :: Value -> Parser AgdaResponse
parseResponse = withObject "response" $ \o -> do
  mkind <- o .:? "kind"
  direct <- o .:? "direct"
  case (mkind :: Maybe Text, direct :: Maybe Bool) of
    (_, Just True) -> do
      info <- o .: "info"
      payload <- info .: "payload"
      RHighlighting <$> mapM parseHL payload
    (Just "Status", _) -> do
      st <- o .: "status"
      RStatus <$> st .: "checked"
    (Just "JumpToError", _) -> RJumpToError <$> o .: "position"
    (Just "InteractionPoints", _) -> do
      ips <- o .: "interactionPoints"
      RInteractionPoints <$> mapM parseIP ips
    (Just "GiveAction", _) -> do
      i <- o .: "interactionPoint" >>= ipId
      gr <- o .: "giveResult"
      RGiveAction i <$> parseGive gr
    (Just "MakeCase", _) ->
      RMakeCase <$> o .: "variant" <*> o .: "clauses"
    (Just "SolveAll", _) -> do
      sols <- o .: "solutions"
      RSolveAll <$> mapM (withObject "solution" $ \s -> (,) <$> (s .: "interactionPoint" >>= ipId) <*> s .: "expression") sols
    (Just "Mimer", _) -> RMimer <$> o .:? "solution"
    (Just "DisplayInfo", _) -> RDisplay <$> (o .: "info" >>= parseDisplay)
    (Just "RunningInfo", _) -> RRunning <$> o .: "message"
    (Just "ClearRunningInfo", _) -> pure RClear
    (Just "ClearHighlighting", _) -> pure RClear
    (Just "DoneExiting", _) -> pure RDoneExiting
    (Just "DoneAborting", _) -> pure RDoneAborting
    _ -> pure (ROther (render (Object o)))

-- | Interaction points appear both as bare ids and as @{id, range}@ objects.
ipId :: Value -> Parser Int
ipId (Object ip) = ip .: "id"
ipId (Number n)  = pure (round n)
ipId _           = fail "interactionPoint"

parseHL :: Value -> Parser HL
parseHL = withObject "hl" $ \o -> do
  [a, b] <- o .: "range"
  atoms <- o .:? "atoms" .!= []
  pure (HL a b atoms)

-- | An interaction point: id plus the code-point range of its first interval.
parseIP :: Value -> Parser (Int, Maybe (Int, Int))
parseIP = withObject "ip" $ \o -> do
  i <- o .: "id"
  rs <- o .:? "range" .!= []
  pure (i, firstInterval rs)

firstInterval :: [Value] -> Maybe (Int, Int)
firstInterval (Object iv : _) =
  let pos k = case KM.lookup k iv of
        Just (Object p) -> parseMaybe (.: "pos") p
        _               -> Nothing
  in (,) <$> pos "start" <*> pos "end"
firstInterval _ = Nothing

parseGive :: Value -> Parser GiveResult
parseGive = withObject "giveResult" $ \o -> do
  ms <- o .:? "str"
  mp <- o .:? "paren"
  pure $ case (ms, mp) of
    (Just s, _)        -> GiveString s
    (_, Just True)     -> GiveParen
    _                  -> GiveNoParen

parseDisplay :: Value -> Parser DisplayInfo
parseDisplay = withObject "info" $ \o -> do
  kind <- o .: "kind"
  case kind :: Text of
    "AllGoalsWarnings" ->
      DAllGoals <$> (o .: "visibleGoals" >>= mapM parseGoalEntry)
                <*> (o .: "invisibleGoals" >>= mapM parseGoalEntry)
                <*> (o .: "warnings" >>= pure . map parseMsg)
                <*> (o .: "errors" >>= pure . map parseMsg)
    "Error" -> do
      e <- o .: "error"
      msg <- withObject "error" (\eo -> eo .: "message") e
      ws <- o .:? "warnings" .!= []
      pure (DError msg (map parseMsg ws))
    "GoalSpecific" -> do
      i <- o .: "interactionPoint" >>= ipId
      gi <- o .: "goalInfo"
      DGoalSpecific i <$> parseGoalInfo gi
    "InferredType" -> DInferred <$> exprText o
    "NormalForm" -> DNormalForm <$> exprText o
    "Auto" -> DAuto <$> (o .:? "info" .!= "")
    "CompilationOk" -> pure DCompilationOk
    other -> pure (DOtherInfo other (Object o))
 where
  exprText o = do
    e <- o .:? "expr"
    pure (maybe "" valueText e)

-- | Goals in AllGoalsWarnings: @{"kind":"OfType","constraintObj":{"id":n,…},"type":"…"}@.
parseGoalEntry :: Value -> Parser GoalEntry
parseGoalEntry = withObject "goal" $ \o -> do
  c <- o .: "constraintObj"
  i <- case c of
    Object co -> co .: "id"
    Number n  -> pure (round n)
    _         -> fail "constraintObj"
  ty <- o .:? "type"
  kind <- o .:? "kind" .!= ("" :: Text)
  pure (GoalEntry i (maybe (kind <> " " <> render (Object o)) valueText ty))

parseGoalInfo :: Value -> Parser GoalInfo
parseGoalInfo v@(Object o) = do
  kind <- o .:? "kind" .!= ("" :: Text)
  case kind of
    "GoalType" -> do
      ty <- o .:? "type"
      entries <- o .:? "entries" .!= []
      es <- mapM parseEntry entries
      pure (GIGoalType (maybe "" valueText ty) es)
    "CurrentGoal" -> GICurrentGoal . maybe "" valueText <$> o .:? "type"
    "InferredType" -> GIInferred . maybe "" valueText <$> o .:? "expr"
    "NormalForm" -> GINormalForm . maybe "" valueText <$> o .:? "expr"
    "HelperFunction" -> GIHelper . maybe "" valueText <$> o .:? "signature"
    _ -> pure (GIOther v)
parseGoalInfo v = pure (GIOther v)

parseEntry :: Value -> Parser ContextEntry
parseEntry = withObject "entry" $ \o ->
  ContextEntry <$> (o .:? "reifiedName" >>= \r -> maybe (o .: "originalName") pure r)
               <*> (maybe "" valueText <$> o .:? "binding")
               <*> o .:? "inScope" .!= True

-- | Warnings/errors come as objects with a message (and sometimes a range);
-- fall back to the whole object rendered.
parseMsg :: Value -> Msg
parseMsg v@(Object o) =
  let txt = case KM.lookup "message" o of
        Just (String s) -> s
        _ -> case KM.lookup "warning" o of
          Just (String s) -> s
          _ -> render v
      rng = case KM.lookup "range" o of
        Just (Array _) -> case fromJSON (fromMaybe Null (KM.lookup "range" o)) of
          Success rs -> firstInterval rs
          _          -> Nothing
        _ -> Nothing
  in Msg txt rng
parseMsg (String s) = Msg s Nothing
parseMsg v = Msg (render v) Nothing

valueText :: Value -> Text
valueText (String s) = s
valueText v          = T.strip (render v)
