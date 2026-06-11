# -*- mode: python ; coding: utf-8 -*-
# PyInstaller recipe that bundles the desktop launcher, the FastAPI backend and
# the built frontend into a single double-clickable Questboard.app.
#
# Build (from the repo root, after building the frontend):
#     cd frontend && npm ci && npm run build && cd ..
#     pip install -r backend/requirements.txt pyinstaller
#     pyinstaller --noconfirm --clean Questboard.spec
#
# The CI workflow (.github/workflows/build-mac-app.yml) runs this on an Intel
# macos-13 runner so the result launches on Big Sur (macOS 11) Intel Macs.
import os
from PyInstaller.utils.hooks import collect_submodules

# uvicorn loads loops/protocols dynamically; pull in all its submodules so the
# frozen app can find them.
hiddenimports = collect_submodules("uvicorn") + ["main"]

_version = os.environ.get("QUESTBOARD_VERSION", "1.12.0")

a = Analysis(
    ["backend/desktop.py"],
    pathex=["backend"],            # so `from main import app` resolves
    binaries=[],
    datas=[("frontend/dist", "frontend/dist")],
    hiddenimports=hiddenimports,
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name="Questboard",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=False,                 # windowed app, no terminal window
    target_arch="x86_64",          # Intel
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=False,
    name="Questboard",
)

app = BUNDLE(
    coll,
    name="Questboard.app",
    icon=None,
    bundle_identifier="com.questboard.app",
    info_plist={
        "CFBundleShortVersionString": _version,
        "CFBundleVersion": _version,
        "LSMinimumSystemVersion": "11.0",
        "NSHighResolutionCapable": True,
    },
)
