-- | One level: prose and hints on the left, statement and editor in the
-- middle, holes / goal / commands / diagnostics on the right. Owns the
-- websocket session for the level.
module Widgets.LevelPage (levelPage) where

import           Control.Monad          (forM_, void, when)
import           Data.List              (find)
import qualified Data.Map               as M
import           Data.Maybe             (listToMaybe)
import           Data.Text              (Text)
import qualified Data.Text              as T
import           Reflex.Dom.Core

import           Client
import           Refl.Protocol
import           Widgets.Common
import           Widgets.Editor
import           Widgets.Inventory      (unlockedCommands)

data Status = Idle | Checking | Done CheckResult

-- A socket being open does not imply that the prover session is ready.
data SessionState = Connecting | Opening | Ready | Unavailable Text | Disconnected
  deriving (Eq)

levelPage :: Widget' t m
          => Manifest -> Event t () -> LangId -> WorldId -> Int -> m (Event t ())
levelPage m leaveE lang wid idx =
  case [ (w, l) | w <- mWorlds m, wId w == wid, l <- wLevels w, lIndex l == idx ] of
    [] -> el "p" (text "No such level.") >> pure never
    ((w, l) : _) -> do
      elClass "div" "nav-row" $ do
        routeLink RWorldMap (text "World map")
        text "›"
        routeLink (RWorld wid) (text (wTitle w))
        text "›"
        text (lTitle l)
        elClass "span" "spacer" blank
        -- language switcher: only languages this level has
        forM_ (M.keys (lLanguages l)) $ \lg ->
          if lg == lang then elClass "span" "pill on" (text (unLangId lg))
          else routeLinkClass "pill" (levelRoute wid l (Just lg)) (text (unLangId lg))
      case M.lookup lang (lLanguages l) of
        Nothing -> elClass "div" "unavailable" (text "This level has no source for that language yet.") >> pure never
        Just ll -> body w l ll
 where
  body w l ll = elClass "div" "level" $ mdo
    -- session ------------------------------------------------------------
    conn <- connect sendE retryE leaveE
    let recv = connRecv conn
        openE = OpenSession lang wid (lId l) <$ connOpen conn
        opened = fmapMaybe (\case SessionOpened li cs t -> Just (li, cs, t); _ -> Nothing) recv
        unavailable = fmapMaybe (\case SessionUnavailable r -> Just r; _ -> Nothing) recv
        checkedRaw = fmapMaybe (\case Checked r -> Just r; _ -> Nothing) recv
        replacedRaw = fmapMaybe (\case TextReplaced t r -> Just (t, r); _ -> Nothing) recv
        fresh = (\sent now -> sent == Just now) <$> submitted <*> eoText ed
        checked = gate (current fresh) checkedRaw
        replaced = gate (current fresh) replacedRaw
        goalShown = fmapMaybe (\case GoalShown g -> Just g; _ -> Nothing) recv
        info = fmapMaybe (\case Info t b -> Just (t, b); _ -> Nothing) recv
        serverErr = leftmost [fmapMaybe (\case ServerError e -> Just e; _ -> Nothing) recv, connError conn]
        resultE = leftmost [checked, fmapMaybe snd replaced]
        finished = leftmost [() <$ checkedRaw, () <$ replacedRaw, () <$ goalShown, () <$ info, () <$ serverErr, () <$ unavailable, connClose conn]
    session <- holdDyn Connecting $ leftmost
      [ Connecting <$ retryE, Opening <$ connOpen conn, Ready <$ opened
      , Unavailable <$> unavailable, Unavailable <$> connError conn, Disconnected <$ connClose conn ]
    busy <- holdDyn False (leftmost [False <$ finished, True <$ requestE, False <$ retryE])
    submitted <- holdDyn Nothing (Just <$> tag (current (eoText ed)) requestE)
    langCommands <- holdDyn [] ((\(_, cs, _) -> cs) <$> opened)
    let available = [ c | c <- unlockedCommands m wid (lIndex l) ]
        canUse c = (\cs s b mt t -> s == Ready && not b && c `elem` cs && c `elem` available
                       && (c == CmdLoad || mt == Just t))
                   <$> langCommands <*> session <*> busy <*> checkedText <*> eoText ed
    -- editor --------------------------------------------------------------
    -- initial text: template until the session says otherwise
    let initialText = llTemplate ll
    lastResult <- holdDyn Nothing (leftmost [ Nothing <$ eoEdited ed, Nothing <$ retryE, Just <$> resultE ])
    checkedText <- holdDyn Nothing (leftmost [ Nothing <$ eoEdited ed, Nothing <$ retryE, Just <$> tag (current (eoText ed)) checked
                                             , Just . fst <$> replaced ])
    let hlDyn = ffor ((,) <$> lastResult <*> checkedText) $ \(mr, mt) -> case (mr, mt) of
          (Just r, Just t) -> Just (t, crHighlight r, crHoles r)
          _ -> Nothing
    -- left column ---------------------------------------------------------
    (ed, cmdE, exprDyn) <- mdo
      elClass "div" "col-left" $ do
        el "h2" (text (lTitle l))
        elClass "div" "card prose" $ rawHtml (lIntroHtml l)
        hintsW l lastResult
        dyn_ $ ffor lastResult $ \mr -> case mr of
          Just r | crVerdict r == Solved -> elClass "div" "conclusion prose" $ do
            rawHtml (lConclusionHtml l)
            nextLink w l
          _ -> blank
      -- middle column
      (ed', cmdE', exprDyn') <- elClass "div" "col-mid" $ do
        elClass "pre" "statement" (text (T.stripEnd (llStatement ll)))
        ed0 <- editor EditorConfig
          { ecInitial = initialText
          , ecSetText = leftmost [ (\(_, _, t) -> t) <$> opened, fst <$> replaced ]
          , ecHighlight = hlDyn
          , ecInputMethod = liInputMethod' lang
          }
        (cmdE0, exprDyn0) <- commandsW canUse ed0
        elClass "div" "editor-status" $ do
          dynText (ffor status $ \case Checking -> "checking…"; _ -> "")
          elClass "span" "im" $ text (if liInputMethod' lang == "none" then "" else "\\ input: \\to → \\bN ℕ \\Gl λ \\== ≡ \\all ∀ \\_1 ₁ · C-c C-l check · C-c C-, goal · C-c C-SPC give · C-c C-c case")
        pure (ed0, cmdE0, exprDyn0)
      pure (ed', cmdE', exprDyn')
    -- right column --------------------------------------------------------
    (sendHoleE, retryE) <- elClass "div" "col-right" $ mdo
      retry <- switchHold never =<< dyn (ffor session $ \s -> do
        elClass "div" "session-status" $ text $ case s of
          Connecting -> "Connecting…"
          Opening -> "Opening prover session…"
          Ready -> "Ready"
          Unavailable reason -> reason
          Disconnected -> "Disconnected. Retry to reconnect."
        case s of
          Unavailable _ -> button "Retry"
          Disconnected -> button "Retry"
          _ -> pure never)
      -- verdict
      dyn_ $ ffor status $ \case
        Idle -> elClass "div" "verdict idle" (text "Check the file to see goals (C-c C-l).")
        Checking -> elClass "div" "verdict idle" (text "Checking…")
        Done r -> elClass "div" ("verdict " <> verdictClass (crVerdict r)) (text (verdictText (crVerdict r) <> " — " <> crStatus r))
      -- holes
      elClass "div" "goals-title" (text "Holes")
      sel <- holdDyn Nothing (leftmost [ pickHole <$> resultE, holeClickE, cursorHoleE ])
      holeClickE <- switchHold never . fmap leftmost =<< (elClass "div" "holes" $ dyn $ ffor ((,) <$> lastResult <*> sel) $ \(mr, s) ->
        case mr of
          Just r | not (null (crHoles r)) -> forM_' (crHoles r) $ \h -> do
            (b, _) <- elClass' "button" (if Just (holeId h) == s then "sel" else "") $
              text ("?" <> T.pack (show (unHoleId (holeId h))) <> maybe "" (\ty -> " : " <> T.take 40 ty) (holeType h))
            pure (Just (holeId h) <$ domEvent Click b)
          Just _ -> elClass "span" "muted" (text "No holes.") >> pure []
          Nothing -> elClass "span" "muted" (text "—") >> pure [])
      -- the cursor selects a hole too
      let cursorHoleE = attachWithMaybe
            (\mr cur -> case mr of
                Just r -> Just . holeId <$> find (\h -> let Span a b = holeSpan h in cur >= a && cur <= b) (crHoles r)
                Nothing -> Nothing)
            (current lastResult) (updated (eoCursor ed))
      -- goal
      elClass "div" "goals-title" (text "Goal")
      goalDyn <- holdDyn Nothing (leftmost [ Just . Left <$> goalShown, Just . Right <$> info, Nothing <$ resultE ])
      dyn_ $ ffor goalDyn $ \case
        Nothing -> elClass "div" "goal muted" (text "Select a hole and press Goal (C-c C-,).")
        Just (Left g) -> elClass "div" "goal" $ do
          forM_ (goalContext g) $ \ce ->
            elClass "div" (if ceInScope ce then "ctx" else "ctx muted") (text (ceName ce <> " : " <> ceType ce))
          when (not (null (goalContext g))) $ elClass "div" "sep" blank
          elClass "div" "ty" (text ("⊢ " <> goalType g))
        Just (Right (t, b)) -> elClass "div" "goal" $ do
          elClass "div" "ctx" (text t)
          elClass "div" "sep" blank
          elClass "div" "ty" (text b)
      -- diagnostics
      elClass "div" "goals-title" (text "Messages")
      errDyn <- holdDyn Nothing (leftmost [Just <$> serverErr, Nothing <$ resultE])
      dyn_ $ ffor errDyn $ \case
        Just e -> elClass "div" "diag error" (text e)
        Nothing -> blank
      dyn_ $ ffor lastResult $ \case
        Just r -> forM_ (crDiagnostics r) $ \d ->
          elClass "div" ("diag " <> sevClass (diagSeverity d)) (text (diagMessage d))
        Nothing -> blank
      -- combine commands with the selected hole / expression
      let holeOpE = attachWithMaybe
            (\(s, expr, cur) c -> case c of
                CmdLoad -> Nothing
                _ -> case (s, c) of
                  (_, CmdInfer) -> Just (HoleCmd (target s cur) (OpInfer NormNormalised expr))
                  (_, CmdNormalise) -> Just (HoleCmd (target s cur) (OpNormalise expr))
                  (_, CmdGoal) -> Just (HoleCmd (target s cur) (OpGoal NormNormalised))
                  (Just h, CmdGive) -> Just (HoleCmd (TargetHole h) (OpGive expr))
                  (Just h, CmdRefine) -> Just (HoleCmd (TargetHole h) (if T.null (T.strip expr) then OpIntro else OpRefine expr))
                  (Just h, CmdCase) -> Just (HoleCmd (TargetHole h) (OpCase expr))
                  (Just h, CmdAuto) -> Just (HoleCmd (TargetHole h) OpAuto)
                  (Nothing, _) -> Nothing
                  (_, CmdSolveAll) -> Nothing)
            ((,,) <$> current sel <*> current exprDyn <*> current (eoCursor ed)) cmdE
          target s cur = maybe (TargetPos cur) TargetHole s
      pure (holeOpE, retry)
    -- outgoing --------------------------------------------------------------
    let checkE = Check <$> tag (current (eoText ed)) (ffilter (== CmdLoad) cmdE)
        draftE = SaveDraft <$> eoEdited ed
    draftDebounced <- debounce 2 draftE
    let requestE = leftmost [() <$ checkE, () <$ sendHoleE]
        sendE = mergeWith (++) [ (: []) <$> openE, (: []) <$> checkE, (: []) <$> sendHoleE
                              , (: []) <$> gate (current ((== Ready) <$> session)) draftDebounced ]
    status <- holdDyn Idle (leftmost [ Idle <$ eoEdited ed, Idle <$ retryE, Done <$> resultE, Idle <$ finished, Checking <$ requestE ])
    pure (() <$ ffilter ((== Solved) . crVerdict) resultE)

  liInputMethod' lg = case unLangId lg of
    "agda" -> "agda"
    "lean" -> "agda"
    _ -> "none"

  sevClass = \case
    SevError -> "error"
    SevWarning -> "warning"
    SevInfo -> "info"

  pickHole r = holeId <$> listToMaybe (crHoles r)

  forM_' xs f = mapM f xs

  nextLink w l =
    case [ n | n <- wLevels w, lIndex n == lIndex l + 1 ] of
      (n : _) -> el "p" $ routeLinkClass "primary" (levelRoute (wId w) n (Just lang)) (text ("Next: " <> lTitle n <> " →"))
      [] -> el "p" $ routeLink (RWorld (wId w)) (text "World complete — back to the world page →")

-- | Command buttons (only the unlocked ones) and the expression field.
commandsW :: Widget' t m => (CommandId -> Dynamic t Bool) -> EditorOut t -> m (Event t CommandId, Dynamic t Text)
commandsW canUse ed = do
  clicks <- elClass "div" "commands" $ mapM btn
    [ (CmdLoad, "Check", "C-c C-l", True)
    , (CmdGoal, "Goal", "C-c C-,", False)
    , (CmdGive, "Give", "C-c C-SPC", False)
    , (CmdRefine, "Refine", "C-c C-r", False)
    , (CmdCase, "Case split", "C-c C-c", False)
    , (CmdAuto, "Auto", "C-c C-a", False)
    , (CmdInfer, "Infer", "C-c C-d", False)
    , (CmdNormalise, "Normalise", "C-c C-n", False)
    ]
  expr <- elClass "div" "expr" $ do
    i <- inputElement $ def
      & inputElementConfig_elementConfig . elementConfig_initialAttributes .~
          ("placeholder" =: "expression for Give / Refine / Case / Infer / Normalise" <> "class" =: "mono")
    pure (_inputElement_value i)
  let chordE = ffor (eoChord ed) $ \case
        ChordLoad -> CmdLoad; ChordGoal -> CmdGoal; ChordGive -> CmdGive; ChordRefine -> CmdRefine
        ChordCase -> CmdCase; ChordAuto -> CmdAuto; ChordNormalise -> CmdNormalise; ChordInfer -> CmdInfer
      allowed = attachWithMaybe (\ok c -> if ok c then Just c else Nothing) (current (allowedSet canUse)) chordE
  pure (leftmost (allowed : clicks), expr)
 where
  btn (c, label, chord, primary) = do
    let attrs = ffor (canUse c) $ \ok ->
          ("title" =: (label <> " (" <> chord <> ")")) <> (if primary then "class" =: "primary" else mempty)
          <> (if ok then mempty else "disabled" =: "disabled")
    (b, _) <- elDynAttr' "button" attrs (text label)
    pure (c <$ domEvent Click b)
  allowedSet f = ffor (sequenceA (M.fromList [ (c, f c) | c <- [minBound .. maxBound] ])) $ \mp c ->
    M.findWithDefault False c mp

-- | Visible hints, and hidden ones revealed one at a time after a failed attempt.
hintsW :: Widget' t m => Level -> Dynamic t (Maybe CheckResult) -> m ()
hintsW l lastResult = elClass "div" "hints" $ do
  let visible = [ h | h <- lHints l, not (hHidden h) ]
      hidden = [ h | h <- lHints l, hHidden h ]
  forM_ visible $ \h -> elClass "div" "hint prose" (rawHtml (hHtml h))
  when (not (null hidden)) $ mdo
    let tried = ffor lastResult $ \case
          Just r -> crVerdict r /= Solved
          Nothing -> False
    shown <- foldDyn (\_ n -> n + 1) (0 :: Int) clickE
    dyn_ $ ffor shown $ \n -> forM_ (take n hidden) $ \h -> elClass "div" "hint prose" (rawHtml (hHtml h))
    clickE <- switchHold never =<< (dyn $ ffor ((,) <$> shown <*> tried) $ \(n, t) ->
      if n < length hidden && t
        then do (b, _) <- el' "button" (text ("Need a hint? (" <> T.pack (show (length hidden - n)) <> " left)")); pure (domEvent Click b)
        else pure never)
    pure ()
