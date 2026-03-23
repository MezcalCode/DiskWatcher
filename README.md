# DiskWatcher

DiskWatcher is a native macOS menu bar app that shows the current free disk space as a percentage plus human-readable storage values.

## Features

- Shows the current free disk percentage in the macOS menu bar.
- Includes the free space amount in GB and MB inside the menu.
- Refreshes on detected filesystem changes and on a timer fallback.
- Attempts to register itself to launch at login on startup.
- Runs as a menu bar only app without a Dock icon.

## Open The Project

1. Open `DiskWatcher.xcodeproj` in Xcode.
2. Build and run the `DiskWatcher` scheme.
3. The app will appear in the macOS menu bar near the clock and Wi-Fi icons.

## Notes

- Launch-at-login registration may fail while running directly from a debug build location. This is expected behavior from macOS in some development setups.
- The project is configured as a status bar app with `LSUIElement` enabled.
