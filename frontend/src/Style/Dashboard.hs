-- | The dashboard's own stylesheet, injected by the page rather than added
-- to 'Style.appCss': appCss is inlined into every public page load, and a
-- private page's chart ramps have no business travelling with it.
--
-- The two palettes below are not eyeballed. They come out of the dataviz
-- skill's validator (@scripts/validate_palette.js@) run against the real
-- surfaces, @--card@ #1d242d dark and #ffffff light:
--
-- * categorical, all checks pass, worst colour-blind separation ΔE 13.8
--   (dark) and 13.9 (light), well above the ΔE 8 target;
-- * sequential, one hue, monotone lightness, every adjacent gap ≥ 0.06 L,
--   and the lowest step clears the surface at 2.12:1 (dark) / 2.48:1
--   (light) — which is what makes "one visit" visibly different from
--   "none" rather than a shade of the background.
module Style.Dashboard (dashboardCss) where

import           Data.Text (Text)
import qualified Data.Text as T

dashboardCss :: Text
dashboardCss = T.unlines
  [ ":root { --cat-1:#3f93f7; --cat-2:#d27b00; --cat-3:#db5fa1;"
    <> " --seq-0:#2a323c; --seq-1:#3d5873; --seq-2:#4c7197; --seq-3:#5b8cbe; --seq-4:#6aa7e5; --seq-5:#7ac3ff; }"
  , ":root[data-theme=light] { --cat-1:#2279dc; --cat-2:#b76200; --cat-3:#c04688;"
    <> " --seq-0:#eceae4; --seq-1:#83a8cf; --seq-2:#6292c3; --seq-3:#407bb5; --seq-4:#1464a8; --seq-5:#004d9a; }"
  , ".dash { max-width:1400px; margin:0 auto; padding:1.2rem; }"
  , ".dash-top { display:flex; align-items:baseline; gap:1rem; flex-wrap:wrap; margin-bottom:1rem; }"
  , ".dash-top h1 { margin:0; font-size:1.5rem; }"
  , ".dash-top .when { color:var(--muted); font-size:.85rem; }"
  , ".dash-top .grow { flex:1; }"
  , ".ranges { display:flex; gap:.3rem; }"
  , ".dash-top #theme-toggle { font-size:.85rem; }"
  , ".ranges button.on { background:var(--active); border-color:var(--accent); color:var(--accent); }"
  , ".tiles { display:grid; grid-template-columns:repeat(auto-fit, minmax(170px, 1fr)); gap:.8rem; margin-bottom:1rem; }"
  , ".tile { background:var(--card); border:1px solid var(--line); border-radius:10px; padding:.8rem 1rem; }"
  , ".tile .k { font-size:.72rem; text-transform:uppercase; letter-spacing:.07em; color:var(--muted); }"
  , ".tile .v { font-family:'Space Grotesk','IBM Plex Sans',sans-serif; font-size:2rem; line-height:1.1; letter-spacing:-0.02em; }"
  , ".tile .d { font-size:.78rem; color:var(--muted); } .tile .note { font-size:.72rem; color:var(--muted); opacity:.85; }"
  , ".tile .d.up { color:var(--ok); } .tile .d.down { color:var(--err); }"
  , ".panels { display:grid; grid-template-columns:repeat(auto-fit, minmax(380px, 1fr)); gap:.8rem; align-items:start; }"
  , ".panel { background:var(--card); border:1px solid var(--line); border-radius:10px; padding:.9rem 1rem; }"
  , ".panel.wide { grid-column:1 / -1; }"
  , "@media (min-width: 1160px) { .panel.two { grid-column:span 2; } }"
  -- the map needs the room, and the table beside it is its accessible twin
  , ".geo-row { display:grid; grid-template-columns:minmax(0, 2.4fr) minmax(230px, 1fr); gap:1.2rem; align-items:start; }"
  , "@media (max-width: 900px) { .geo-row { grid-template-columns:1fr; } }"
  , ".geo-row h3 { font-size:.75rem; text-transform:uppercase; letter-spacing:.07em; color:var(--muted); margin:.2rem 0 .5rem; font-family:'IBM Plex Sans',sans-serif; font-weight:600; }"
  , ".panel h2 { font-size:.95rem; margin:0 0 .6rem; }"
  , ".panel .empty { color:var(--muted); font-size:.9rem; }"
  -- charts: sized by viewBox only, coloured by class, so both themes work
  , ".chart svg, .geo svg { width:100%; height:auto; display:block; }"
  , ".chart .grid { stroke:var(--line); stroke-width:1; opacity:.5; }"
  , ".chart .area { fill:var(--cat-1); opacity:.16; }"
  , ".chart .line { fill:none; stroke:var(--cat-1); stroke-width:2; stroke-linejoin:round; stroke-linecap:round; }"
  , ".chart .dot { fill:var(--cat-1); }"
  , ".chart .tick { font-size:11px; fill:var(--muted); font-family:'IBM Plex Sans',sans-serif; }"
  , ".chart .last { font-size:12px; font-weight:600; fill:var(--ink); font-family:'IBM Plex Sans',sans-serif; }"
  , ".chart .hit { fill:transparent; } .chart .hit:hover { fill:var(--ink); opacity:.07; }"
  -- the map
  , ".geo .land { stroke:var(--card); stroke-width:.7; fill-rule:evenodd; }"
  , ".geo .q0 { fill:var(--seq-0); } .geo .q1 { fill:var(--seq-1); } .geo .q2 { fill:var(--seq-2); }"
  , ".geo .q3 { fill:var(--seq-3); } .geo .q4 { fill:var(--seq-4); } .geo .q5 { fill:var(--seq-5); }"
  , ".geo .land:hover { stroke:var(--ink); stroke-width:1.2; }"
  , ".legend { display:flex; align-items:center; gap:.4rem; margin-top:.5rem; font-size:.75rem; color:var(--muted); flex-wrap:wrap; }"
  , ".legend .sw { width:1.6rem; height:.55rem; border-radius:2px; display:inline-block; }"
  -- bar lists are plain HTML: easier to read by screen reader than a chart
  , ".bars { display:flex; flex-direction:column; gap:.35rem; }"
  , ".bars .row { display:grid; grid-template-columns:minmax(7rem, 38%) 1fr auto; gap:.5rem; align-items:center; font-size:.85rem; }"
  , ".bars .name { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }"
  , ".bars .track { background:var(--code); border-radius:3px; height:.7rem; overflow:hidden; }"
  , ".bars .fill { height:100%; border-radius:3px; background:var(--cat-1); }"
  -- opened and solved as a stacked pair on one scale: nesting one inside
  -- the other reads as two abutting segments, which is the wrong quantity
  , ".pairtrack { display:flex; flex-direction:column; gap:2px; }"
  , ".pairtrack .t { background:var(--code); border-radius:2px; height:.42rem; overflow:hidden; }"
  , ".pairtrack .t .f { height:100%; border-radius:2px; }"
  , ".pairtrack .t .f.opened { background:var(--cat-1); } .pairtrack .t .f.solved { background:var(--ok); }"
  , ".bars .fill.b { background:var(--cat-2); } .bars .fill.c { background:var(--cat-3); }"

  , ".bars .n { color:var(--muted); font-variant-numeric:tabular-nums; }"
  , ".keys { display:flex; gap:.9rem; font-size:.75rem; color:var(--muted); margin-bottom:.5rem; flex-wrap:wrap; }"
  , ".keys .k { display:inline-flex; align-items:center; gap:.3rem; }"
  , ".keys .sw { width:.7rem; height:.7rem; border-radius:2px; display:inline-block; }"
  , ".dash-foot { color:var(--muted); font-size:.8rem; margin-top:1.2rem; }"
  , "@media (prefers-reduced-motion: reduce) { .dash * { transition:none !important; } }"
  ]
