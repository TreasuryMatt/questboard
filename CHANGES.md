# Questboard Changes

A running log of completed changes, ordered most-recent first.

---

## 2026-06-11

### Distinct pixel icons + readable hamburger glyph for the header menu

- The secondary toolbar items (Settings/Reset week/Export Save/Import Save) all shared tile 115 (red potion). Gave each a distinct, thematic tilemap icon: Settings = control panel (65), Reset week = scroll (56), Export Save = open chest (91), Import Save = closed chest (89). Applied to both the Epic hamburger dropdown and the inline toolbar at other scales.
- `frontend/src/App.jsx` — the `☰` glyph wasn't in the pixel font (rendered as a tofu box), so replaced it with a CSS-drawn three-bar hamburger (`<span className="hamburger" />`).
- `frontend/src/index.css` — added `.hamburger` bar styling via `::before`/`::after`.
- Verified with `npm run build`; rebuilt Docker, live at `http://localhost:3062`.

### Collapse header toolbar into a hamburger at Epic scale

- At Epic UI scale (1.75×) the secondary toolbar (Sound/Settings/Reset week/Export Save/Import Save) overflowed the viewport and the Bounties tab wrapped to two lines.
- `frontend/src/App.jsx` — added an `isEpic` flag; on Epic the five secondary buttons collapse into a single `☰` hamburger that opens a dropdown (`menuOpen` state, with an outside-click/Escape close handler). Heroic and Mini keep the full inline toolbar.
- `frontend/src/index.css` — added `.header-menu`/`.menu-toggle`/`.header-dropdown` styles; added `white-space: nowrap` to `.tab` so Bounties no longer wraps.
- Verified with `npm run build` (passes). Docker rebuild needed to see it live at `http://localhost:3062`.

### Merge upstream (thillygooth/questboard) — 28 commits

- Pulled the original author's recent work into the fork via `git merge upstream/main`. Notable additions: bounty board, portrait/fridge display mode, configurable week-start day, state backup/restore (export/import), edit player name/class after setup, optional chore tap confirmation, level-gated monster rebalance, mute toggle, animated-background toggle, history timestamps, CC BY-NC 4.0 license, README/deploy-script updates.
- Conflict resolutions:
  - `PlayerCard.jsx` — kept our `MONSTER_SPRITES` refactor; merged our sprite `filter` with upstream's `margin: 0 auto` centering on the static-`img` monster branch; removed a duplicate `MONSTER_SPRITES` import left by the auto-merge (it broke the Vite build).
  - `index.css` — kept upstream's new portrait + bounty styles, but dropped the `body.scale-heroic/epic { zoom }` rules it re-introduced (our earlier "zoom content only, not the background" fix removed those on purpose).
  - `frost_knight.png` — kept our version of the class icon.
- Verified with `npm run build` (passes). Docker rebuild still needed to see it live at `http://localhost:3062`.

### Fix settings menu unscrollable at non-mini UI scales

- `frontend/src/App.jsx` — the setup/settings overlay (`SetupWizard`, a full-screen `position: fixed` modal capped at `maxHeight: 90vh`) was rendered inside the `zoom: uiZoom` UI-scale wrapper. CSS `zoom` multiplies `vh` units, so at Heroic (1.25×)/Epic (1.75×) the overlay grew taller than the viewport — the footer (Save) sat below the screen and the header (close) above it, with nowhere to scroll to reach them. Mini worked only because its zoom is 1.
- Moved both the `needsSetup` and `showSettings` branches to render the modal outside the zoom wrapper, so it always renders at true scale and scrolls correctly. Trade-off: settings text no longer grows at Heroic/Epic.
- Rebuilt Docker; verified live at `http://localhost:3062`

### Fix enemy sprites all showing as the green blob

- `frontend/src/components/PlayerCard.jsx` — removed the stale, partial local `MONSTER_CFG` sprite table (only had the ~40 `monsters2` sprites) and switched to the canonical `MONSTER_SPRITES` from `monsterSprites.js`, which covers the full 90+ roster. Every `mcf`/`st04` monster was previously falling through to the `green_slime` fallback.
- Added `type: 'img'` handling so the static `st04` PNGs render as an `<img>` (the shared `MonsterSprite` component only draws animated sprite-strips).
- Rebuilt Docker; verified live at `http://localhost:3062`

### Move frontend Docker host port from 3000 to 3062

- `docker-compose.yml` — changed host mapping from `3000:3000` to `3062:3000`
- `frontend/nginx.conf` — restored missing `/api/` proxy block to `backend:5050` (was lost from the repo; the running container had it, but a rebuild without it would have broken all API calls since the frontend uses a relative `/api` path)
- App verified live at `http://localhost:3062`
