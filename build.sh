#!/bin/zsh
# Build "AI Profiles.app" into ~/Applications
set -eu
cd "${0:A:h}"
out="$HOME/Applications/AI Profiles.app"
rm -rf "$out"
mkdir -p "$out/Contents/MacOS"
swiftc -O main.swift -o "$out/Contents/MacOS/AIProfiles"
cat > "$out/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>AI Profiles</string>
  <key>CFBundleIdentifier</key><string>local.heitor.ai-profiles</string>
  <key>CFBundleExecutable</key><string>AIProfiles</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
codesign -s - --force "$out"
echo "built $out"
