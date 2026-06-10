# StandBy Plus

StandBy Plus is a SwiftUI iOS app prototype for a more customizable, cozy
replacement-style standby dashboard. It is designed for landscape desk use, dark
workspaces, and sideloading through tools such as SideStore.

## Features

- Custom day and night color palettes instead of a fixed red night mode.
- Draggable widget "windows" with medium and huge sizes.
- Digital, analog, and minimal clock styles with optional seconds.
- Clean call HUD for Phone, WhatsApp, Discord, and FaceTime style calls:
  - Open the related app.
  - Accept or decline incoming call requests.
  - Active-call controls for speaker, mute, and hang up.
- Cozy music surface with:
  - Open app.
  - Play/pause.
  - Shuffle.
  - Repeat off/all/one.
  - Previous and next controls.
  - Duration and volume sliders.
- Smooth SwiftUI materials, gradients, spring animations, and dark/light usage.

## Important iOS limitation

Public iOS APIs do not let a normal app directly read or control calls from
other apps such as WhatsApp or Discord, and they do not let a third-party app
hang up, mute, or toggle speaker for another app's call. This prototype provides
the requested HUD and app-launching bridge while modeling those controls in-app.
Real cross-app call control would require private APIs/entitlements that are not
available to standard sideloaded apps.

## Building an unsigned IPA

The repository includes a GitHub Actions workflow:

```text
.github/workflows/build-unsigned-ipa.yml
```

Run **Build unsigned IPA** from GitHub Actions or push to a `cursor/**` branch.
The workflow builds the iOS app without code signing and uploads
`StandByPlus-unsigned.ipa` as an artifact.

## Local development

Open `StandByPlus.xcodeproj` in Xcode 15 or newer and run the `StandByPlus`
scheme on an iOS 17+ simulator or device.
