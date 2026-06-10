# iOS StandBy Plus

StandBy Plus is a SwiftUI concept app that reimagines iOS StandBy as a deeply customizable dashboard for a dark, cozy desk setup while still feeling polished in the light.

## What is included

- Distinct day and night palettes with custom background, surface, accent, and text colors.
- A window-like widget system with medium and huge cards that can be reordered from the in-app customization sheet.
- Clock styling controls with digital, split, and minimal layouts, plus 12/24-hour and seconds toggles.
- A unified call HUD design that surfaces incoming and active calls from multiple providers and exposes open-app, speaker, mute, accept, decline, and hang-up actions.
- A clean music surface with playback, repeat, shuffle, volume, seek, and open-app controls.
- A GitHub Actions workflow that builds an unsigned IPA artifact suitable for sideload workflows such as SideStore.

## Important platform note

iOS does not allow third-party apps to replace the built-in system StandBy experience or directly control live calls and media sessions across arbitrary third-party apps the way system software can. This project therefore focuses on:

- a production-quality standby-style UI,
- extensible models for call and media providers,
- handoff actions that open supported apps when available,
- and a polished demo implementation that can be extended with app-specific integrations where platform APIs allow it.

## Project layout

- `StandByPlus.xcodeproj` - Xcode project
- `StandByPlus/` - SwiftUI source, assets, and Info.plist
- `.github/workflows/build-unsigned-ipa.yml` - CI pipeline for unsigned IPA builds

## Build locally in Xcode

1. Open `StandByPlus.xcodeproj` in Xcode 16 or newer.
2. Choose an iPhone or iPad simulator, or a connected device.
3. Build and run the `StandByPlus` scheme.

## Build unsigned IPA in GitHub Actions

Push the branch to GitHub, then run the `Build Unsigned IPA` workflow. The workflow builds the app for `generic/platform=iOS`, packages the resulting `.app` into a `Payload` directory, and uploads `StandByPlus-unsigned.ipa` as an artifact.
