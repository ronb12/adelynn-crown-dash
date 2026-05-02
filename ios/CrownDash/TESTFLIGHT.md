# TestFlight (Fastlane) — Bradley Virtual Solutions, LLC

**Team ID:** `4SQJ3AH62S`  
**Bundle ID:** `com.bradleyvirtual.crowndash`  
**Display name:** Adelynn’s Crown Dash

> I **cannot** log in to your Apple account or complete a TestFlight upload from this environment. Follow the steps below on your Mac (where Xcode and your signing certificates work).

## Disk space

Archives, Derived Data, and temp files are directed under `ios/CrownDash/build/`, `DerivedDataFastlane/`, and `.tmp/` on your project disk. **Xcode still uses space on the system volume** for some caches — if `fastlane` fails with **“No space left on device”** on **Macintosh HD**, free several gigabytes there (Empty Trash, delete large downloads, clear Xcode archives) before retrying.

If the boot volume is almost full, point temp files at your external project disk before running Fastlane:

```bash
export TMPDIR="/Volumes/My Passport for Mac/Adelynn Crown Dash/.tmp"
mkdir -p "$TMPDIR"
```

Using **`/bin/bash --noprofile --norc -c '…'`** avoids zsh creating temp files on a full startup disk when launching commands from some environments.

## Prereqs

1. **Xcode** with command-line tools: `xcode-select --install`
2. **XcodeGen:** `brew install xcodegen`
3. **Fastlane:** `brew install fastlane` (recommended; avoids system Ruby 2.6 + Bundler native gem failures)

Optional: Bundler + `Gemfile` works if you use **Homebrew Ruby 3** (`brew install ruby`) and run `bundle install` from `ios/CrownDash`.

## App Store Connect

1. Create an app with bundle ID **`com.bradleyvirtual.crowndash`** if it does not exist.  
2. **Users and Access → Keys → App Store Connect API** → create a key (**Developer** or **App Manager**). Download **`AuthKey_XXXXXXXXXX.p8`** once and note **Issuer ID** and **Key ID**.

## Configure secrets (local only — do not commit)

Create `ios/CrownDash/fastlane/.env` (gitignored):

```bash
APPSTORE_CONNECT_KEY_ID=XXXXXXXXXX
APPSTORE_CONNECT_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
APPSTORE_CONNECT_KEY_PATH=fastlane/AuthKey_XXXXXXXXXX.p8
```

Put the `.p8` file under `ios/CrownDash/fastlane/` or point `APPSTORE_CONNECT_KEY_PATH` to an absolute path.

Optional **Apple ID upload** (instead of the API key trio above — pick one approach):

```bash
FASTLANE_APPLE_ID=you@company.com
FASTLANE_PASSWORD=xxxx-xxxx-xxxx-xxxx
BUILD_NUMBER=2
TESTFLIGHT_WHAT_TO_TEST="Build for internal testing."
```

`FASTLANE_PASSWORD` must be an **app-specific password** from [appleid.apple.com](https://appleid.apple.com) → Sign-In and Security → App-Specific Passwords — **not** your normal Apple ID password.

**Security:** Never commit `.env` or paste passwords into GitHub/issues/chat. If a password was exposed, **revoke** it on appleid.apple.com and create a new app-specific password.

Fastlane loads `fastlane/.env` when present (see [environment variables](https://docs.fastlane.tools/advanced/#environment-variables)).

If `.env` is not auto-loaded, run: `export $(grep -v '^#' fastlane/.env | xargs)` before `fastlane beta`.

## Upload

```bash
cd ios/CrownDash
fastlane generate   # optional; beta runs this anyway
fastlane beta
```

Lanes:

| Lane             | Purpose                                                                 |
|-----------------|-------------------------------------------------------------------------|
| `generate`      | `xcodegen generate`                                                     |
| `build`         | Release IPA only → `build/`                                           |
| `create_asc_app`| Create App Store Connect app + Developer Portal App ID (bundle ID must match `project.yml`). Optional env: `ASC_SKU`, `ASC_APP_NAME`. |
| `beta`          | Generate + IPA + TestFlight                                             |

After `create_asc_app`, if Apple reports the SKU is already used, run again with e.g. `ASC_SKU=bradleyvirtual-crowndash-ios-2 fastlane create_asc_app`.

## Notes

- **`project.yml`** sets `DEVELOPMENT_TEAM` to **4SQJ3AH62S** so Xcode signing matches your team.
- The membership **Developer ID** UUID (e.g. from Apple’s portal) is **not** the same as **Team ID** or API keys — use **Team ID** `4SQJ3AH62S` for signing.
- If upload fails with “wrong team”, try `FASTLANE_ITC_TEAM_ID` set to the App Store Connect team identifier (often same as Team ID for a single-team org).
