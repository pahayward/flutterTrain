# flutter_train (app)

The Flutter application that powers **flutterTrain** — a fully offline
training harness for Android that runs Python and Go courseware with embedded
CPython (Chaquopy) and yaegi (gomobile) runners.

This directory is the Flutter package. It is treated largely as build output:
run `flutter create` to generate the Android scaffolding, then
`tools/build_apk.sh` (from the repo root) overlays `android-overlay/`, packs
the courseware into `assets/courseware/pack.json`, binds the Go engine, and
builds the release APK.

See the repository root [`README.md`](../README.md) and
[`docs/BUILD.md`](../docs/BUILD.md) for setup, build, and verification steps.