#!/bin/bash
# Print iOS Simulator name, runtime, state, and UUID (for simulator-protect.config).
set -e
echo "Copy the UUID of the device you use in Xcode (Run destination) into scripts/simulator-protect.config"
echo ""
xcrun simctl list devices | sed -n '/== Devices ==/,$p'
