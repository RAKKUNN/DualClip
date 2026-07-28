<p align="center">
  <img src="icon.png" alt="DualClip Icon" width="128" height="128">
</p>

<h1 align="center">DualClip</h1>

<p align="center">
  <b>English</b> · <a href="README-ko.md">한국어</a> · <a href="README-ja.md">日本語</a> · <a href="README-zh.md">中文</a>
</p>

<p align="center">
  A lightweight macOS menu bar app that provides <b>multi-slot clipboard management</b>.<br>
  Unlike history-based clipboard managers, DualClip gives you instant access to dedicated clipboard slots via customizable keyboard shortcuts.
</p>

<p align="center">
  <a href="https://rakkunn.github.io/DualClip/"><b>🌐 Website</b></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/RAKKUNN/DualClip/releases/latest"><b>⬇ Download</b></a>
  &nbsp;·&nbsp;
  <a href="#installation"><b>🍺 Homebrew</b></a>
</p>

![CI](https://github.com/RAKKUNN/DualClip/actions/workflows/ci.yml/badge.svg)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue)
![Universal](https://img.shields.io/badge/Universal-arm64%20%2B%20x86__64-black?logo=apple)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

## Features

- **3 Clipboard Slots**: Slot A (system default), Slot B, and Slot C
- **Customizable Shortcuts**: No hardcoded key conflicts — configure your own shortcuts
- **Atomic Paste**: Seamlessly pastes from any slot without corrupting your system clipboard
- **Menu Bar Popover**: Quick-glance view of all slot contents with previews
- **Privacy First**: All data lives in RAM only — nothing is persisted to disk
- **Zero Network Access**: No telemetry, no analytics, no internet communication

## Demo

<p align="center">
  <img src="test_dualclip.gif" alt="DualClip Demo" width="600">
</p>

<p align="center">
  <img src="test_dualclip_image.gif" alt="DualClip Image Support Demo" width="600">
</p>

## Default Shortcuts

| Action | Shortcut |
|--------|----------|
| Copy to Slot B | ⌥⌘C |
| Paste from Slot B | ⌥⌘V |
| Copy to Slot C | ⌃⌘C |
| Paste from Slot C | ⌃⌘V |

All shortcuts are fully customizable in **Settings > Shortcuts**.

## How It Works

1. **Slot A** automatically mirrors the system clipboard (⌘C / ⌘V)
2. **Slot B/C** store content independently via their own copy shortcuts
3. **Atomic Paste** temporarily swaps the system clipboard, simulates ⌘V, then restores the original clipboard — typically within ~200ms, adjustable in **Settings > General**

## Requirements

- macOS 13.0 (Ventura) or later
- Intel or Apple Silicon Mac — the pre-built release is a universal binary (`arm64` + `x86_64`)
- Accessibility permission (required for keystroke simulation)

## Installation

### Homebrew (Recommended)

```bash
brew install RAKKUNN/tap/dualclip
```

### Manual Download

1. Go to the [latest release](https://github.com/RAKKUNN/DualClip/releases/latest)
2. Download `DualClip-x.x.x-universal.zip`
3. Unzip and move `DualClip.app` to `/Applications`
4. Grant Accessibility permission when prompted

> **Note**: Starting from v1.1.0, this app is signed and notarized by Apple. No security warnings on launch.

### Building from Source

```bash
# Clone the repository
git clone https://github.com/RAKKUNN/DualClip.git
cd DualClip

# Open in Xcode
open Package.swift

# Or build from command line
swift build -c release
```

> **Note**: Building from source requires Xcode or Swift 5.9+ Command Line Tools.

## Dependencies

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) — Global keyboard shortcut management (MIT)

## Architecture

```
DualClipCore/                # Library target — all app logic (unit tested)
├── App/                    # App entry point and delegate
├── Models/                 # Data models (SlotIdentifier, ClipboardSlot)
├── Services/               # Core logic
│   ├── ClipboardManager    # NSPasteboard polling (0.5s interval)
│   ├── AtomicPasteService  # Clipboard swap + CGEvent ⌘V simulation
│   └── AccessibilityService # Permission management
├── Views/                  # SwiftUI views (MenuBar, Settings, Onboarding)
└── Shortcuts/              # KeyboardShortcuts integration

DualClip/                   # Executable target — entry point only
└── main.swift

Tests/DualClipCoreTests/    # Unit tests (@testable import DualClipCore)
```

## Security & Privacy

- **No Persistence**: Clipboard data exists only in memory
- **No Network**: Zero external communication — verified by source code
- **Open Source**: Full transparency for security-sensitive clipboard access
- **Accessibility Only**: Minimal permission footprint

## Roadmap

- [x] Secure input field detection (auto-disable in password fields)
- [x] RAM zeroing on normal app termination (not on force quit)
- [x] Image/rich text clipboard support
- [x] GitHub Actions CI/CD + Notarization
- [x] Homebrew Cask distribution
- [ ] Sparkle auto-update framework
- [ ] VoiceOver accessibility support

## Sponsor

If you find DualClip useful, consider supporting development:

<a href="https://github.com/sponsors/RAKKUNN">
  <img src="https://img.shields.io/badge/Sponsor-%E2%9D%A4-ea4aaa?logo=github" alt="Sponsor RAKKUNN"/>
</a>

## Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change.

## License

[MIT](LICENSE)
