# Installing Questboard on the kids' Mac

This is a standalone Mac app — no Docker, no setup, nothing to keep running on
another machine. The game runs right on this Mac and opens in the browser.

> Works on macOS 11 (Big Sur) and newer, Intel Macs.

## First-time install

1. **Download** `Questboard-macOS-Intel.zip` from the
   [Releases page](https://github.com/TreasuryMatt/questboard/releases)
   (grab the newest one at the top).
2. **Unzip** it — double-click the `.zip`. You'll get `Questboard.app`.
3. **Move** `Questboard.app` into your **Applications** folder (optional, but tidy).
4. **First launch — important:** the app isn't signed with a paid Apple
   account, so a normal double-click will be blocked the first time. Instead:
   - **Right-click** (or Control-click) `Questboard.app` → **Open**
   - In the dialog that appears, click **Open** again.
   - You only have to do this **once**. After that, double-click works normally.
5. The app starts and opens Questboard in your default browser. Play!

To quit, close the small Questboard window (or quit it from the Dock).

## Where the game saves progress

All gold, XP and dungeon progress is stored here:

```
~/Library/Application Support/Questboard/
```

This lives **outside** the app, so installing a newer version never wipes
anyone's progress.

## Updating to a newer version

1. Quit Questboard if it's running.
2. Download the newest `Questboard-macOS-Intel.zip` from the Releases page.
3. Unzip and replace the old `Questboard.app` with the new one.
4. Launch it (a plain double-click is fine now). Your saved progress is intact.

## Troubleshooting

- **"Questboard can't be opened because Apple cannot check it…"** — you
  double-clicked instead of right-click → Open. Do step 4 above.
- **Browser didn't open** — open any browser and go to
  [http://127.0.0.1:5050](http://127.0.0.1:5050) while the app is running.
- **Nothing happens / port in use** — quit any other copy of Questboard and try
  again.
