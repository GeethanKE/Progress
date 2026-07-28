# Progress 🥧

[![Download for macOS](https://img.shields.io/badge/Download-Progress.dmg-blue?style=for-the-badge&logo=apple)](https://github.com/GeethanKE/Progress/releases/latest/download/Progress.dmg)
[![CI](https://github.com/GeethanKE/Progress/actions/workflows/ci.yml/badge.svg)](https://github.com/GeethanKE/Progress/actions/workflows/ci.yml)

A tiny, native macOS menu bar utility that shows a pie or bar progress indicator
for any custom time range — a workday, a countdown, a deadline, a meeting, a
sprint. Pick a start and end time, and Progress tracks it live in your menu bar
as a percentage or as remaining minutes/hours.

No Dock icon, no clutter — just a small icon that lives quietly in your menu bar.

## Features

- 🥧 **Pie or bar** progress icon, rendered natively (crisp at any display scale)
- 🔢 Shows **percentage complete** or **time remaining**
- ⏱ Custom **start** and **end** date/time — a workday, a deadline, a timer, anything
- 🪶 Extremely lightweight — no Dock icon, no background processes beyond a 30s refresh tick
- 💾 Settings persist across relaunches
- 🖱 Click the menu bar item to open a small settings popover — no separate preferences window

## Screenshot

A plain template icon sits in the menu bar next to your other system icons,
and clicking it drops a native macOS menu — no custom popover, no extra chrome:

```
   ◐  ← menu bar icon (fills clockwise as time elapses)
   │ click
   ▼
┌───────────────────────────────┐
│ 64 %                          │
│ 8 hrs 44 min until end of day │
├───────────────────────────────┤
│ Settings…                 ⌘,  │
│ More                        ▸ │  → Show: Percent / Time Left
│                                │    Style: Pie / Bar
├───────────────────────────────┤
│ Quit Progress              ⌘Q │
└───────────────────────────────┘
```

"Settings…" opens a small window for the label, start time, and end time.
"More" holds the display-mode and icon-style toggles as a checkable submenu,
the same way native menu bar utilities organize secondary options.

## Requirements

- macOS 12 (Monterey) or later
- Swift 5.9+ / Xcode 15+ (for building from source)

## Installation

### Option 1 — Download (recommended for most people)

1. Click **[Download Progress.dmg](https://github.com/GeethanKE/Progress/releases/latest/download/Progress.dmg)** (also on the [Releases](https://github.com/GeethanKE/Progress/releases) page).
2. Double-click `Progress.dmg` to mount it.
3. Drag `Progress.app` onto the **Applications** shortcut in the window that opens.
4. Eject the disk image, then open `Progress.app` from `/Applications` (Launchpad, Spotlight, or Finder).
5. Since this build isn't notarized by Apple, the very first launch needs one of:
   - Right-click `Progress.app` → **Open** → **Open** again in the dialog, or
   - Run `xattr -cr /Applications/Progress.app` in Terminal once, then double-click normally.

To launch it automatically at login, add `Progress.app` in
**System Settings → General → Login Items**.

### Option 2 — Build and bundle it yourself

```bash
git clone https://github.com/GeethanKE/Progress.git
cd Progress
./scripts/build-dmg.sh   # or ./scripts/build-app.sh for just the .app, no dmg
```

This produces `Progress.dmg` (or `Progress.app`) locally — no download, no
Gatekeeper prompt tied to a stranger's binary.

### Option 3 — Run directly with Swift Package Manager

```bash
git clone https://github.com/GeethanKE/Progress.git
cd Progress
swift run -c release
```

### The full source is always attached too

Every GitHub Release automatically includes **Source code (zip)** and
**Source code (tar.gz)** links below the `Progress.dmg` asset — so anyone who
wants to read, audit, or build from source has that one click away as well,
right alongside the installer.

### Releasing a new version (for maintainers)

Every push of a `v*.*.*` tag triggers `.github/workflows/release.yml`, which
builds `Progress.app`, wraps it into `Progress.dmg`, and attaches it to a new
GitHub Release — so the download badge above always points at the latest
build automatically.

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Usage

1. Click the icon in your menu bar to see the dropdown.
2. Open **Settings…** to set a **Label**, **Start**, and **End** time.
3. Open **More** to switch between **Percent / Time Left** and **Pie / Bar** icon style.
4. Close the menu — Progress keeps updating in the background every 30 seconds.

## Project structure

```
Progress/
├── .github/workflows/
│   ├── ci.yml                    # Builds on every push/PR
│   └── release.yml               # Builds Progress.dmg and attaches it to GitHub Releases on tag push
├── Package.swift
├── Sources/Progress/
│   ├── main.swift                  # App entry point (AppDelegate)
│   ├── StatusItemController.swift  # Builds the NSStatusItem + native NSMenu + timer
│   ├── SettingsWindowController.swift # Native window hosting the SwiftUI settings view
│   ├── ProgressStore.swift         # Persisted model: start/end time, display prefs
│   ├── IconRenderer.swift          # Draws the template pie/bar icon
│   ├── Formatters.swift            # Percent / remaining-time string helpers
│   └── SettingsView.swift          # SwiftUI content for the Settings… window
├── scripts/
│   ├── build-app.sh              # Bundles the release build into Progress.app
│   └── build-dmg.sh              # Wraps Progress.app into a drag-to-Applications Progress.dmg
├── LICENSE
└── README.md
```

## How it works

Progress computes elapsed fraction as:

```
fraction = (now - startDate) / (endDate - startDate)
```

clamped to `[0, 1]`, and redraws the menu bar icon and label every 30 seconds
via a repeating `Timer`. All state is persisted to `UserDefaults`, so your
configured range survives app relaunches.

## Roadmap

- [ ] Multiple saved presets (e.g. "Workday", "Sprint", "Vacation countdown")
- [ ] Optional notification when the end time is reached
- [ ] Menu bar-only color customization
- [ ] Recurring daily ranges (e.g. always 9–5 on weekdays)

## Contributing

Issues and PRs welcome. Keep it lightweight — this is meant to stay a
single-purpose utility, not grow into a full task manager.

## License

MIT — see [LICENSE](LICENSE).
