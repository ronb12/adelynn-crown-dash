# Crown Dash: Princess Run — App Store Ready Starter

This package includes a polished web/PWA version of the game using the Adelynn sprite sheet.

## What is included
- `index.html` playable game
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
Open `index.html` in a browser.

For best testing, run a local server:
```bash
python3 -m http.server 8080
```
Then open:
```text
http://localhost:8080
```

## Convert to iOS app
Best simple path:
1. Open Xcode.
2. Create a new iOS app.
3. Add a `WKWebView`.
4. Bundle this folder into the app.
5. Load `index.html` locally.
6. Set landscape orientation.
7. Add the app icon from `assets/icon-1024.png`.

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
