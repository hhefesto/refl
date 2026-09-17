-- | Language-agnostic wire types between the browser and the backend.
--
-- Positions are 0-based code-point offsets into the USER REGION of a level
-- (the text the player edits), half-open. The backend converts from each
-- prover's native coordinates (Agda: 1-based whole-file code points; Lean:
-- UTF-16 line/column) so the client never sees a prover-specific offset.
--
-- Everything derives aeson generically with the default sum encoding
-- (@{"tag": …, …}@); both ends are Haskell, so field names are the schema.
module Refl.Protocol.Types where

import           Data.Aeson   (FromJSON, FromJSONKey, ToJSON, ToJSONKey, Value)
import           Data.Map     (Map)
import           Data.Text    (Text)
import           GHC.Generics (Generic)

-- ---------------------------------------------------------------------------
-- Identifiers
-- ---------------------------------------------------------------------------

newtype LangId = LangId { unLangId :: Text }
  deriving stock (Show, Generic)
  deriving newtype (Eq, Ord, ToJSON, FromJSON, ToJSONKey, FromJSONKey)

newtype WorldId = WorldId { unWorldId :: Text }
  deriving stock (Show, Generic)
  deriving newtype (Eq, Ord, ToJSON, FromJSON, ToJSONKey, FromJSONKey)

newtype LevelId = LevelId { unLevelId :: Text }
  deriving stock (Show, Generic)
  deriving newtype (Eq, Ord, ToJSON, FromJSON, ToJSONKey, FromJSONKey)

-- | A prover-side interaction point (Agda goal number). Lean has none.
newtype HoleId = HoleId { unHoleId :: Int }
  deriving stock (Show, Generic)
  deriving newtype (Eq, Ord, ToJSON, FromJSON)

-- ---------------------------------------------------------------------------
-- Positions and results
-- ---------------------------------------------------------------------------

data Span = Span { spanFrom :: Int, spanTo :: Int }
  deriving stock (Eq, Ord, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

-- | What a hole operation is aimed at: an Agda hole, or a cursor offset (Lean).
data Target = TargetHole HoleId | TargetPos Int
  deriving stock (Eq, Ord, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data Hole = Hole
  { holeId   :: HoleId
  , holeSpan :: Span
  , holeType :: Maybe Text   -- ^ the goal type as reported by the last load
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data ContextEntry = ContextEntry
  { ceName    :: Text
  , ceType    :: Text
  , ceInScope :: Bool
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data Goal = Goal
  { goalTarget  :: Target
  , goalType    :: Text
  , goalContext :: [ContextEntry]
  , goalExtras  :: Value
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data Severity = SevError | SevWarning | SevInfo
  deriving stock (Eq, Ord, Show, Bounded, Enum, Generic)
  deriving anyclass (ToJSON, FromJSON)

data Diagnostic = Diagnostic
  { diagSeverity :: Severity
  , diagSpan     :: Maybe Span
  , diagMessage  :: Text
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

-- | A syntax-highlighting span; atoms are the prover's own class names
-- (Agda: @keyword@, @datatype@, @function@, @bound@, @hole@, @error@, …).
data HighlightSpan = HighlightSpan
  { hlSpan  :: Span
  , hlAtoms :: [Text]
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

-- | A static-rule violation in the user region (tampering, forbidden names).
data Violation = Violation
  { vRule    :: Text
  , vSpan    :: Maybe Span
  , vMessage :: Text
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

data Verdict
  = Solved
  | Unsolved Int          -- ^ open goals remaining
  | Rejected [Violation]  -- ^ static rules failed; the prover was not consulted
  | Failed                -- ^ the prover reported errors
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data CheckResult = CheckResult
  { crHoles       :: [Hole]
  , crDiagnostics :: [Diagnostic]
  , crHighlight   :: [HighlightSpan]
  , crVerdict     :: Verdict
  , crStatus      :: Text     -- ^ one-line human summary
  , crExtras      :: Value    -- ^ language-specific extras (e.g. Lean axioms)
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

-- ---------------------------------------------------------------------------
-- Commands (the "tactic inventory")
-- ---------------------------------------------------------------------------

data Normalisation
  = NormAsIs | NormInstantiated | NormHeadNormal | NormSimplified | NormNormalised
  deriving stock (Eq, Ord, Show, Bounded, Enum, Generic)
  deriving anyclass (ToJSON, FromJSON)

data HoleOp
  = OpGoal Normalisation          -- ^ goal type and context
  | OpGive Text                   -- ^ fill the hole with an expression
  | OpRefine Text                 -- ^ refine: apply expression, leaving new holes
  | OpIntro                       -- ^ introduce a constructor / lambda
  | OpCase Text                   -- ^ case split on variables
  | OpAuto                        -- ^ proof search
  | OpInfer Normalisation Text    -- ^ infer the type of an expression
  | OpNormalise Text              -- ^ normalise an expression in the hole's context
  | OpHelperType Text             -- ^ type of a helper function to define
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data CommandId
  = CmdLoad | CmdGoal | CmdGive | CmdRefine | CmdCase | CmdAuto
  | CmdInfer | CmdNormalise | CmdSolveAll
  deriving stock (Eq, Ord, Show, Bounded, Enum, Generic)
  deriving anyclass (ToJSON, FromJSON, ToJSONKey, FromJSONKey)

data LangInfo = LangInfo
  { liId          :: LangId
  , liName        :: Text
  , liExt         :: Text     -- ^ file extension without the dot
  , liInputMethod :: Text     -- ^ which unicode input table the editor uses
  , liAvailable   :: Bool
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

-- ---------------------------------------------------------------------------
-- Progress
-- ---------------------------------------------------------------------------

-- | Levels completed, per language, as @"world/level"@ keys; drafts per
-- level key per language.
data Progress = Progress
  { prCompleted :: Map LangId [Text]
  , prDrafts    :: Map Text (Map LangId Text)
  } deriving stock (Eq, Show, Generic)
    deriving anyclass (ToJSON, FromJSON)

emptyProgress :: Progress
emptyProgress = Progress mempty mempty

-- ---------------------------------------------------------------------------
-- Messages
-- ---------------------------------------------------------------------------

data ClientMsg
  = OpenSession { csLang :: LangId, csWorld :: WorldId, csLevel :: LevelId }
  | Check       { csText :: Text }                 -- ^ full user region
  | HoleCmd     { csTarget :: Target, csOp :: HoleOp }  -- ^ against the last Check text
  | SaveDraft   { csText :: Text }
  | GetProgress
  | Ping
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

data ServerMsg
  = SessionOpened
      { smLang        :: LangInfo
      , smCommands    :: [CommandId]   -- ^ what this prover can do at all
      , smInitialText :: Text          -- ^ template, or the saved draft
      }
  | SessionUnavailable { smReason :: Text }
  | Checked CheckResult
  | GoalShown Goal
  | TextReplaced { smText :: Text, smThen :: Maybe CheckResult }
      -- ^ a hole op rewrote the user region; the server re-checked it
  | Info { smTitle :: Text, smBody :: Text }
  | ProgressState Progress
  | Busy
  | ServerError Text
  | Pong
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON)
