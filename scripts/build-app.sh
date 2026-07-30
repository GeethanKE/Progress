#!/bin/bash
# Builds Progress in release mode and wraps it into Progress.app
set -e

APP_NAME="Progress"
BUILD_DIR=".build/release"
APP_DIR="$APP_NAME.app"

# Version comes from the pushed git tag (e.g. v1.0.1 -> 1.0.1) so it's never
# stale. Falls back to 0.0.0 for local dev builds with no tags yet.
VERSION="$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')"
VERSION="${VERSION:-0.0.0}"

echo "==> Building $APP_NAME (release) — version $VERSION..."
swift build -c release

echo "==> Assembling $APP_DIR..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_DIR/Contents/MacOS/$APP_NAME"

echo "==> Building app icon..."
if [ -d "Resources/AppIcon.iconset" ]; then
    iconutil -c icns "Resources/AppIcon.iconset" -o "$APP_DIR/Contents/Resources/AppIcon.icns"
else
    echo "    (no Resources/AppIcon.iconset found — app will use the default icon)"
fi

cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.progress.menubar</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "==> Ad-hoc signing $APP_DIR..."
# Unsigned bundles get flagged by Gatekeeper as "damaged" on modern macOS,
# not just "unidentified developer". An ad-hoc signature (no paid Apple
# Developer account needed) is enough to fix that specific error, though the
# one-time "unidentified developer" right-click-to-open step still applies
# since this isn't notarized by Apple.
codesign --force --deep --sign - "$APP_DIR"

echo "==> Done. Move $APP_DIR to /Applications and double-click to launch."
