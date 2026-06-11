# Shipping changes to the kids' Mac app

This is how you push an improvement out to the standalone **Questboard.app** on
the kids' Intel Mac. (For first-time install, see [INSTALL-MAC.md](INSTALL-MAC.md).)

## How it works (read this once)

The kids' app is a **prebuilt bundle** that lives on the
[Releases page](https://github.com/TreasuryMatt/questboard/releases). The GitHub
Intel build runner (`macos-13`) was retired, so the app is built **on your Mac**
instead of in the cloud — but that's now **automatic on push** via a git hook.

When you `git push`, a `pre-push` hook checks the version in
`frontend/package.json`. If it's a **new** version (no release for it yet), the
hook builds the Intel app and publishes it to the matching release. If the
version is unchanged, the hook does nothing — normal pushes stay fast.

```
  bump version ──► commit ──► git push
                                  │  (pre-push hook fires only on a new version)
                                  ▼
                     builds Intel app ──► Releases page
                                              │
                      kids' Mac: re-download, replace ◄┘
```

> The hook is enabled by `git config core.hooksPath .githooks` (already set on
> this Mac). If you ever clone the repo fresh, run that once to re-enable it.
> Skip the build for a single push with `git push --no-verify`.

Your game data is never touched — it lives in
`~/Library/Application Support/Questboard/` on the kids' Mac and survives every
update.

## One-time setup on your Mac

You only need these once:

- **Node.js** and **npm** (you already build the frontend with these)
- **GitHub CLI**, logged in: `gh auth status` should show you're logged in
- **Rosetta** (Apple Silicon Macs only), so the build can use an Intel Python:
  ```
  softwareupdate --install-rosetta --agree-to-license
  ```

## Shipping an update — the steps

1. **Make your code changes** and test them locally (`cd frontend && npm run dev`,
   plus the backend if needed).

2. **Bump the version** in `frontend/package.json` (e.g. `1.12.1` → `1.12.2`).
   Each release needs a new version number.

3. **Commit and push to GitHub:**
   ```
   git add -A
   git commit -m "Describe your change"
   git push origin main
   ```
   Because you bumped the version, the `pre-push` hook automatically builds the
   Intel `Questboard.app` and publishes `Questboard-macOS-Intel.zip` to the
   matching release. This adds a couple of minutes to the push — that's the build
   running. Watch for `pre-push: published vX.Y.Z` near the end.

   > Didn't bump the version? The hook skips the build (you'll see
   > `already published — skipping`). To rebuild without pushing, or if the hook
   > build failed, run it by hand: `./scripts/build-mac-app.sh` (optionally with a
   > version, e.g. `./scripts/build-mac-app.sh 1.12.2`).

4. **Update the kids' Mac:**
   - Quit Questboard if it's open.
   - Open the [Releases page](https://github.com/TreasuryMatt/questboard/releases),
     download the newest `Questboard-macOS-Intel.zip`, unzip it.
   - Drag the new `Questboard.app` into Applications, replacing the old one.
   - Launch it (a normal double-click is fine after the first-ever install).
     Saved progress is intact.

That's it.

## Notes & gotchas

- **The script publishes to your fork** (`TreasuryMatt/questboard`), derived from
  your `origin` remote — not the upstream. Override with `QB_REPO=owner/name` if
  you ever need to.
- **Re-running the same version** replaces the existing zip on that release
  (`--clobber`), so a re-build is safe.
- **First launch on a fresh download** still needs the one-time Gatekeeper
  unlock, because the app is unsigned:
  ```
  xattr -dr com.apple.quarantine /Applications/Questboard.app
  ```
  Replacing an already-unlocked app in place usually doesn't re-trigger this,
  but if Big Sur complains, just run that line again.
- **Why not just `git push` and let CI build it?** Because GitHub no longer
  offers an Intel macOS runner, and a non-Intel build won't run on Big Sur. The
  local script is the reliable path. If you later move the kids to an Apple
  Silicon Mac, we can switch to a hosted runner and make this fully automatic.

## Quick reference

```bash
# from the repo root, after pushing your changes:
./scripts/build-mac-app.sh          # builds + publishes using package.json version
./scripts/build-mac-app.sh 1.13.0   # ...or force a specific version
```
