-- | The one stylesheet, injected from headW (mainWidgetWithHead replaces the
-- document head, so index.html cannot carry it).
module Style (appCss) where

import           Data.Text (Text)
import qualified Data.Text as T

appCss :: Text
appCss = T.unlines
  [ ":root { color-scheme:dark; --bg:#15191f; --ink:#e6eaf0; --muted:#adb8c6; --line:#485463; --accent:#8cc8ff; --accent-ink:#101820; --ok:#8ddd9a; --warn:#f4cd75; --err:#ffa2aa; --hole:#51451d; --card:#1d242d; --code:#242d38; --locked:#738195; --skeleton:#394454; --selection:#38618a; --keyword:#f4cd75; --type:#8cc8ff; --function:#89d5e5; --literal:#dbb0f6; --field:#ffa7d1; --error-bg:#45272e; --success-bg:#203d2b; --warning-bg:#403719; --active:#2b4158; --glow:rgba(140,200,255,.13); }"
  , ":root[data-theme=light] { color-scheme:light; --bg:#fbfaf7; --ink:#1d1d1b; --muted:#60605a; --line:#c9c5ba; --accent:#245f8a; --accent-ink:#fff; --ok:#246a28; --warn:#805000; --err:#b12222; --hole:#fff3b0; --card:#fff; --code:#f4f2ec; --locked:#969286; --skeleton:#e0dcd0; --selection:#bcd7ee; --keyword:#805300; --type:#1a5fb4; --function:#1f6f8b; --literal:#812098; --field:#a31151; --error-bg:#fde3e3; --success-bg:#e3f4e4; --warning-bg:#fff6d6; --active:#e8f1f8; --glow:rgba(36,95,138,.10); }"
  , "button, input, select { color:var(--ink); background:var(--card); } :focus-visible { outline:2px solid var(--accent); outline-offset:3px; } .editor-wrap:focus-within { border-color:var(--accent); box-shadow:0 0 0 2px var(--accent); } summary { cursor:pointer; } .worked-example { margin-top:1rem; } ::selection { background:var(--selection); }"
  , "html, body { margin:0; background:var(--bg); color:var(--ink); font-family:'IBM Plex Sans', system-ui, sans-serif; font-size:15px; line-height:1.5; }"
  , "a { color:var(--accent); text-decoration:none; } a:hover { text-decoration:underline; }"
  , "code, pre, textarea, .mono { font-family:'JuliaMono', 'DejaVu Sans Mono', ui-monospace, monospace; font-size:14px; }"
  , "h1, h2, h3 { font-family:'Space Grotesk', 'IBM Plex Sans', sans-serif; letter-spacing:-0.01em; margin:0 0 .4em; }"
  , "header.top { display:flex; align-items:center; gap:1rem; padding:.6rem 1.2rem; border-bottom:1px solid var(--line); background:var(--card); position:sticky; top:0; z-index:5; }"
  , "header.top .brand { font-family:'Space Grotesk'; font-weight:700; font-size:1.15rem; color:var(--ink); }"
  , "header.top nav a { margin-right:1rem; }"
  , "header.top .spacer { flex:1; }"
  , "header.top select { font:inherit; padding:.2rem .4rem; }"
  , "main { padding:1.2rem; max-width:1500px; margin:0 auto; }"
  , ".card { background:var(--card); border:1px solid var(--line); border-radius:10px; padding:1rem 1.2rem; }"
  , ".muted { color:var(--muted); }"
  , ".prose p { margin:.5em 0; } .prose pre { background:var(--code); padding:.6rem .8rem; border-radius:6px; overflow-x:auto; }"
  , ".prose code { background:var(--code); padding:.05em .3em; border-radius:4px; }"
  , ".prose pre code { background:none; padding:0; }"
  , ".prose blockquote { border-left:3px solid var(--line); margin:.6em 0; padding:.1em .8em; color:var(--muted); }"
  -- world map
  , ".map svg { width:100%; height:auto; display:block; }"
  , ".map .edge { stroke:var(--line); stroke-width:2; fill:none; }"
  , ".map .node circle { stroke:var(--card); stroke-width:3; }"
  , ".map .node text { font-family:'IBM Plex Sans'; font-size:13px; fill:var(--ink); text-anchor:middle; }"
  , ".map .node .count { font-size:11px; fill:var(--muted); }"
  , ".map .node.done circle { fill:var(--ok); } .map .node.open circle { fill:var(--accent); } .map .node.locked circle { fill:var(--locked); } .map .node.skeleton circle { fill:var(--skeleton); stroke:var(--line); }"
  , ".map .node:hover circle { filter:brightness(1.1); }"
  -- world page
  , ".levels { list-style:none; padding:0; margin:0; } .levels li { padding:.45rem 0; border-bottom:1px solid var(--line); display:flex; gap:.8rem; align-items:baseline; }"
  , ".levels .idx { color:var(--muted); width:2.2rem; } .levels .done { color:var(--ok); } .levels .langs { margin-left:auto; color:var(--muted); font-size:.85rem; }"
  -- level page
  , ".level { display:grid; grid-template-columns: minmax(280px, 1fr) minmax(420px, 1.5fr) minmax(300px, 1fr); gap:1rem; align-items:start; }"
  , "@media (max-width: 1100px) { .level { grid-template-columns: 1fr; } }"
  -- the explanation and the conclusion span every column; the working
  -- aids, the editor and the prover panel share the row between them
  , ".level-intro, .conclusion { grid-column: 1 / -1; }"
  , ".level-intro h2 { text-align:center; margin:.2rem 0 .7rem; }"
  -- verified pair: --warn on --warning-bg is contrast-checked
  , ".spoiler-tag { margin-left:.5rem; font-size:.7rem; text-transform:uppercase; letter-spacing:.08em; padding:.05rem .4rem; border-radius:4px; background:var(--warning-bg); color:var(--warn); }"
  , ".spoiler-note { color:var(--muted); font-size:.9rem; }"
  , ".level h2 { font-size:1.3rem; } .level .goals-title { font-size:.8rem; text-transform:uppercase; letter-spacing:.08em; color:var(--muted); margin:.8rem 0 .3rem; }"
  , ".statement { background:var(--code); border-radius:6px; padding:.6rem .8rem; white-space:pre; overflow-x:auto; margin:0 0 .6rem; }"
  , ".editor-wrap { position:relative; border:1px solid var(--line); border-radius:6px; background:var(--card); overflow:hidden; }"
  , ".editor-wrap textarea, .editor-wrap pre.overlay { margin:0; padding:.6rem .8rem; border:0; width:100%; min-height:16em; box-sizing:border-box; white-space:pre; overflow:auto; line-height:1.45; tab-size:4; }"
  , ".editor-wrap textarea { position:relative; background:transparent; color:transparent; caret-color:var(--ink); resize:vertical; outline:none; z-index:2; }"
  , ".editor-wrap textarea::selection { background:var(--selection); color:var(--ink); }"
  , ".editor-wrap pre.overlay { position:absolute; inset:0; z-index:1; pointer-events:none; color:var(--ink); overflow:hidden; }"
  , ".editor-status { display:flex; gap:1rem; font-size:.85rem; color:var(--muted); padding:.3rem .2rem; min-height:1.4em; }"
  , ".editor-status .im { color:var(--accent); }"
  -- agda highlighting atoms
  , ".hl-keyword { color:var(--keyword); } .hl-symbol { color:var(--muted); } .hl-primitivetype, .hl-datatype, .hl-record { color:var(--type); }"
  , ".hl-function { color:var(--function); } .hl-inductiveconstructor, .hl-coinductiveconstructor { color:var(--ok); } .hl-bound { color:var(--ink); }"
  , ".hl-string, .hl-number { color:var(--literal); } .hl-comment { color:var(--muted); font-style:italic; } .hl-module { color:var(--literal); } .hl-operator { color:var(--function); }"
  , ".hl-hole { background:var(--hole); } .hl-error { text-decoration:underline wavy var(--err); background:var(--error-bg); } .hl-unsolvedmeta { background:var(--hole); } .hl-postulate { color:var(--err); }"
  , ".hl-field { color:var(--field); } .hl-argument { color:var(--ink); } .hl-macro { color:var(--function); } .hl-generalizable { color:var(--ink); }"
  , ".hl-terminationproblem, .hl-coverageproblem, .hl-positivityproblem { background:var(--error-bg); }"
  -- commands and panels
  , ".commands { display:flex; flex-wrap:wrap; gap:.4rem; margin:.6rem 0; }"
  -- Reset sits apart from the prover commands: it is destructive and
  -- client-side. Border only, so theme contrast is unaffected.
  , ".commands button.reset { margin-left:auto; } .commands button.reset:hover { border-color:var(--err); }"
  , "button { font:inherit; font-size:.9rem; padding:.35rem .7rem; border-radius:6px; border:1px solid var(--line); background:var(--card); cursor:pointer; }"
  , "button:hover { border-color:var(--accent); } button.primary { background:var(--accent); color:var(--accent-ink); border-color:var(--accent); }"
  , "button:disabled { opacity:.45; cursor:default; }"
  , ".expr { display:flex; gap:.4rem; margin:.4rem 0; } .expr input { flex:1; font:inherit; padding:.35rem .5rem; border:1px solid var(--line); border-radius:6px; }"
  , ".verdict { padding:.5rem .8rem; border-radius:6px; margin:.5rem 0; font-weight:600; }"
  , ".verdict.solved { background:var(--success-bg); color:var(--ok); } .verdict.unsolved { background:var(--warning-bg); color:var(--warn); } .verdict.failed, .verdict.rejected { background:var(--error-bg); color:var(--err); } .verdict.idle { background:var(--code); color:var(--muted); font-weight:400; }"
  , ".holes button { margin:.15rem .3rem .15rem 0; } .holes button.sel { border-color:var(--accent); background:var(--active); }"
  , ".goal { background:var(--code); border-radius:6px; padding:.5rem .7rem; white-space:pre-wrap; word-break:break-word; }"
  , ".goal .ctx { color:var(--muted); } .goal .sep { border-top:1px solid var(--line); margin:.3rem 0; } .goal .ty { font-weight:600; }"
  , ".diag { border-left:3px solid var(--line); padding:.2rem .6rem; margin:.3rem 0; white-space:pre-wrap; word-break:break-word; font-size:.9rem; }"
  , ".diag.error { border-color:var(--err); } .diag.warning { border-color:var(--warn); } .diag.info { border-color:var(--accent); }"
  , ".hints .hint { border-left:3px solid var(--accent); padding:.2rem .7rem; margin:.4rem 0; }"
  , ".conclusion { border-top:2px solid var(--ok); margin-top:1rem; padding-top:.6rem; }"
  , ".inventory .item { padding:.5rem 0; border-bottom:1px solid var(--line); } .inventory .kind { font-size:.75rem; text-transform:uppercase; color:var(--muted); letter-spacing:.06em; }"
  , ".inventory summary { cursor:pointer; }"
  , ".pill { display:inline-block; font-size:.75rem; padding:.05rem .45rem; border-radius:999px; background:var(--code); color:var(--muted); margin-left:.3rem; }"
  , ".pill.on { background:var(--active); color:var(--accent); }"
  , ".nav-row { display:flex; gap:1rem; align-items:center; margin-bottom:.8rem; }"
  , ".unavailable { background:var(--error-bg); color:var(--err); padding:.6rem .8rem; border-radius:6px; }"
  , ".kbd { font-family:'JuliaMono', monospace; font-size:.8em; background:var(--code); padding:.05em .35em; border-radius:4px; border:1px solid var(--line); }"
  -- Support page. The one page meant to stop a reader, so it does not wear
  -- the level chrome: its own type scale, a hero, and a decorative
  -- computational path whose last rung is left open.
  , ".donate { max-width:1100px; margin:0 auto; }"
  , ".donate-hero { position:relative; overflow:hidden; display:flex; flex-wrap:wrap; align-items:center; gap:1.4rem 2.5rem; border:1px solid var(--line); border-radius:14px; background:var(--card); padding:clamp(1.8rem,4vw,3rem) clamp(1.2rem,3.5vw,3rem); margin:.2rem 0 1.6rem; }"
  , ".donate-hero::after { content:''; position:absolute; inset:0; z-index:0; background:radial-gradient(85% 130% at 8% -25%, var(--glow), transparent 60%); pointer-events:none; }"
  , ".hero-motif { position:relative; z-index:1; flex:1 1 19rem; min-width:0; pointer-events:none; }"
  , ".hero-motif svg { width:100%; height:auto; display:block; overflow:visible; }"
  , "@media (max-width: 720px) { .hero-motif { display:none; } }"
  , ".hero-motif .rung { fill:none; stroke:var(--line); stroke-width:2; }"
  -- the unresolved rung: the page's whole argument, in one dashed curve
  , ".hero-motif .rung.open { stroke:var(--accent); stroke-dasharray:5 9; stroke-linecap:round; }"
  , ".hero-motif .node { fill:var(--line); } .hero-motif .node.last { fill:var(--accent); }"
  , ".hero-text { position:relative; z-index:1; flex:1 1 27rem; min-width:0; }"
  , ".donate-hero h1 { font-size:clamp(1.9rem,5vw,3.4rem); line-height:1.05; letter-spacing:-0.035em; margin:0 0 .45em; }"
  , ".donate-hero h1 .accented { color:var(--accent); }"
  , ".donate-hero .lede { max-width:46ch; font-size:1.08rem; color:var(--muted); margin:0; }"
  , ".chains { display:grid; grid-template-columns:repeat(auto-fit, minmax(290px, 1fr)); gap:1rem; }"
  , ".chain { background:var(--card); border:1px solid var(--line); border-radius:14px; padding:1.1rem 1.2rem 1rem; display:flex; flex-direction:column; gap:.75rem; transition:border-color .18s ease, transform .18s ease; }"
  , ".chain:hover { border-color:var(--accent); transform:translateY(-2px); }"
  , ".chain-head { display:flex; align-items:baseline; gap:.5rem; flex-wrap:wrap; }"
  , ".chain-head h2 { font-size:1.2rem; margin:0; }"
  , ".chain .tokens { display:flex; gap:.3rem; flex-wrap:wrap; margin-left:auto; }"
  , ".chain .token { font-size:.68rem; text-transform:uppercase; letter-spacing:.07em; padding:.1rem .45rem; border-radius:999px; background:var(--code); color:var(--muted); }"
  -- A QR must stay dark on light to scan: the white tile is deliberate in
  -- both themes and is the one place a literal colour is correct.
  , ".chain .qr { background:#fff; border:1px solid var(--line); border-radius:10px; padding:.6rem; align-self:center; line-height:0; }"
  , ".chain .qr img { width:190px; max-width:100%; height:auto; display:block; }"
  , ".chain .addr { display:flex; align-items:flex-start; gap:.5rem; }"
  , ".chain .addr code { flex:1; min-width:0; font-size:.72rem; line-height:1.45; word-break:break-all; background:var(--code); padding:.45rem .55rem; border-radius:6px; }"
  , "button.copy { flex:0 0 auto; align-self:flex-start; } button.copy.done { border-color:var(--ok); color:var(--ok); }"
  , ".chain .chain-foot { margin-top:auto; min-height:1.3em; } .chain .wallet { font-size:.85rem; }"
  , ".chain.loading { min-height:22rem; border-style:dashed; background:none; }"
  , ".donate-note { margin:1.3rem 0 0; padding:.6rem .8rem; border-radius:6px; background:var(--warning-bg); color:var(--warn); font-size:.9rem; }"
  -- one orchestrated reveal rather than scattered micro-interactions
  , ".chains .chain { animation:rise .5s cubic-bezier(.2,.7,.3,1) backwards; animation-delay:calc(var(--i, 0) * 70ms); }"
  , "@keyframes rise { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:none; } }"
  , "@media (prefers-reduced-motion: reduce) { .chains .chain { animation:none; } .chain:hover { transform:none; } }"
  -- the single call to action in the chrome; a.primary does not exist, and
  -- this must read as a button rather than a fourth nav link
  , "header.top a.support { font-weight:600; font-size:.85rem; padding:.28rem .85rem; border-radius:999px; background:var(--accent); color:var(--accent-ink); border:1px solid var(--accent); }"
  , "header.top a.support:hover { text-decoration:none; filter:brightness(1.08); }"
  , "@media (max-width: 760px) { header.top { flex-wrap:wrap; gap:.4rem .7rem; padding:.5rem .8rem; } header.top .brand { white-space:nowrap; font-size:1.05rem; } header.top .spacer { flex-basis:100%; height:0; } header.top nav a { margin-right:.9rem; } header.top label[for=language] { position:absolute; width:1px; height:1px; overflow:hidden; clip-path:inset(50%); white-space:nowrap; } }"
  ]
