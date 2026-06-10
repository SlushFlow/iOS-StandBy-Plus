# StandbyMode

A fully customizable replacement for iOS's built-in StandBy mode, designed for sideloading via SideStore.

## Features

### Customizable Theming
- Separate color palettes for **day** and **night** modes — no more locked-in red tint
- 6 built-in presets (Ocean, Sunset, Forest, Midnight, Cherry, Arctic) plus full manual hex-color editing
- Automatic day/night switching based on time of day, or manual override
- Colors for primary, secondary, accent, background, surface, and text are all independently adjustable

### Widget System
- **Drag-and-drop** widget placement — move widgets anywhere on screen like desktop windows
- Two sizes: **Medium** (compact) and **Huge** (full-featured)
- Toggle resize on each widget, remove widgets, or add new ones from settings
- Available widgets:
  - **Clock** — 5 styles: Digital, Analog, Minimal, Flip, Neon
  - **Music** — Now Playing with full controls
  - **Calendar** — Month grid (huge) or day display (medium)
  - **Weather** — Temperature and conditions
  - **Battery** — Circular gauge with charge status
  - **Photo** — Photo display placeholder

### Clock Customization
- 5 distinct clock styles with unique visual character
- Toggle seconds display, 24-hour format, date display
- All styles respond to theme colors

### Call HUD
- Detects incoming and active calls via CallKit
- Shows caller info with source app identification (Phone, WhatsApp, Discord, FaceTime, Telegram)
- **Incoming calls**: Accept / Decline buttons with animated pulse indicator
- **Active calls**: Duration timer, mute, speaker toggle, hang up, open source app
- **On hold**: Resume and end call controls
- Smooth slide-in/out animations with blur background

### Music Player
- Compact widget view with album art, track info, and basic controls
- Full-screen detail panel with:
  - Album artwork with animated scaling
  - Draggable seek bar with time labels
  - Play/pause, next, previous track
  - Shuffle and loop (none / all / one) toggles
  - Volume slider
  - Open source app button
- Integrates with system `MPMusicPlayerController`

### UI/UX
- Dark, cozy aesthetic by default — optimized for nightstand/desk use
- Smooth spring animations throughout
- Keep-screen-on toggle (disables idle timer)
- Settings panel slides in from the right with sectioned controls
- Status bar hidden, system overlays hidden for immersive experience

## Building

### Requirements
- Xcode 15+ with iOS 16.0 SDK
- macOS 13+

### Local Build
```bash
xcodebuild \
  -project StandbyMode.xcodeproj \
  -scheme StandbyMode \
  -sdk iphoneos \
  -configuration Release \
  archive \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

### GitHub Actions (Automated)
Push to `main` or create a tag (`v1.0`, etc.) to trigger the CI workflow. The unsigned IPA will be available as a build artifact, or attached to a GitHub Release if you push a version tag.

## Installation

1. Download the `StandbyMode.ipa` from [GitHub Actions artifacts](../../actions) or [Releases](../../releases)
2. Open **SideStore** on your device
3. Import the IPA and install
4. Open StandbyMode and customize your setup

## Project Structure

```
StandbyMode/
├── StandbyModeApp.swift          # App entry point
├── Info.plist                     # App configuration
├── Models/
│   ├── ThemeManager.swift         # Day/night color theming
│   ├── WidgetManager.swift        # Widget state and positioning
│   ├── SettingsManager.swift      # Clock and display preferences
│   ├── CallManager.swift          # CallKit integration
│   └── MusicPlayerManager.swift   # MediaPlayer integration
├── Views/
│   ├── StandbyContainerView.swift # Main container with background
│   ├── WidgetContainerView.swift  # Draggable widget wrapper
│   ├── CallHUDView.swift          # Call overlay HUD
│   ├── MusicDetailView.swift      # Full music player sheet
│   ├── SettingsView.swift         # Settings panel
│   └── Widgets/
│       ├── ClockWidgetView.swift   # 5 clock styles
│       ├── MusicWidgetView.swift   # Compact/large music widget
│       ├── CalendarWidgetView.swift
│       ├── WeatherWidgetView.swift
│       ├── BatteryWidgetView.swift
│       └── PhotoWidgetView.swift
└── Assets.xcassets/               # App icons and colors
```

## License

MIT
