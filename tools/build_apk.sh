#!/usr/bin/env bash
# Build the flutterTrain offline Python + Go training APK.
#
# Prerequisites (see docs/BUILD.md):
#   - Flutter SDK (>=3.22) with Android toolchain
#   - JDK 17
#   - Android SDK + NDK (ANDROID_SDK_ROOT / ANDROID_NDK_ROOT set)
#   - Go >= 1.22 and gomobile (go install golang.org/x/mobile/cmd/gomobile@latest)
#   - rsync
#
# Usage:
#   tools/build_apk.sh            # incremental build
#   REBUILD_GO=1 tools/build_apk.sh   # force rebuild of the Go engine .aar
#   SKIP_GO=1 tools/build_apk.sh      # skip Go engine (no Go examples in app)
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"
APP="$ROOT/flutter_train"

FLUTTER="${FLUTTER:-flutter}"
GOBIN="${GOBIN:-$(go env GOPATH)/bin}"
export PATH="$GOBIN:$PATH"  # gomobile shells out to `gobind`; it must be on PATH

# 1. Fresh copy of courseware into bundled assets (source of truth = courseware/)
mkdir -p "$APP/assets/courseware"
command -v rsync >/dev/null || { echo "rsync required"; exit 1; }
rsync -a --delete "$ROOT/courseware/" "$APP/assets/courseware/"

# 1b. Export a single pack.json for Flutter assets (no dir enumeration on device)
echo ">> exporting content pack ..."
python3 "$ROOT/tools/export_content.py"

# 2. Apply the Android overlay (idempotent) on top of `flutter create` output
#    The Flutter template now emits Kotlin-DSL build files + a Gradle 9 wrapper,
#    which conflict with our Groovy DSL overlay (AGP 8.3.1). Remove them and
#    pin the wrapper to a Gradle version AGP 8.3.1 supports.
rsync -a "$APP/android-overlay/" "$APP/android/"
rm -f "$APP/android/build.gradle.kts" "$APP/android/settings.gradle.kts" "$APP/android/app/build.gradle.kts" "$APP/android/flutter_train_android.iml"
WRAPPER="$APP/android/gradle/wrapper/gradle-wrapper.properties"
if [ -f "$WRAPPER" ] && ! grep -q "gradle-8.10.2" "$WRAPPER"; then
  sed -i 's#distributionUrl=.*#distributionUrl=https\\://services.gradle.org/distributions/gradle-8.10.2-all.zip#' "$WRAPPER"
  echo ">> pinned gradle wrapper to 8.10.2"
fi

# 3. Build the Go engine .aar via gomobile bind (arm64 only)
GO_AAR="$APP/android/app/libs/goengine-release.aar"
if [ "${SKIP_GO:-0}" != "1" ]; then
  if [ ! -f "$GO_AAR" ] || [ "${REBUILD_GO:-0}" = "1" ]; then
    echo ">> building Go engine (gomobile bind) ..."
    ( cd "$APP/go" && "$GOBIN/gomobile" bind \
        -target=android/arm64 \
        -androidapi=24 \
        -javapkg com.fluttertrain \
        -o "$GO_AAR" . )
  else
    echo ">> Go engine .aar up to date ($GO_AAR)"
  fi
fi

# 4. Flutter release build
#    --android-skip-build-dependency-validation: newer Flutter requires Gradle
#    >=8.14, but our overlay pins Gradle 8.10.2 (the version AGP 8.3.1's
#    Groovy DSL needs). AGP 8.3.1 + Gradle 8.10.2 is a valid, tested pairing;
#    this only bypasses Flutter's own advisory version gate.
#    --target-platform android-arm64: the Go engine .aar is arm64-only and
#    Chaquopy's Python 3.13 doesn't ship an armeabi-v7a build, so building
#    for Flutter's default multi-ABI set (arm,arm64,x64) fails Chaquopy's
#    per-variant ABI check. Restrict to arm64 to match.
echo ">> flutter build apk --release ..."
( cd "$APP" && "$FLUTTER" build apk --release --target-platform android-arm64 --android-skip-build-dependency-validation )

APK="$APP/build/app/outputs/flutter-apk/app-release.apk"
echo
echo "APK ready: $APK"
ls -lh "$APK"
echo "Install: adb install -r \"$APK\""