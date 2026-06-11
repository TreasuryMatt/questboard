"""
Questboard desktop launcher.

Runs the FastAPI backend AND serves the built frontend from a single local
process, then opens the kids' default browser. This is the entry point for the
standalone macOS .app build (see ../Questboard.spec).

The Docker/nginx deployment keeps using main.py directly and is unaffected by
this file: here we simply mount that same `app` under /api and serve the static
frontend alongside it, so there is no nginx and no second process.
"""
import os
import socket
import sys
import threading
import time
import webbrowser
from pathlib import Path

HOST = "127.0.0.1"
PORT = int(os.environ.get("QUESTBOARD_PORT", "5050"))


def _resource_dir() -> Path:
    """Directory holding bundled resources (the built frontend)."""
    # PyInstaller unpacks bundled data under sys._MEIPASS at runtime.
    if getattr(sys, "_MEIPASS", None):
        return Path(sys._MEIPASS)
    # Running from source: repo root is one level up from backend/.
    return Path(__file__).resolve().parent.parent


def _default_data_dir() -> Path:
    # Outside the .app so game progress survives every update.
    return Path.home() / "Library" / "Application Support" / "Questboard"


def _open_when_ready(url: str) -> None:
    """Wait for the server to accept connections, then open the browser."""
    for _ in range(60):  # up to ~30s
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(0.5)
            if s.connect_ex((HOST, PORT)) == 0:
                webbrowser.open(url)
                return
        time.sleep(0.5)


def main() -> None:
    os.environ.setdefault("QUESTBOARD_DATA", str(_default_data_dir()))
    os.makedirs(os.environ["QUESTBOARD_DATA"], exist_ok=True)

    # Import only AFTER QUESTBOARD_DATA is set: main.py reads it at import time.
    from fastapi import FastAPI
    from fastapi.staticfiles import StaticFiles
    import uvicorn
    from main import app as api_app

    dist = _resource_dir() / "frontend" / "dist"
    if not dist.is_dir():
        sys.exit(
            f"Frontend build not found at {dist}.\n"
            "Build it first:  cd frontend && npm ci && npm run build"
        )

    root = FastAPI()
    # The frontend calls /api/* ; mounting the existing API as a sub-app at
    # /api strips that prefix, so /api/state reaches the backend's /state.
    root.mount("/api", api_app)
    # html=True serves index.html at / for the single-page app.
    root.mount("/", StaticFiles(directory=str(dist), html=True), name="frontend")

    url = f"http://{HOST}:{PORT}/"
    threading.Thread(target=_open_when_ready, args=(url,), daemon=True).start()
    print(f"Questboard running at {url}  (close this window to quit)")
    uvicorn.run(root, host=HOST, port=PORT, log_level="warning")


if __name__ == "__main__":
    main()
