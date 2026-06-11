# Questboard Changes

A running log of completed changes, ordered most-recent first.

---

## 2026-06-11

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
