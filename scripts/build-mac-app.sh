#!/usr/bin/env bash
#
# Build and publish the standalone Intel macOS Questboard.app, then attach it to
# a GitHub release. This is the working replacement for the (dead) macos-13 CI
# build — see DEPLOY-MAC.md.
#
# Run it ON a Mac, from anywhere in the repo:
#     ./scripts/build-mac-app.sh            # version from frontend/package.json
#     ./scripts/build-mac-app.sh 1.12.2     # explicit version
#
# Apple Silicon Macs need Rosetta (one-time):  softwareupdate --install-rosetta
#
set -euo pipefail

# ---- config ---------------------------------------------------------------
PYBUILD_DATE="20260610"          # python-build-standalone release tag
PYVER="3.11.15"                  # CPython version in that release
# ---------------------------------------------------------------------------

# repo root (this script lives in scripts/)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Publish to the 'origin' fork, not whatever gh picks as default (it may choose
# the upstream). Derive owner/repo from the origin remote URL.
REPO="${QB_REPO:-$(git remote get-url origin | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')}"

# Version: arg 1, else frontend/package.json. Strip any leading 'v'.
VERSION="${1:-$(node -p "require('./frontend/package.json').version")}"
VERSION="${VERSION#v}"
TAG="v$VERSION"

echo "==> Building Questboard.app $TAG  →  $REPO"

# 1) Frontend ---------------------------------------------------------------
echo "==> [1/5] Building frontend"
( cd frontend && npm ci --no-audit --no-fund && npm run build )

# 2) Portable x86_64 Python -------------------------------------------------
B="$(mktemp -d)/qb"; mkdir -p "$B"
URL="https://github.com/astral-sh/python-build-standalone/releases/download/${PYBUILD_DATE}/cpython-${PYVER}+${PYBUILD_DATE}-x86_64-apple-darwin-install_only.tar.gz"
echo "==> [2/5] Fetching portable Python (x86_64)"
curl -fsSL "$URL" -o "$B/py.tar.gz"
tar xzf "$B/py.tar.gz" -C "$B"        # creates $B/python
PY="$B/python/bin/python3"

# 3) Backend deps as x86_64 macOS wheels (runs via Rosetta on Apple Silicon) -
echo "==> [3/5] Installing backend deps (x86_64)"
"$PY" -m pip install --quiet --upgrade pip
"$PY" -m pip install --quiet fastapi uvicorn
"$PY" -c "import fastapi,uvicorn; print('    deps ok', fastapi.__version__, uvicorn.__version__)"

# 4) Assemble the .app bundle ----------------------------------------------
echo "==> [4/5] Assembling Questboard.app"
APP="$B/Questboard.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/app" "$APP/Contents/Resources/frontend"
cp -R "$B/python"               "$APP/Contents/Resources/python"
cp "$ROOT/backend/main.py" "$ROOT/backend/desktop.py" "$APP/Contents/Resources/app/"
cp -R "$ROOT/frontend/dist"     "$APP/Contents/Resources/frontend/dist"

cat > "$APP/Contents/MacOS/Questboard" <<'LAUNCH'
#!/bin/bash
HERE="$(cd "$(dirname "$0")/../Resources" && pwd)"
exec "$HERE/python/bin/python3" "$HERE/app/desktop.py"
LAUNCH
chmod +x "$APP/Contents/MacOS/Questboard"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Questboard</string>
  <key>CFBundleDisplayName</key><string>Questboard</string>
  <key>CFBundleIdentifier</key><string>com.questboard.app</string>
  <key>CFBundleExecutable</key><string>Questboard</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

# slim it down
find "$APP/Contents/Resources/python" -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null || true
rm -rf "$APP/Contents/Resources/python/lib/python3.11/test" 2>/dev/null || true

# 5) Zip + publish to the release ------------------------------------------
echo "==> [5/5] Zipping + publishing to $TAG"
ZIP="$B/Questboard-macOS-Intel.zip"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"

NOTES="Standalone Questboard.app for Intel Macs (macOS 11 Big Sur+). Unzip, move to Applications, then run once in Terminal:

    xattr -dr com.apple.quarantine /Applications/Questboard.app

Double-click to play. Progress is saved in ~/Library/Application Support/Questboard/ and survives updates."

if gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
  echo "    Release $TAG exists — replacing the asset"
  gh release upload "$TAG" "$ZIP#Questboard-macOS-Intel.zip" --repo "$REPO" --clobber
else
  echo "    Creating release $TAG"
  gh release create "$TAG" --repo "$REPO" \
    --title "Questboard $TAG — standalone Mac app" \
    --notes "$NOTES" \
    "$ZIP#Questboard-macOS-Intel.zip"
fi

echo ""
echo "==> Done.  https://github.com/$REPO/releases/tag/$TAG"
echo "    On the kids' Mac: re-download the zip, replace Questboard.app, relaunch."
