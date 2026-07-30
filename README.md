<div align="center">

<img src="docs/logo.png" width="120" alt="Progress app icon">

# ✨ Progress ✨

### a lil menu bar buddy that watches your day go by

[![Homebrew](https://img.shields.io/badge/brew_install--cask-geethanke%2Fprogress%2Fprogress-ffb6c1?style=for-the-badge)](#how-to-install-it-)
[![Download for macOS](https://img.shields.io/badge/⬇️_or_Download-Progress.dmg-ffb6c1?style=for-the-badge)](https://github.com/GeethanKE/Progress/releases/latest/download/Progress.dmg)

*one line in Terminal, or one drag-and-drop — whichever's more you 🩷*

</div>

<br>

## what even is this 🥹

Progress lives quietly up in your Mac's menu bar (next to your wifi, battery,
all that) and shows you **how much of your day is gone** — as a lil pie that
fills up, or a bar, whatever's cuter to you.

That's it. That's the whole app. No accounts, no ads, no tracking, no popups
begging you to subscribe to anything. It just sits there being aesthetic and
useful 🎀

<br>

## how to install it 💫

**if you have [Homebrew](https://brew.sh)** — this is the easiest way, one line, no dragging anything anywhere:

```bash
brew install --cask geethanke/progress/progress
```

open it from Launchpad or Spotlight (`⌘ + Space`, type "Progress") once it's done. To update later:

```bash
brew upgrade --cask progress
```

**if you don't have Homebrew** — download it instead:

[![Download for macOS](https://img.shields.io/badge/⬇️_Download_for_Mac-Progress.dmg-ffb6c1?style=for-the-badge)](https://github.com/GeethanKE/Progress/releases/latest/download/Progress.dmg)

1. Click that button, `Progress.dmg` lands in your Downloads — double click it
2. A little window pops up, drag the **Progress** icon onto the **Applications**
   folder icon (there's literally an arrow showing you where lol)
3. Close that window, then open **Launchpad** or **Spotlight** (`⌘ + Space`)
   and type "Progress" — click it to open

**either way, one weird extra step the first time only:** your Mac might say
something like *"Apple could not verify Progress is free of malware"* —
that happens whether you use Homebrew or the download, since it just means
I'm one (1) person and not a company paying Apple $$$/year for notarization,
not that anything's actually wrong 🫶. If that happens:

- **On newer macOS:** go to **System Settings → Privacy & Security**, scroll
  down, and click **Open Anyway** next to Progress — then confirm once more
- **On older macOS:** right-click the Progress icon → click **Open** → click
  **Open Anyway** in the dialog that pops up

That's a one-time thing per install — you'll never see it again after that.
That's genuinely it. You're done. Look up at your menu bar 🎀

<br>

## making it yours 💌

Click the icon up top any time to see:

```
   ◐  ← your lil progress icon
   │
   ▼
┌───────────────────────────────┐
│ 64 %                          │
│ 8 hrs 44 min until end of day │
├───────────────────────────────┤
│ Settings…                     │  ← set your own start/end time
│ More ▸                        │  → percent/time left, pie/bar, repeat daily
├───────────────────────────────┤
│ Quit Progress                 │
└───────────────────────────────┘
```

Open **Settings…** to give it a cute label and pick when your "day" starts
and ends — defaults to midnight → midnight so it just works right away, but
make it a workday, a countdown to vacation, whatever you want it to track 🌷

Want it to open automatically every time you turn your Mac on? Go to
**System Settings → General → Login Items** and add Progress there.

<br>

<div align="center">
<img src="docs/screenshots/screenshot1.png" width="45%" alt="Progress menu bar dropdown">
&nbsp;
<img src="docs/screenshots/screenshot2.png" width="45%" alt="Progress settings window">
</div>

<br>

## why does it look so plain / why is there no color 🤍

That's on purpose! It's built to match Apple's own menu bar icons (like your
battery or wifi symbol) so it feels like it's actually part of your Mac,
not some random app slapped on top. It even flips light/dark automatically
depending on your wallpaper and dark mode settings ✨

<br>

## it's private, i promise 🔒

Everything — your start time, end time, all of it — lives only on your own
Mac. Nothing gets sent anywhere, there's no internet connection happening at
all. It's just a lil clock, minding its business.

<br>

---

<br>

<details>
<summary><b>🛠️ for the developers / curious people (click to expand)</b></summary>

<br>

### building it yourself instead of downloading

```bash
git clone https://github.com/GeethanKE/Progress.git
cd Progress
./scripts/build-dmg.sh   # builds Progress.dmg locally
# or:
swift run -c release     # just run it directly, no packaging
```

Requires macOS 12+ and Swift 5.9+ / Xcode 15+.

### project structure

```
Progress/
├── .github/workflows/
│   ├── ci.yml                    # builds on every push/PR
│   └── release.yml               # builds Progress.dmg + attaches to GitHub Releases on tag push
├── Package.swift
├── Resources/
│   └── AppIcon.iconset/          # all required icon sizes; compiled to .icns at build time
├── docs/
│   ├── logo.png                  # README header image
│   └── screenshots/              # drop screenshot1.png / screenshot2.png here — used in README
├── Sources/Progress/
│   ├── main.swift                     # app entry point (AppDelegate)
│   ├── StatusItemController.swift     # NSStatusItem + native NSMenu + minute-aligned timer
│   ├── SettingsWindowController.swift # native window hosting the SwiftUI settings view
│   ├── ProgressStore.swift            # persisted model: start/end time, display prefs
│   ├── IconRenderer.swift             # draws the template pie/bar icon
│   ├── Formatters.swift               # percent / remaining-time string helpers
│   └── SettingsView.swift             # SwiftUI content for the Settings… window
├── scripts/
│   ├── build-app.sh              # bundles the release build into Progress.app (incl. app icon)
│   └── build-dmg.sh              # wraps Progress.app into a drag-to-Applications Progress.dmg
├── LICENSE
└── README.md
```

### how the progress calculation works

```
fraction = (now - startDate) / (endDate - startDate)
```

Clamped to `[0, 1]`. The icon and menu redraw exactly when the clock's
minute value changes (aligned to real minute boundaries via
`Calendar.nextDate`), not on a blind interval — so there's no wasted work
and no lag behind the actual time.

Default range is midnight → 11:59:59 PM of the current day. All settings
persist via `UserDefaults`.

### releasing a new version

Every push of a `v*.*.*` tag triggers `.github/workflows/release.yml`,
which builds `Progress.app`, wraps it into `Progress.dmg`, and attaches it
to a new GitHub Release. The version number is read straight from the git
tag (`v1.0.2` → `1.0.2`), so there's nothing to edit by hand.

```bash
git tag v1.0.2
git push origin v1.0.2
```

To undo a bad tag/release before retagging:

```bash
gh release delete v1.0.2 --yes         # or delete it on github.com
git push origin :refs/tags/v1.0.2
git tag -d v1.0.2
```

### Homebrew Cask (one-time setup)

`brew install --cask geethanke/progress/progress` works because Homebrew
looks for a repo named `homebrew-<tapname>` — in this case
`GeethanKE/homebrew-progress` — containing a `Casks/progress.rb` file.
`release.yml` keeps that file up to date automatically on every tagged
release, but it needs to exist and have write access granted once:

1. Create a new **public** repo on GitHub named exactly `homebrew-progress`
   (empty is fine — the workflow creates `Casks/progress.rb` itself the
   first time it runs).
2. Create a
   [fine-grained personal access token](https://github.com/settings/personal-access-tokens/new)
   scoped only to that `homebrew-progress` repo, with **Contents:
   Read and write** permission.
3. In the `Progress` repo, go to **Settings → Secrets and variables →
   Actions → New repository secret**, name it `HOMEBREW_TAP_TOKEN`, and
   paste the token in.
4. Push a new tag — the release workflow will clone `homebrew-progress`,
   write/update `Casks/progress.rb` with the new version and checksum, and
   push the commit automatically. No further manual steps after that.

If `HOMEBREW_TAP_TOKEN` isn't set, that step is skipped silently — the DMG
release still works fine, Homebrew installs just won't be available yet.

### roadmap

- [x] Recurring daily ranges — toggle **More → Repeat Daily** (on by default);
      when the current range ends, it automatically shifts forward by whole
      days (DST-safe) until it covers "now" again, instead of freezing at
      "Done." Turn it off for one-time deadlines/countdowns that shouldn't
      repeat.
- [ ] Multiple saved presets (e.g. "Workday", "Sprint", "Vacation countdown")
- [ ] Optional notification when the end time is reached

### contributing

Issues and PRs welcome. Keep it lightweight — this is meant to stay a
single-purpose utility, not grow into a full task manager.

</details>

<br>

<div align="center">

MIT licensed — see [LICENSE](LICENSE) 🩷

</div>
