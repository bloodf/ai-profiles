#!/bin/zsh
# Build "AI Profiles.app" (universal) into ./build. Pass --install to copy it to /Applications.
set -eu
cd "${0:A:h}"
app="build/AI Profiles.app"
rm -rf build
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
for arch in arm64 x86_64; do
  swiftc -O -target "$arch-apple-macos14.0" main.swift -o "build/AIProfiles-$arch"
done
lipo -create build/AIProfiles-arm64 build/AIProfiles-x86_64 -output "$app/Contents/MacOS/AIProfiles"
rm build/AIProfiles-*
cp Info.plist "$app/Contents/Info.plist"
codesign -s - --force "$app"
ditto -c -k --keepParent "$app" "build/AI-Profiles.zip"
echo "built $app"

if [[ "${1:-}" == "--install" ]]; then
  pkill -x AIProfiles || true
  rm -rf "/Applications/AI Profiles.app"
  cp -R "$app" /Applications/
  echo "installed /Applications/AI Profiles.app"
fi
