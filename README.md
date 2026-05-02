# Crown Dash: Princess Run — App Store Ready Starter

This package includes a polished web/PWA version of the game using the Adelynn sprite sheet.

## What is included
- `index.html` landing page · `privacy.html` · `terms.html`
- `play.html` playable game (also bundled as `Game/index.html` in the iOS app)
- Real sprite animation frames
- Smooth movement interpolation
- Jump, dash, run, fall, land animation switching
- Touch controls for mobile
- Keyboard controls for desktop
- Pause and mute buttons
- Procedural background music and sound effects
- Offline PWA support with service worker
- Web app manifest
- App icons
- Privacy policy starter

## Test locally
Open `http://localhost:8080/` for the landing page, or `http://localhost:8080/play.html` for the game only.

For best testing, run a local server:
```bash
python3 -m http.server 8080
```
Then open:
```text
http://localhost:8080/
```

## iOS app (Xcode project included)
An Xcode project lives at **`ios/CrownDash/`**. It wraps the same web game in a `WKWebView` and copies **`play.html` → `Game/index.html`** plus `assets` into the app bundle on every build (the marketing site files are not required in the app).

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) only if you edit `ios/CrownDash/project.yml` and need to regenerate the `.xcodeproj`.
2. Open **`ios/CrownDash/CrownDash.xcodeproj`** in Xcode.
3. Set your **Signing Team**, choose a simulator or device, press **Run**.

Details: `ios/CrownDash/README.md`.

## App Store checklist
- App icon: included.
- Privacy policy: included starter file.
- No external music dependency: included procedural music.
- No user data collected in this prototype.
- Mobile controls: included.
- Pause/mute controls: included.
- Offline/PWA support: included.
- Needs final App Store screenshots and metadata before submission.

## Recommended next production upgrades
- Add title screen art.
- Add 3 full levels.
- Add Game Center leaderboard.
- Add tutorial screen.
- Add rewarded ads only after the gameplay is stable.
- Add Apple in-app purchases only after a strong retention loop exists.


## Smoother sprite update
This version normalizes all character animation frames into equal-sized transparent PNGs to prevent sprite-sheet background flashes and frame jitter.


## Damage meter update
The player now starts with 100% health. Normal failed obstacle hits reduce health by 25%. Royal Rush/boss obstacles reduce health by 35%. The game ends at 0% health.


## Single-sprite frame fix
Animation frames were rebuilt using connected-component isolation so only the main character sprite remains in each PNG. This removes neighboring sprite-sheet bleed.
