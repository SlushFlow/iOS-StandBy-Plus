# StandBy+ — iOS-StandBy-Plus

A massive overhaul of iPhone StandBy mode, packaged as a regular iOS app you can sideload with [SideStore](https://sidestore.io) (or AltStore / TrollStore).

![Build unsigned IPA](../../actions/workflows/build-ipa.yml/badge.svg)

## What it does

StandBy+ turns your iPhone into a cozy, fully customizable bedside / desk display — without being locked into Apple's two-widget layout or that creepy all-red night mode.

### Deep customization
- **Separate day and night themes**, each with fully custom colors: background, widget background, primary/secondary text, and accent. Night mode can be any color you like — warm amber, teal, lavender, ember… not just red.
- **Automatic night switching** on a schedule you pick (e.g. 21:00 → 07:00), or force day/night manually from the toolbar.
- **Built-in presets** (Cozy Amber, Midnight Teal, Lavender, Ember) as starting points.
- **Extra dimming slider** per theme for truly dark rooms.

### Windows-style widgets
- Long-press any widget to enter edit mode, then **drag widgets anywhere** on screen — like floating windows, not a fixed OS grid.
- Each widget comes in **Medium** or **Huge**; toggle with one tap in edit mode.
- Add as many as you want: **Clock, Music, Calendar, Battery**. Remove or reset the layout anytime.

### Clock customization
- Four faces: **Digital, Stacked (StandBy-style), Analog, Minimal**.
- Font styles (Rounded / Standard / Serif / Mono), 12/24-hour time, seconds, date line, and an optional fully custom clock color.

### Call HUD
- Uses CallKit's system call observer, so it reacts to calls from **any CallKit app** (Phone, FaceTime, WhatsApp, Telegram, …).
- A glassy HUD slides in with **Accept / Decline** for incoming calls, and **Mute / Speaker / Hang Up** plus a live call timer for ongoing ones.
- One-tap **"Open App"** shortcuts (Phone, FaceTime, WhatsApp, Discord, Telegram, Messenger) to jump straight to the app that owns the call.

### Clean music surface
- Easy-on-the-eyes now-playing UI with blurred artwork backdrop.
- Full control set: **play/pause, next/previous, shuffle, repeat all / repeat one, scrubbing slider with elapsed/total time, real system volume slider**, and an **"Open Music App"** button (Apple Music, Spotify, YouTube Music, SoundCloud — pick your default in Settings).
- Available as a medium widget, a huge widget, or a full-screen expanded player.

### UI
- Smooth spring animations everywhere, haptics on every interaction.
- Screen stays awake while the app is open.
- Designed dark-and-cozy first, but the day themes are bright-room friendly.

## Installing with SideStore

1. Go to the repo's **Actions** tab → latest **Build unsigned IPA** run → download the `StandByPlus-unsigned-ipa` artifact (or grab `StandByPlus.ipa` from a tagged Release).
2. Unzip the artifact if needed so you have `StandByPlus.ipa`.
3. Open SideStore → **+** → pick the IPA. SideStore re-signs it with your Apple ID during install (the IPA itself ships unsigned on purpose).
4. Launch StandBy+, allow Music/Calendar access when asked, set your phone on a stand, and enjoy.

## Building locally

Requires macOS with Xcode 15+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen
xcodegen generate
open StandByPlus.xcodeproj
```

The CI workflow (`.github/workflows/build-ipa.yml`) does the same thing headlessly: generate the project, build unsigned for `generic/platform=iOS`, zip the `.app` into `Payload/`, and upload `StandByPlus.ipa`.

## Honest notes on iOS limitations

- **Calls:** iOS sandboxing only lets the app that *owns* a call actually answer/hang up/mute it. StandBy+ requests these actions through CallKit; when iOS refuses (third-party calls), it tells you and the quick-open app buttons are right there. Call detection itself works for all CallKit apps.
- **Music:** transport controls drive the system music player (Apple Music). For Spotify & friends, the volume slider still works (it's true system volume) and the open-app button gets you to their UI in one tap. iOS does not expose cross-app "now playing" control to normal sandboxed apps.
- This app **replaces the StandBy experience while it's open in the foreground** — a sandboxed app cannot replace the OS-level StandBy screen itself.

## Project layout

```
project.yml                  # XcodeGen project definition
StandByPlus/
  App/                       # App entry + main standby screen
  Theme/                     # Palettes, theme manager, clock preferences
  Widgets/                   # Widget models, canvas (drag/resize), clock/calendar/battery
  Music/                     # System music controller, player UI, volume slider
  Calls/                     # CallKit observer + call HUD
  Settings/                  # Settings screens
  Support/                   # Codable colors, helpers
  Resources/                 # Asset catalog (app icon)
  Info.plist
.github/workflows/build-ipa.yml
```
