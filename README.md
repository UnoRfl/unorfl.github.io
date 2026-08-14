# unorfl.github.io

Personal portfolio for **Juan Rafael — codename Uno**. Single `index.html`, no framework, no build step, no npm.

## Deploy to GitHub Pages (root user page)

A repo named exactly `unorfl.github.io` is served by GitHub as your root user page at `https://unorfl.github.io/`.

### 1. Create the repo

Go to https://github.com/new and create a **public** repo named exactly:

```
unorfl.github.io
```

Do **not** tick "Add a README" / `.gitignore` / license — leave it empty so the first push isn't rejected.

### 2. Push from this folder

```bash
git init
git add index.html README.md
git commit -m "initial: portfolio v1"
git branch -M main
git remote add origin https://github.com/UnoRfl/unorfl.github.io.git
git push -u origin main
```

### 3. Turn on Pages

1. `https://github.com/UnoRfl/unorfl.github.io/settings/pages`
2. **Build and deployment → Source** → **Deploy from a branch**
3. Branch `main` · Folder `/ (root)` → **Save**

First build takes ~1–2 minutes, then it's live at `https://unorfl.github.io/`.

### Updating later

```bash
git add index.html
git commit -m "tweak: <what changed>"
git push
```

Pages redeploys automatically on every push to `main`.

---

## What's in it

**Sections:** hero → live GitHub stats → contribution heatmap → featured project (Orbit) → all repos → stack → contact.

**Live data** (all `fetch()`, all in try/catch with skeleton loaders, all cached in `localStorage` for 10 minutes so you stay under GitHub's 60-req/hr unauthenticated limit):

| Section | Endpoint |
|---|---|
| Stats grid | `api.github.com/users/UnoRfl` |
| Heatmap | `github-contributions-api.jogruber.de/v4/UnoRfl?y=last` |
| All repos | `api.github.com/users/UnoRfl/repos?sort=updated&per_page=30` (forks filtered out) |

The top ticker is **decorative only** — no API call, just styled telemetry strings. Edit the `lines` array in the `ticker()` block to change what it says.

**Aurora background** — three large, soft radial-gradient blobs drifting behind everything on long, deliberately mismatched cycles (41s / 53s / 67s) so they never visibly resync. There is no canvas and no JavaScript: each blob is rasterised once and only its `transform` animates, so the whole thing lives on the compositor and never touches the main thread.

Two things matter if you edit it:

- **Translate only, never `scale()`.** Scaling a layer this large forces a re-raster every frame. Pure translation reuses one cached texture forever.
- **Sizes are capped** (`clamp(480px, 72vmax, 760px)`), not pure `vmax`. These layers composite over the whole viewport every frame, so their *area* is the cost — uncapped they grew past 1100px on a desktop and pulled the page to ~40fps. Capped, it sits at a solid 60.

The cursor glow is a static gradient moved with `translate3d`, for the same reason: transform-only means it composites rather than repaints. The aurora also leans a few pixels away from the pointer — one CSS variable, one transform.

Replacing the old animated contour field with this cut main-thread time to almost nothing:

| | idle | while scrolling |
|---|---|---|
| Desktop | 798ms → **25ms** | 1881ms → **300ms** |
| Mobile @3x | 616ms → **20ms** | 824ms → **399ms** |

Idle is now ~0.6% of the main thread; what remains while scrolling is the 3D tilt, which is the effect itself.

**Scroll depth** — every panel is tilted on `rotateX` by its distance from the centre of the viewport: sections rising from the bottom lean back like a floor, sections leaving the top lean forward like a ceiling. Driven continuously by scroll position (rAF-throttled, no layout reads — geometry is measured once and cached).

**Decode** — the name resolves out of scrambled characters, left to right, on load and again on hover. Each letter is its own `inline-block` span pinned to the width of its final glyph, so swapping characters 20× a second never reflows the line by a pixel. Unresolved characters render in neon purple and flash once as they lock.

Two implementation notes if you touch it:

- The scramble charset is deliberately **dense glyphs only** (`ABCDEFGHKMNOPQRSUVWXYZ0234568#&@%$`). Thin characters like `I`, `J`, `1`, `/` sit centred in a wide pinned box and read as gaps in the word.
- The gradient fill lives on **each character**, not on the line. Chrome rasterises a `background-clip: text` fill against the text shape and does not reliably re-clip it when a descendant text node changes — with the fill on the parent, already-locked letters would vanish mid-decode. Per-character output is identical (the ramp is vertical, every character shares a baseline) and each span invalidates its own fill.

**Accessibility / safety**
- `prefers-reduced-motion` kills the aurora drift, scanlines, cursor glow, ticker scroll, pulse, decode and 3D tilt — the name renders settled immediately
- No inline event handlers — everything is `addEventListener`
- All GitHub text is escaped through an `E()` helper before being injected
- Semantic HTML, visible keyboard focus, collapses to one column under 720px

## Things you may want to edit

- **Stack lists** — `LANGS` and `TOOLS` arrays near the bottom of the script.
- **Featured project** — the single `<article class="proj">` block in the HTML. Duplicate it and wrap both in a 2-column grid if you add a second one later.
- **Ticker copy** — the `lines` array in the `ticker()` IIFE.
- **Aurora colours** — the three `radial-gradient` stops on `.a1` / `.a2` / `.a3`.
- **Contact** — GitHub, `Improvised30@gmail.com`, and Discord `teluks` (click-to-copy) are already wired up.

## Notes

- Open `index.html` directly in a browser to preview. The GitHub fetches will fail on `file://` because of CORS — that's expected, the fallbacks show "offline". They work fine once served over https from Pages.
- Google Fonts (Space Grotesk, Inter, JetBrains Mono) load from the CDN on first visit, then browser-cached.
- The heatmap uses a public proxy because GitHub's official contribution calendar is only available through the authenticated GraphQL API.
