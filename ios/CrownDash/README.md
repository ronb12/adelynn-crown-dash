# CrownDash (iOS)

Native iOS game built with **SwiftUI** + **SpriteKit**. The iOS target does not load `play.html`, does not embed a `Game/` web bundle, and does not use `WKWebView`.

**Offline:** The game runs entirely as native Swift/SpriteKit code. No cellular/Wi-Fi is required for gameplay.

## Gameplay features

- Princess Adelynn native SpriteKit runner with jump, dash, lane switching, shields, coins, hazards, and themed powers.
- First-run tutorial covering controls, powers, missions, and outfit progression.
- Royal missions with coin rewards, local high score, coin bank, and unlockable outfits.
- Settings for sound, haptics, and reduced motion.
- Multi-zone progression: Castle Courtyard, Rose Garden, Crystal Bridge, and Moonlit Ballroom.
- Game Center-ready leaderboard and achievement hooks via `CrownDash.entitlements`.
- Generated Princess Adelynn concept art bundled in `Assets.xcassets/PrincessAdelynnConcept.imageset`.

## Requirements

- Xcode 15+ (tested with Xcode 16 / iOS 18 SDK)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — only needed if you edit `project.yml` and need to regenerate `CrownDash.xcodeproj`

## Open in Xcode

```bash
open ios/CrownDash/CrownDash.xcodeproj
```

Or double-click `CrownDash.xcodeproj` in Finder.

## First-time setup

1. Select the **CrownDash** target → **Signing & Capabilities**.
2. Choose your **Team** so the app can run on a device.
3. Pick an **iPhone or iPad simulator** (or a device) and press **Run**.

### Keeping your simulator when freeing disk space

Automated cleanup must **not** run `xcrun simctl erase all` — it wipes every simulator’s data.

1. From the repo root, list devices and copy the UUID of the simulator you use in Xcode:
   ```bash
   ./scripts/list-simulators.sh
   ```
2. Copy `scripts/simulator-protect.config.example` to **`scripts/simulator-protect.config`** (gitignored) and paste **one UUID per line** for each simulator you want to preserve.
3. To reclaim CoreSimulator space **without** erasing those devices:
   ```bash
   ./scripts/cleanup-simulators-keep-protected.sh           # dry-run
   ./scripts/cleanup-simulators-keep-protected.sh --execute # actually erase others
   ```

The app supports **portrait and landscape**, is **full screen**, with the status bar hidden (see `Info.plist`).

## Regenerating the Xcode project

After changing `project.yml`:

```bash
cd ios/CrownDash
xcodegen generate
```

## App Store notes

- **Bundle ID:** `com.bradleyvirtual.crowndash` (change in `project.yml` under `PRODUCT_BUNDLE_IDENTIFIER` if needed).
- **Developer team:** `DEVELOPMENT_TEAM` is set to **4SQJ3AH62S** (Bradley Virtual Solutions, LLC) in `project.yml`.
- **TestFlight (Fastlane):** Step-by-step **`TESTFLIGHT.md`** (API key, `fastlane beta`). Requires XcodeGen (`brew install xcodegen`) and Fastlane (`brew install fastlane`).
- **Icon:** `Assets.xcassets` uses the same artwork as `assets/icon-1024.png` at the repo root; update `AppIcon` in the asset catalog when you change branding.
- **Privacy manifest:** `PrivacyInfo.xcprivacy` is included (no tracking, no collected data types declared). Regenerate the Xcode project after edits: `xcodegen generate`.
- **Human review:** Apple does not publish an automated “pass/fail” checklist; approval is discretionary. See **App Store readiness** below.

### App Store readiness (high level)

Things this codebase supports:

| Area | Status |
|------|--------|
| Native game implementation | OK — SwiftUI + SpriteKit, no web wrapper |
| Export compliance plist | `ITSAppUsesNonExemptEncryption` = `false` in `Info.plist` |
| Privacy manifest | `PrivacyInfo.xcprivacy` bundled |
| Tracking / ATT | Not used — no `NSUserTrackingUsageDescription` |
| Sensitive APIs | No camera/mic/photos/contacts plist strings (not requested) |

You still must complete **in App Store Connect** (not in this repo): privacy questionnaire answers that match “no data collected,” **Privacy Policy URL** (host `PRIVACY_POLICY.md` or equivalent), **support URL**, screenshots, age rating, copyright, and signing/provisioning. Metadata must match the real app ([Guideline 2.3](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata)).

If you later add ads, analytics, IAP, accounts, or online leaderboards, update the privacy manifest, `Info.plist` usage descriptions, and privacy policy before submission.
