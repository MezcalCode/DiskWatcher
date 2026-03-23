# DiskWatcher

DiskWatcher is a native macOS menu bar app that shows the current free disk space as a percentage plus human-readable storage values.

If you install an unsigned release build on macOS, you may need to remove the quarantine attribute once before first launch. See the release notes below for the exact command.

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
- GitHub Actions creates the matching `vX.Y.Z` tag, signs the app with a Developer ID certificate, notarizes it, staples the ticket, and publishes the GitHub Release from that tag.
- If signing secrets are not configured yet, GitHub Actions falls back to an unsigned zip for internal testing.
- The build number is assigned automatically from the GitHub run number during CI and release builds.
- Local Xcode Release builds use the current git commit count as `CFBundleVersion`.
- On a Mac that shows the Gatekeeper warning, you can either right-click the app and choose `Open` once, or remove the quarantine attribute with `xattr -dr com.apple.quarantine DiskWatcher.app`.
- Release signing requires GitHub secrets for `APPLE_TEAM_ID`, `DEVELOPER_ID_CERTIFICATE_P12`, `DEVELOPER_ID_CERTIFICATE_PASSWORD`, `NOTARYTOOL_APPLE_ID`, and `NOTARYTOOL_APPLE_PASSWORD`.

## Local Install Workaround

If you copy the app into the Applications folder, the full path is usually:

```bash
/Applications/DiskWatcher.app
```

If macOS shows the “app is damaged and can’t be opened” message, run:

```bash
xattr -dr com.apple.quarantine /Applications/DiskWatcher.app
```

After that, open `DiskWatcher.app` again from `/Applications`.
