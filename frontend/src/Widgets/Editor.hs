-- | The proof editor: a textarea (transparent text, visible caret) over a
-- @pre@ overlay that carries the prover's highlighting, plus the unicode input
-- method and agda-mode's C-c chords.
module Widgets.Editor
  ( EditorConfig (..)
  , EditorOut (..)
  , Chord (..)
  , editor
  , setCursor
  ) where

import           Control.Lens                ((^.))
import           Control.Monad               (void, when)
import           Control.Monad.IO.Class      (liftIO)
import           Data.IORef
import           Data.List                   (sortOn)
import           Data.Text                   (Text)
import qualified Data.Text                   as T
import qualified GHCJS.DOM.Element           as DomEl
import qualified GHCJS.DOM.HTMLElement       as HtmlEl
import qualified GHCJS.DOM.Node              as DomNode
import qualified GHCJS.DOM.ParentNode        as ParentNode
import qualified GHCJS.DOM.EventM            as EventM
import qualified GHCJS.DOM.GlobalEventHandlers as GE
import qualified GHCJS.DOM.HTMLTextAreaElement as TA
import qualified GHCJS.DOM.KeyboardEvent     as KE
import           GHCJS.DOM.Types             (liftJSM)
import           Language.Javascript.JSaddle (MonadJSM)
import           Reflex.Dom.Core

import           Refl.Protocol.Types
import           Widgets.InputMethod
import           Widgets.InputTable          (agdaTable)

data Chord = ChordLoad | ChordGoal | ChordGive | ChordRefine | ChordCase | ChordAuto | ChordNormalise | ChordInfer
  deriving (Eq, Show)

data EditorConfig t = EditorConfig
  { ecInitial     :: Text
  , ecSetText     :: Event t Text                 -- ^ server rewrote the text
  , ecHighlight   :: Dynamic t (Maybe (Text, [HighlightSpan], [Hole]))
    -- ^ highlighting valid for exactly that text
  , ecInputMethod :: Text                          -- ^ "agda" | "lean"
  }

data EditorOut t = EditorOut
  { eoText   :: Dynamic t Text
  , eoCursor :: Dynamic t Int          -- ^ code points
  , eoChord  :: Event t Chord
  , eoRaw    :: TA.HTMLTextAreaElement
  }

editor :: MonadWidget t m => EditorConfig t -> m (EditorOut t)
editor cfg = elClass "div" "editor-wrap" $ mdo
  let table = mkTable agdaTable
  -- overlay (behind the textarea)
  elClass "pre" "overlay" $ dyn_ $ ffor ((,) <$> textDyn <*> ecHighlight cfg) $ \(t, hl) ->
    case hl of
      Just (t', spans, holes) | t' == t -> overlay t spans holes
      _ -> text (t <> "\n")
  ta <- textAreaElement $ def
    & textAreaElementConfig_initialValue .~ ecInitial cfg
    & textAreaElementConfig_elementConfig . elementConfig_initialAttributes .~
        ("spellcheck" =: "false" <> "autocomplete" =: "off" <> "autocapitalize" =: "off"
         <> "wrap" =: "off" <> "rows" =: "14")
  let raw = _textAreaElement_raw ta
  overlayEl <- pure ()  -- overlay is the first child; scroll sync below finds it by DOM
  chordRef <- liftIO (newIORef False)
  -- keydown: chords and preventDefault for C-c
  keyE <- wrapDomEvent raw (`EventM.on` GE.keyDown) $ do
    e <- EventM.event
    ctrl <- KE.getCtrlKey e
    key <- KE.getKey e
    armed <- liftIO (readIORef chordRef)
    if ctrl && key == "c" && not armed
      then do EventM.preventDefault; liftIO (writeIORef chordRef True); pure Nothing
      else if armed && ctrl
        then do
          EventM.preventDefault
          liftIO (writeIORef chordRef False)
          pure $ case T.toLower key of
            "l" -> Just ChordLoad
            "," -> Just ChordGoal
            " " -> Just ChordGive
            "r" -> Just ChordRefine
            "c" -> Just ChordCase
            "a" -> Just ChordAuto
            "n" -> Just ChordNormalise
            "d" -> Just ChordInfer
            _   -> Nothing
        else do
          when armed (liftIO (writeIORef chordRef False))
          pure Nothing
  -- input: apply the input method, then report the new text
  inputE <- performEvent $ ffor (_textAreaElement_input ta) $ \_ -> liftJSM $ do
    v <- TA.getValue raw
    selU <- fromIntegral <$> TA.getSelectionStart raw
    let cur = utf16ToCp v selU
    if ecInputMethod cfg == "none" then pure (v, cur) else
      case applyInput table v cur of
        Nothing -> pure (v, cur)
        Just (v', cur') -> do
          TA.setValue raw v'
          let u = cpToUtf16 v' cur'
          TA.setSelectionRange raw (Just u) (Just u) (Nothing :: Maybe Text)
          pure (v', cur')
  setE <- performEvent $ ffor (ecSetText cfg) $ \t -> liftJSM $ do
    selU <- fromIntegral <$> TA.getSelectionStart raw
    old <- TA.getValue raw
    let cur = min (T.length t) (utf16ToCp old selU)
    TA.setValue raw t
    let u = cpToUtf16 t cur
    TA.setSelectionRange raw (Just u) (Just u) (Nothing :: Maybe Text)
    pure (t, cur)
  -- cursor moves without input
  cursorMoveE <- performEvent $ ffor (leftmost [() <$ domEvent Click (_textAreaElement_element ta), () <$ domEvent Keyup (_textAreaElement_element ta)]) $ \_ -> liftJSM $ do
    v <- TA.getValue raw
    selU <- fromIntegral <$> TA.getSelectionStart raw
    pure (utf16ToCp v selU)
  -- scroll sync
  performEvent_ $ ffor (domEvent Scroll (_textAreaElement_element ta)) $ \_ -> liftJSM $ do
    top <- DomEl.getScrollTop raw
    left <- DomEl.getScrollLeft raw
    mparent <- DomNode.getParentElement raw
    case mparent of
      Nothing -> pure ()
      Just parent -> do
        mfirst <- ParentNode.getFirstElementChild parent
        case mfirst of
          Nothing -> pure ()
          Just ov -> DomEl.setScrollTop ov top >> DomEl.setScrollLeft ov left
  textDyn <- holdDyn (ecInitial cfg) (leftmost [fst <$> setE, fst <$> inputE])
  cursorDyn <- holdDyn 0 (leftmost [snd <$> setE, snd <$> inputE, cursorMoveE])
  void (pure overlayEl)
  let _ = raw ^. id
  pure EditorOut
    { eoText = textDyn
    , eoCursor = cursorDyn
    , eoChord = fmapMaybe id keyE
    , eoRaw = raw
    }

-- | Move the caret to a code-point offset and focus.
setCursor :: MonadJSM m => TA.HTMLTextAreaElement -> Int -> m ()
setCursor raw cp = liftJSM $ do
  v <- TA.getValue raw
  let u = cpToUtf16 v cp
  TA.setSelectionRange raw (Just u) (Just u) (Nothing :: Maybe Text)
  HtmlEl.focus raw

-- | Render text with highlight spans as classed @span@s.
overlay :: DomBuilder t m => Text -> [HighlightSpan] -> [Hole] -> m ()
overlay t spans holes = go 0 pieces >> text "\n"
 where
  holeSpans = [ HighlightSpan (holeSpan h) ["hole"] | h <- holes ]
  pieces = sortOn (spanFrom . hlSpan) (filter valid (holeSpans ++ spans))
  valid (HighlightSpan (Span a b) _) = a >= 0 && b <= T.length t && a < b
  go pos [] = text (T.drop pos t)
  go pos (HighlightSpan (Span a b) atoms : rest)
    | a < pos = go pos rest   -- overlapping: skip
    | otherwise = do
        text (T.take (a - pos) (T.drop pos t))
        elClass "span" (T.unwords (map (("hl-" <>) . T.toLower) atoms)) (text (T.take (b - a) (T.drop a t)))
        go b rest
