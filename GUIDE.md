# DualClip User Guide

DualClip is a multi-slot clipboard manager that lives in the macOS menu bar. It keeps your existing clipboard (⌘C/⌘V) untouched while giving you two additional slots (B and C) accessible via customizable keyboard shortcuts.

---

## Table of Contents

1. [Installation](#1-installation)
2. [First Launch & Permission Setup](#2-first-launch--permission-setup)
3. [Core Concept: 3 Clipboard Slots](#3-core-concept-3-clipboard-slots)
4. [Using Keyboard Shortcuts](#4-using-keyboard-shortcuts)
5. [Menu Bar Popover](#5-menu-bar-popover)
6. [Customizing Shortcuts](#6-customizing-shortcuts)
7. [How Atomic Paste Works](#7-how-atomic-paste-works)
8. [Security & Privacy](#8-security--privacy)
9. [Troubleshooting](#9-troubleshooting)
10. [Building from Source](#10-building-from-source)

---

## 1. Installation

### Building with Xcode (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/RAKKUNN/DualClip.git
cd DualClip

# 2. Open in Xcode
open Package.swift

# 3. In the Xcode toolbar:
#    - Scheme: Select "DualClip"
#    - Destination: Select "My Mac"
#    - Press ⌘R to build & run
```

### Building with Command Line Tools Only

You can build without Xcode (requires Swift 5.9+ Command Line Tools):

```bash
swift build -c release
# Binary location: .build/release/DualClip
```

> **Note**: CLI builds produce an executable, not an `.app` bundle. A Dock icon may briefly appear during launch.

---

## 2. First Launch & Permission Setup

When you first launch DualClip, an **Onboarding screen** will appear.

### Step 1: Grant Accessibility Permission

DualClip requires **Accessibility permission** to perform paste operations for Slots B and C. This permission is used to simulate ⌘V keystrokes via `CGEvent`.

1. Click **"Grant Access"** on the Onboarding screen
2. macOS System Settings will open automatically
3. Navigate to **System Settings > Privacy & Security > Accessibility**
4. Find **DualClip** in the list and **toggle it ON**

> The status indicator on the Onboarding screen will change from red to green once the permission is granted.

### Step 2: Review Default Shortcuts

Click "Next" to see the default shortcut assignments:

| Slot | Copy | Paste |
|------|------|-------|
| Slot A (System) | ⌘C | ⌘V |
| Slot B | ⌥⌘C | ⌥⌘V |
| Slot C | ⌃⌘C | ⌃⌘V |

Click **"Get Started"** to proceed to the main interface.

---

## 3. Core Concept: 3 Clipboard Slots

DualClip provides three independent clipboard slots:

### Slot A — System Clipboard

- **Automatically syncs** with the macOS system clipboard
- Anything you copy with ⌘C is reflected here in real time
- No special action needed — your existing workflow remains unchanged

### Slot B — Auxiliary Slot 1

- An independent storage space
- Copy with ⌥⌘C, paste with ⌥⌘V
- Example: Temporarily store a frequently used email address or code snippet

### Slot C — Auxiliary Slot 2

- A second independent storage space
- Copy with ⌃⌘C, paste with ⌃⌘V
- Example: Store source text and translated text in separate slots during translation work

### Usage Scenarios

**Code Refactoring:**
1. Select variable name `oldName` → **⌥⌘C** (save to Slot B)
2. Select new variable name `newName` → **⌃⌘C** (save to Slot C)
3. In another file, press **⌥⌘V** to paste the old name, **⌃⌘V** to paste the new name
4. Throughout this process, **⌘C/⌘V (Slot A) remains fully independent**

**Translation Work:**
1. Select English source text → **⌥⌘C** (save to Slot B)
2. Select translated result from a translator → **⌃⌘C** (save to Slot C)
3. Paste each version where needed using **⌥⌘V** or **⌃⌘V**

---

## 4. Using Keyboard Shortcuts

### Copying to a Slot

1. **Select the text** you want to copy (drag to highlight)
2. Press the **copy shortcut** for the desired slot:
   - Slot B: **⌥⌘C** (Option + Command + C)
   - Slot C: **⌃⌘C** (Control + Command + C)
3. The text is now stored in the slot — verify via the menu bar popover

> Internally, the copy action simulates ⌘C and then captures the clipboard content into the target slot.

### Pasting from a Slot

1. **Place the cursor** where you want to insert text
2. Press the **paste shortcut** for the desired slot:
   - Slot B: **⌥⌘V** (Option + Command + V)
   - Slot C: **⌃⌘V** (Control + Command + V)
3. The stored text is pasted at the cursor position

> After pasting, the system clipboard (Slot A) remains **unchanged** thanks to Atomic Paste.

### Modifier Key Reference

| Symbol | Key | Location |
|--------|-----|----------|
| ⌘ | Command | Both sides of the Space bar |
| ⌥ | Option (Alt) | Next to the Command key |
| ⌃ | Control | Bottom-left corner of the keyboard |

---

## 5. Menu Bar Popover

Click the clipboard icon in the menu bar to open the **popover window**.

### Popover Layout

```
┌──────────────────────────────┐
│  DualClip          Clear All │  ← Header (clears Slots B & C)
├──────────────────────────────┤
│  [A] System clipboard        │  ← Slot A: current system clipboard
│      "Copied text preview…"  │
│      3 seconds ago            │
│                               │
│  [B] Slot B              [✕] │  ← Slot B: stored content + clear button
│      "Stored text preview…"  │
│      1 minute ago             │
│                               │
│  [C] Slot C              [✕] │  ← Slot C
│      (empty)                  │
├──────────────────────────────┤
│  ⚙ Settings    🟢    Quit   │  ← Footer (settings, permission status, quit)
└──────────────────────────────┘
```

### Element Descriptions

- **Slot Badge (A/B/C)**: Color-coded identifiers (A = blue, B = orange, C = purple)
- **Preview**: Displays the first 40 characters of stored text in a single line
- **Timestamp**: Shows when content was copied in relative format (e.g., "3 seconds ago")
- **✕ Button**: Clears the content of the individual slot (Slots B and C only)
- **Clear All**: Clears Slots B and C simultaneously (Slot A is unaffected as it mirrors the system clipboard)
- **Status Dot**: Green = Accessibility granted; Red = not granted (click to open System Settings)
- **Settings**: Opens the shortcut customization window
- **Quit**: Terminates the application

---

## 6. Customizing Shortcuts

If the default shortcuts conflict with other apps or feel inconvenient, you can change them freely.

### How to Change Shortcuts

1. Click **⚙ Settings** in the menu bar popover
2. Select the **Shortcuts** tab
3. Click the input field for the shortcut you want to change
4. **Press the desired key combination** directly (e.g., ⌃⇧C)
5. The new shortcut is saved automatically

### Settings Layout

```
Shortcuts Tab:
┌─────────────────────────────────┐
│  Slot B                         │
│  Copy to Slot B:    [⌥⌘C     ] │  ← Click and press new key combo
│  Paste from Slot B: [⌥⌘V     ] │
│                                 │
│  Slot C                         │
│  Copy to Slot C:    [⌃⌘C     ] │
│  Paste from Slot C: [⌃⌘V     ] │
│                                 │
│  [Reset to Defaults]            │  ← Restore default shortcuts
└─────────────────────────────────┘
```

### Tips for Choosing Shortcuts

- **Choose combinations that don't conflict** with other applications
- Generally safe modifier combinations:
  - `⌃⇧` (Control + Shift) + letter
  - `⌃⌥` (Control + Option) + letter
  - `⌃⌥⌘` (Control + Option + Command) + letter
- Combinations to avoid:
  - `⌘⇧V` — commonly used for "Paste without formatting" in most apps
  - `⌘⇧C` — used in Chrome DevTools, VS Code, and other developer tools

---

## 7. How Atomic Paste Works

**Atomic Paste** is DualClip's core technology that preserves the system clipboard when pasting from Slots B or C.

### Step-by-Step Process (when ⌥⌘V is pressed)

```
[1] Back up the system clipboard
    Temporarily save the current ⌘C content

[2] Swap in slot data
    Overwrite the system clipboard with Slot B's content

[3] Simulate ⌘V
    Send the paste command to the target application

[4] Wait 150ms
    Allow time for the target app to read the clipboard

[5] Restore the system clipboard
    Revert to the original content saved in step [1]
```

### Why Does It Work This Way?

macOS paste (⌘V) always reads from the **system clipboard (`NSPasteboard.general`)**. To paste content from Slot B, DualClip must temporarily replace the system clipboard. Atomic Paste completes this entire cycle — backup, swap, paste, restore — **within 150ms**, so the user never notices the clipboard was momentarily changed.

---

## 8. Security & Privacy

DualClip is designed with security as a top priority.

### Data Storage

| Item | Policy |
|------|--------|
| Clipboard data | **Exists in RAM only** — never written to disk |
| On app quit | All slot data is immediately discarded |
| Settings data | Only shortcut preferences and onboarding status are stored in `UserDefaults` |

### Network

- **No networking code exists in the application**
- No telemetry, analytics, or auto-update server connections
- Source code is publicly available for independent verification

### Permissions

| Permission | Purpose | Required |
|------------|---------|----------|
| Accessibility | Simulate ⌘V/⌘C key events via `CGEvent` | **Required** — Slots B/C paste will not work without it |
| All others | Not used | — |

### Open Source

- Released under the MIT License
- All source code is available on GitHub for inspection
- Clipboard apps handle sensitive data — transparency is essential

---

## 9. Troubleshooting

### Pressing ⌥⌘V does nothing

**Cause**: Accessibility permission is likely not granted.

**Fix**:
1. Check the status dot at the bottom of the menu bar popover — is it red?
2. If red, click it to open System Settings
3. Navigate to **System Settings > Privacy & Security > Accessibility**
4. Toggle DualClip OFF and then back ON
5. Restart the app

### Shortcuts conflict with another app

**Fix**:
1. Open the menu bar popover > **Settings** > **Shortcuts** tab
2. Click the conflicting shortcut field
3. Press a new key combination
4. Use "Reset to Defaults" to restore original shortcuts

### Previous clipboard content disappears after pasting

**Cause**: The target application may take longer than 150ms to read the clipboard.

**Fix**: The current version does not allow adjusting the restore delay. If this occurs frequently, please report it via [GitHub Issues](https://github.com/RAKKUNN/DualClip/issues).

### Menu bar icon is not visible

**Fix**:
1. If you have many menu bar icons, macOS may hide some — try scrolling or rearranging
2. Hold ⌘ and drag menu bar icons to rearrange
3. Check if DualClip is running by searching "DualClip" in Activity Monitor

### Slot A shows no content

**Cause**: You copied non-text data such as an image or file.

**Note**: The current version **supports text (String) only**. Images, rich text, and files are not detected.

---

## 10. Building from Source

### Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15+ or Swift 5.9+ Command Line Tools

### Xcode Build

```bash
git clone https://github.com/RAKKUNN/DualClip.git
cd DualClip
open Package.swift
# Press ⌘R in Xcode to build & run
```

### CLI Build

```bash
git clone https://github.com/RAKKUNN/DualClip.git
cd DualClip
swift build -c release
# Run
.build/release/DualClip
```

### Project Structure

```
DualClip/
├── App/
│   ├── DualClipApp.swift          # App entry point (MenuBarExtra)
│   └── AppDelegate.swift          # Permission checks, lifecycle
├── Models/
│   ├── ClipboardSlot.swift        # Slot data model
│   └── SlotIdentifier.swift       # A/B/C enum
├── Services/
│   ├── ClipboardManager.swift     # Clipboard polling (0.5s interval)
│   ├── AtomicPasteService.swift   # Atomic Paste implementation
│   └── AccessibilityService.swift # Permission management
├── Views/
│   ├── MenuBarView.swift          # Menu bar popover
│   ├── SlotRowView.swift          # Individual slot row
│   ├── SettingsView.swift         # Shortcut settings
│   └── OnboardingView.swift       # First-run guide
└── Shortcuts/
    ├── ShortcutNames.swift        # Shortcut name definitions
    └── ShortcutHandler.swift      # Shortcut-to-action binding
```

---

> **DualClip** is an open-source project distributed under the MIT License. For contributions, bug reports, and feature requests, please use [GitHub Issues](https://github.com/RAKKUNN/DualClip/issues).
