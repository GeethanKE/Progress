#!/bin/bash
# Builds Progress.app (via build-app.sh) and packages it into a
# drag-to-Applications .dmg installer — the easiest possible install
# experience for someone who isn't a developer.
set -e

APP_NAME="Progress"
DMG_NAME="$APP_NAME.dmg"
STAGING_DIR="dmg-staging"

echo "==> Building $APP_NAME.app..."
./scripts/build-app.sh

echo "==> Preparing DMG staging folder..."
rm -rf "$STAGING_DIR" "$DMG_NAME"
mkdir "$STAGING_DIR"
cp -R "$APP_NAME.app" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

echo "==> Creating $DMG_NAME..."
hdiutil create -volname "$APP_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov -format UDZO \
  "$DMG_NAME"

rm -rf "$STAGING_DIR"

echo "==> Done. $DMG_NAME is ready to share."
echo "    Users just double-click it, then drag $APP_NAME.app onto the Applications shortcut."
