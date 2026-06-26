# Questboard Changes

A running log of completed changes, ordered most-recent first.

---

## 2026-06-26

### Hide the midnight penalty text when a player's penalties are paused

- The player card always showed `💀 -Ng at midnight`, even for players with **Pause gold penalties** checked — misleading, since the overnight strike is skipped for them (`App.jsx` already guards on `pl.paused`).
- `frontend/src/components/PlayerCard.jsx` — when `player.paused` is set, the card now renders `⏸️ penalties paused` (class `atk-penalty--paused`) instead of the gold-loss warning.
- Verified with `npm run build`; rebuilt Docker, live at `http://localhost:3062`.

### Manually set a player's gold in Edit Settings

- Added a **Gold** number field to **Edit Settings → Party**, inside each player's expanded row, directly below the "Pause gold penalties" checkbox.
- Gold isn't stored on the player object — it lives in `serverState.gold` (a `{ playerId: amount }` map). Rather than add a new endpoint or write live, the edit is threaded through the existing save path so it only commits when you hit **Save**, like every other setting in that panel.
- `frontend/src/components/SetupWizard.jsx` — new `initialGold` prop and a `goldEdits` draft map; the field is pre-filled with current gold, clamps to whole numbers ≥ 0, and is passed to `TabParty`. `goldEdits` rides along on the object handed to `onComplete`.
- `frontend/src/App.jsx` — pass `initialGold={serverState?.gold}` into the edit-mode `SetupWizard`; in `handleEditComplete`, strip `goldEdits` out before persisting config (it belongs in state, not config) and overlay the sanitized values onto the surviving gold map. Combat, rewards, and overnight penalties are untouched — they still read `serverState.gold` as before.
- Verified with `npm run build`; rebuilt Docker, live at `http://localhost:3062`.

### Multi-account system (per-household settings + data)

- Questboard was single-tenant: the backend read/wrote two global files (`state.json`, `config.json`) with no notion of who was asking. Added an **account** layer so multiple households can share one deployment, each with isolated config and game state.
- **Backend** (`backend/main.py`) — replaced JSON-file storage with **SQLite** (`questboard.db`), stdlib only (`sqlite3`/`hashlib`/`secrets`, no new dependency). New `accounts` table (name, optional PBKDF2-hashed PIN, per-account `config`/`state` JSON) and `sessions` table (random bearer tokens). New endpoints: `GET/POST /accounts`, `POST /accounts/{id}/login`, `GET/POST /account` (read/rename current), `DELETE /account`, `POST /logout`. The existing `/config` and `/state` are now scoped to the caller's session via an `Authorization: Bearer` header. On first startup, legacy `state.json`/`config.json` auto-migrate into a single "My Family" account (old files kept as backup).
- **Frontend** — new `frontend/src/api.js` (token storage + `apiFetch`/`apiPost`, bounces to the picker on 401); new `frontend/src/components/AccountGate.jsx` (pick household / create / optional PIN entry). `frontend/src/App.jsx` now gates on auth, routes all fetches through `apiFetch`, and adds Rename / Switch / Delete account items to both header menus (delete requires typing the account name to confirm).
- Verified backend endpoints (creation, isolation, PIN, logout/delete invalidation, migration) via FastAPI TestClient; `npm run build` passes; rebuilt Docker, live at `http://localhost:3062`.

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
