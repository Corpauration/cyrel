#!/bin/sh

flutter build web --web-renderer html --profile
flutter build apk

mkdir -p build/web/release
cp build/app/outputs/flutter-apk/app-release.apk build/web/release/cyrel.apk
