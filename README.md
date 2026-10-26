# macOS Toggle Menu Bar

An AppleScript for the macOS **Shortcuts** app to quickly toggle menu bar visibility between **"Never"** (always visible) and **"In Full Screen Only"** (hidden unless hovered).

Designed specifically for **macOS 14 Sonoma**, **macOS 15 Sequoia**, and **macOS 26+**, and intended to be run seamlessly from **Control Center** or the **Menu Bar**.

---

## Features

- **Direct Navigation**: Opens directly into the Control Center settings pane (`x-apple.systempreferences:com.apple.ControlCenter-Settings.extension`) without manual clicking.
- **Focus Management**: Activates System Settings to ensure simulated keystrokes are received by the target window, not your active application.
- **State Detection**: Reads the current value of the menu bar preference before switching.
- **SwiftUI Workaround**: Bypasses the known SwiftUI dropdown click limitation by navigating menu items using simulated keystrokes (`Up`/`Down` Arrow + `Return`).
- **Clean Exit**: Automatically closes the System Settings window once the toggle completes.

---

## macOS Compatibility

| macOS Version | Supported? | Details |
| :--- | :---: | :--- |
| **macOS 26+** | ✅ **Yes** | Fully supported. Uses SwiftUI `System Settings` with Control Center extension. |
| **macOS 15 Sequoia** | ✅ **Yes** | Fully supported. Uses `com.apple.ControlCenter-Settings.extension`. |
| **macOS 14 Sonoma** | ✅ **Yes** | Fully supported. Apple moved menu bar preferences to Control Center here. |
| **macOS 13 Ventura** | ❌ **No** | Menu bar settings were under **Desktop & Dock** (`com.apple.Desktop-Settings.extension`), not Control Center. |
| **macOS 12 Monterey & older** | ❌ **No** | Used legacy **System Preferences** with checkboxes under Dock & Menu Bar. |

> [!NOTE]
> **Language Requirement**: This script targets UI elements by English string names (`"Automatically hide and show the menu bar"`, `"Never"`, etc.). If your Mac uses a non-English display language, you will need to update those strings to match your localized System Settings text.

---

## How to Set Up in Shortcuts (Control Center / Menu Bar)

### 1. Create the Shortcut
1. Open the **Shortcuts** app on your Mac.
2. Click **`+`** to create a new shortcut and name it **Toggle Menu Bar**.
3. In the action search bar on the right, find **"Run AppleScript"** and drag it into the editor.
4. Replace the default template text with the full contents of [`toggle-menu-bar.applescript`](toggle-menu-bar.applescript).

### 2. Add to Control Center / Menu Bar
1. In the Shortcuts editor, open the **Shortcut Details** sidebar (click the **`(i)`** icon in the upper-right corner).
2. Check the following options:
   - **Show in Control Center**
   - **Pin in Menu Bar** (optional, if you want an icon directly in the top menu bar)

### 3. Grant Permissions
When you run the shortcut for the first time:
1. macOS may show a prompt asking if Shortcuts can control **System Events** and **System Settings**—click **OK** / **Allow**.
2. Make sure **Shortcuts** has Accessibility permissions:
   - Go to **System Settings** > **Privacy & Security** > **Accessibility**.
   - Ensure **Shortcuts** is turned **ON**. *(If it is not in the list, click `+`, press `Cmd + Shift + G`, enter `/System/Applications/Shortcuts.app`, and add it).*

---

## How to Use

1. Click the **Control Center** icon in your menu bar (or the Shortcuts icon if pinned).
2. Click **Toggle Menu Bar**.
3. System Settings will briefly open, toggle the preference, and quit cleanly.

---

## Note: Why Global Hotkeys Fail for this Script

If you attempt to assign a global keyboard shortcut (hotkey) to this Shortcut in the Details sidebar and press it while using another application, macOS will block it with this error:

> **System Events got an error: Shortcuts is not allowed assistive access.**

### Why this happens:
- **Interactive execution (Control Center / Menu Bar / Shortcuts app)**: macOS attributes the script directly to the user-facing `Shortcuts.app` process, which respects your Accessibility grants.
- **Background hotkey execution**: When triggered via a keyboard shortcut while another application is active, macOS delegates execution to an isolated background daemon (`siriactionsd` / headless runner). Apple's security framework confines this daemon to a strict sandbox that does **not** inherit Accessibility permissions and cannot simulate keystrokes (`System Events`).

For this reason, triggering the shortcut directly from **Control Center** or the **Menu Bar** is the cleanest, most reliable native method.

---

## Script Source

[`toggle-menu-bar.applescript`](toggle-menu-bar.applescript):

```applescript
open location "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension"

tell application "System Settings" to activate

tell application "System Events"
	tell process "System Settings"
		set frontmost to true
		-- Wait for the window to appear
		repeat until exists window 1
			delay 0.05
		end repeat

		-- Wait for the inner scroll area to render
		delay 0.2

		-- Target the exact popup button from System Settings
		set thePopup to pop up button "Automatically hide and show the menu bar" of group 1 of scroll area 1 of group 1 of group 3 of splitter group 1 of group 1 of window 1

		-- Read current value before opening
		set currentValue to value of thePopup as string

		-- Open the drop-down menu
		click thePopup

		-- CRITICAL: Wait for the menu animation to finish appearing on screen
		delay 0.3

		-- Use keyboard arrows to bypass the SwiftUI clicking bug
		if currentValue contains "Never" then
			-- Currently at the bottom. Move UP one slot to "In Full Screen Only"
			key code 126 -- Up Arrow
			delay 0.1
			key code 36 -- Return
		else
			-- Assume "In Full Screen Only". Move DOWN one slot to "Never"
			key code 125 -- Down Arrow
			delay 0.1
			key code 36 -- Return
		end if

	end tell
end tell

-- Clean up
delay 0.2
tell application "System Settings" to quit
```

---

## Troubleshooting

- **Timing / Delays**: If the script occasionally misses the popup on slower hardware or under heavy load, slightly increase `delay 0.2` and `delay 0.3`.
- **System Language**: The script targets UI elements by localized string names (`"Automatically hide and show the menu bar"`, `"Never"`, etc.). If your macOS display language is not English, change those strings to match your localized System Settings text.