# iOS StandBy Plus

StandBy Plus is a SwiftUI iOS app that reimagines StandBy mode with a customizable and workspace-friendly interface.

## Included features

- **Deep customization**
  - Separate day and night palettes
  - Clock style options (digital, monospaced, rounded)
  - 12/24-hour and seconds toggles
  - Widget window sizing presets (medium and huge)
- **Unified call HUD experience**
  - Incoming, outgoing, and active call cards
  - HUD actions for mute, speaker, hang up, accept/decline, and open source app
  - Designed to work as a clean "single pane" call command center
- **Clean music panel**
  - Open source app shortcut
  - Play/pause, previous, next
  - Loop all / loop one / off
  - Shuffle toggle
  - Duration and volume sliders
- **Comfort-first design**
  - Dark cozy defaults with smooth transitions
  - Light mode support for daytime usage

## Important platform constraints

iOS does not permit arbitrary control of calls from other apps (for example, directly hanging up a WhatsApp or Discord call) unless those apps expose supported integration points and/or the call is represented through permitted system APIs.  
This project ships with a **unified HUD UI and action architecture** plus app deep links, and is ready for deeper integrations where allowed by public APIs.

## Build unsigned IPA with GitHub Actions

The repository includes:

- `.github/workflows/build-unsigned-ipa.yml`

It compiles the app on `macos-latest` with signing disabled and packages:

- `StandbyPlus-unsigned.ipa`

Download the artifact from the workflow run and install with your preferred sideload tool (for example, SideStore signing on device).

## Local development

1. Open `StandbyPlus.xcodeproj` in Xcode.
2. Run the `StandbyPlus` scheme on a device or simulator.
3. Adjust bundle identifier and signing team if you want to create a signed build locally.
