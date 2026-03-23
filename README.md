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

## Releases

- Bump `MARKETING_VERSION` in Xcode when you are ready for a new release.
- Shared build defaults live in `Config/Base.xcconfig`.
- Version values live in `Config/Versioning.xcconfig`.
- Target signing and Debug/Release overrides live in `Config/TargetCommon.xcconfig`, `Config/TargetDebug.xcconfig`, and `Config/TargetRelease.xcconfig`.
- Push the change to `main`.
- GitHub Actions creates the matching `vX.Y.Z` tag, builds the app, and publishes the GitHub Release from that tag.
- The build number is assigned automatically from the GitHub run number during CI and release builds.
- Local Xcode Release builds use the current git commit count as `CFBundleVersion`.
