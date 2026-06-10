# StandBy+ — a massive overhaul for iOS StandBy

StandBy+ is a SwiftUI app that reimagines the built‑in iOS StandBy experience for
a dark, cozy workspace (and looks just as good in the light). It is designed to
be **sideloaded as an unsigned IPA** (e.g. via [SideStore](https://sidestore.io)),
and the IPA is **built automatically by GitHub Actions** — no Mac or paid
developer account required to produce a build.

> Point your phone at it on a charger, lean back, and get a clock, your widgets,
> your music, and incoming calls — your way.

---

## ✨ Features

### 1. Deep customization
- **Separate Day and Night themes.** Pick *any* colors for background, gradient,
  cards, primary/secondary text and accent — no more permanent creepy red.
- **Automatic or manual day/night switching** with configurable start hours, plus
  gentle **night dimming** for a dark room.
- **Color presets** (Cozy Night, Midnight Ocean, Forest, Sunset, Warm Day, Paper)
  as one‑tap starting points, fully editable afterwards.
- **Clock customization:** five faces (Digital, Flip, Analog, Minimal, Stacked),
  four font personalities (Rounded, Standard, Serif, Monospaced), 12/24‑hour,
  optional seconds, and accent highlighting.
- **Windows‑style widget placement.** Drag widgets *anywhere* on the canvas and
  resize each between **Medium** and **Huge** — this is free placement, not the
  fixed OS grid. Available widgets: Clock, Date, Calendar, Weather, Battery,
  Music, Quote, World Clock. Layouts persist automatically.
- **Ambient motion** background and **burn‑in protection drift**.

### 2. Call HUD
A full‑surface HUD appears when a call is ringing or active:
- **Open app**, **hang up**, **speaker**, **mute**, and **accept / decline**
  (the last two only while ringing).
- Works with the system **Phone** app and **CallKit‑based** VoIP apps
  (WhatsApp, Messenger, Telegram, FaceTime, and others) via `CXCallObserver`.
- Built‑in **previews** in Settings so you can see and tune the HUD any time.

> **Platform honesty:** iOS lets any app *observe* call state system‑wide, but it
> does **not** let a third‑party app silently answer, mute or hang up *another
> app's* call. Where the OS forbids the direct action, the HUD performs the safe
> equivalent — it reflects the state and **deep‑links into the owning app** so you
> finish there. Mute/end are honored for calls the app itself owns. This is an iOS
> sandbox limitation, not a missing feature.

### 3. Clean music surface
A calm, legible now‑playing screen with the full control set:
- Open source app, play/pause, next, previous, shuffle, loop‑all / loop‑one,
  a draggable **scrubber**, and a real system **volume slider**.
- On device it reflects whatever app owns playback via Apple's private
  **MediaRemote** framework (resolved safely at runtime). When MediaRemote is
  unavailable (Simulator, previews, or a locked‑down OS build) it falls back to a
  built‑in **demo session** so the whole UI stays usable.

### UI
Smooth, spring‑based transitions, frosted glass panels, swipeable Widgets ↔ Music
pages, long‑press anywhere for settings. Built dark‑first, light‑friendly.

---

## 🧱 Project layout

```
project.yml                      # XcodeGen project definition
.github/workflows/build-ipa.yml  # CI: builds the unsigned IPA
StandByPlus/
  App/                           # App entry, RootView, palette environment
  Models/                        # Settings, themes, colors, widgets, clock styles
  Managers/                      # CallManager, NowPlayingManager, VolumeController
  Bridge/                        # MediaRemote private-framework wrapper (ObjC)
  Views/                         # Clock, widget canvas, music, call HUD, settings
  Assets.xcassets/               # Accent color
  StandByPlus-Bridging-Header.h
```

The `.xcodeproj` is **generated** by [XcodeGen](https://github.com/yonsm/XcodeGen)
and is intentionally git‑ignored.

---

## 🤖 Building the unsigned IPA (GitHub Actions)

Every push and every `workflow_dispatch` run builds an **unsigned IPA**:

1. Push this repository to GitHub.
2. Open the **Actions** tab → **Build Unsigned IPA** → run it (or just push).
3. When it finishes, download the **`StandByPlus-unsigned-ipa`** artifact.
4. Tagging a commit `v*` (e.g. `v1.0.0`) additionally attaches the IPA to a
   GitHub Release.

The workflow runs on macOS, installs XcodeGen, generates the project, and archives
with code signing fully disabled:

```bash
xcodebuild -project StandByPlus.xcodeproj -scheme StandByPlus \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  -archivePath build/StandByPlus.xcarchive clean archive \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

It then wraps `StandByPlus.app` into `Payload/` and zips it to
`StandByPlus-unsigned.ipa`.

## 📲 Installing via SideStore

1. Download `StandByPlus-unsigned.ipa` from the Actions artifact (or Release).
2. In **SideStore**, tap **+**, choose the IPA, and let SideStore sign it with
   your own free Apple ID and install it.
3. Put the phone on a charger in landscape for the full StandBy feel.

> SideStore re‑signs the app with your personal account on install, so the IPA we
> ship is intentionally unsigned.

---

## 🛠 Building locally (optional, needs a Mac)

```bash
brew install xcodegen
xcodegen generate
open StandByPlus.xcodeproj
```

Then build/run as usual. To produce an unsigned IPA locally, use the same
`xcodebuild` command shown above.

---

## 📝 Notes & limitations
- **Now Playing via MediaRemote** is a private API. Apple has tightened access on
  newer iOS releases, so live third‑party now‑playing data may be limited on some
  versions; the demo fallback keeps the UI fully functional regardless.
- **Weather** is a tasteful placeholder (WeatherKit needs a signed entitlement).
- **Call control** of other apps' calls is limited by the iOS sandbox as described
  above.
- Targets **iOS 17.0+**. No app icon is bundled (sideloaded utility); add one to
  `Assets.xcassets` if you like.
```
