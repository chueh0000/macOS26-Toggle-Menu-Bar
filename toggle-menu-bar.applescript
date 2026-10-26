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

		-- Target the exact popup button from your terminal output
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
