fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios generate

```sh
[bundle exec] fastlane ios generate
```

Regenerate CrownDash.xcodeproj with XcodeGen (install: brew install xcodegen)

### ios build

```sh
[bundle exec] fastlane ios build
```

Build a Release .ipa for App Store / TestFlight (no upload)

### ios create_asc_app

```sh
[bundle exec] fastlane ios create_asc_app
```

Create app record on App Store Connect + Identifiers in Developer Portal (produce). Uses API key from .env if set; otherwise FASTLANE_APPLE_ID + FASTLANE_PASSWORD.

### ios upload_ipa

```sh
[bundle exec] fastlane ios upload_ipa
```

Upload existing build/CrownDash.ipa to TestFlight (no archive — use when boot disk is low on space)

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload App Store screenshots only (no metadata, no binary)

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload App Store metadata only (no screenshots, no binary, no review submission)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight (internal testers)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
