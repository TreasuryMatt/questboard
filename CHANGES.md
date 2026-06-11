# Questboard Changes

A running log of completed changes, ordered most-recent first.

---

## 2026-06-11

### Move frontend Docker host port from 3000 to 3062

- `docker-compose.yml` — changed host mapping from `3000:3000` to `3062:3000`
- `frontend/nginx.conf` — restored missing `/api/` proxy block to `backend:5050` (was lost from the repo; the running container had it, but a rebuild without it would have broken all API calls since the frontend uses a relative `/api` path)
- App verified live at `http://localhost:3062`
