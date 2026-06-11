# Questboard Changes

A running log of completed changes, ordered most-recent first.

---

## 2026-06-11

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
