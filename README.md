# StandBy Plus

A massive overhaul of the iPhone nightstand experience — built as a standalone iOS app with deep customization, a call HUD, and a full music control surface. Designed for landscape use on your desk or nightstand, with a dark cozy workspace aesthetic and optional light themes.

## Features

### Customization
- **Separate day and night color palettes** — background, surface, accent, text, and glow colors (no more locked-in red StandBy look)
- **Window-style widget placement** on a grid with **medium** or **huge** sizes
- **Clock styles**: digital, analog, minimal, and flip
- Font weight, 12/24-hour time, and seconds toggle
- Preset palettes: Cozy Dark, Cozy Light, Midnight, Warm Sunrise

### Call HUD
- Observes active calls via **CallKit** (Phone, FaceTime, and third-party apps that register with CallKit such as WhatsApp, Discord, Telegram, etc.)
- Floating HUD with:
  - Open calling app
  - Mute / unmute (audio route)
  - Speaker toggle
  - End call (opens source app — iOS restricts cross-app call control)
  - Accept / decline for incoming requests (opens source app)

### Music Player
- Now Playing metadata and artwork
- Open source app (Apple Music, Spotify, etc.)
- Play / pause, next, previous
- Shuffle, loop all, loop one
- Scrubbable timeline and system volume slider

### UI
- Smooth spring animations (with reduce-motion support)
- Landscape-first layout
- Glassy cards, soft gradients, and comfortable typography

## Install via SideStore

This project builds an IPA through GitHub Actions for sideloading with [SideStore](https://sidestore.io/). The CI build uses **ad-hoc signing** (`codesign -`) so the Swift runtime and frameworks are embedded in the bundle — without this step Xcode produces a ~170 KB shell with no runnable binary content. SideStore re-signs with your Apple ID on install.

1. Open the **Actions** tab in this repository
2. Select **Build Unsigned IPA** and run the workflow (or download the artifact from a completed run)
3. Download the `StandByPlus-unsigned-ipa` artifact
4. Install with SideStore and sign with your Apple ID

Tagged releases (`v*`) automatically attach the IPA to a GitHub Release.

## Build locally (macOS)

```bash
brew install xcodegen
xcodegen generate
open StandByPlus.xcodeproj
```

Or build from the command line:

```bash
xcodegen generate
xcodebuild -project StandByPlus.xcodeproj -scheme StandByPlus -sdk iphoneos -configuration Release CODE_SIGNING_ALLOWED=NO build
```

## iOS API notes

Apple sandboxing applies to all apps, including sideloaded ones:

| Feature | Behavior |
|---------|----------|
| CallKit observation | Works for apps that integrate CallKit |
| Hang up / accept / decline other apps | Opens the source app; cannot remotely control another app's call UI |
| Music transport controls | Full control for Apple Music via `MPMusicPlayerController`; other apps expose Now Playing info |
| StandBy system mode | This is a companion app — it does not replace the system StandBy lock screen |

## Project structure

```
StandByPlus/           SwiftUI app source
project.yml            XcodeGen project definition
.github/workflows/     CI pipeline for unsigned IPA
```

## Requirements

- iOS 17.0+
- iPhone (landscape)
- Xcode 15+ to build locally
- SideStore or similar for installation

## License

MIT
