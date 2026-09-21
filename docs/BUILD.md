# Building the APK

This app (flutterTrain) is a Flutter app (`flutter_train/`) with two embedded language engines:

- **Python** — Chaquopy 17 (bundles CPython 3.13, precompiled by the Chaquopy Gradle plugin)
- **Go** — a `yaegi`-based interpreter bound to Android with `gomobile bind` (`.aar`)

Course content lives in `courseware/` and is copied into `flutter_train/assets/courseware/`
by the build script. `tools/export_content.py` then flattens the two courses into
a single `flutter_train/assets/courseware/pack.json` that the Flutter app loads (the asset
system can't enumerate directories; this also keeps precompiled content small).

## 1. Install prerequisites

| Tool | Version | Purpose |
|---|---|---|
| Flutter SDK | >= 3.22 (stable) | builds the APK |
| Android Studio / SDK | API 34-35 | compileSdk, platform tools |
| Android NDK | any recent | only needed for `gomobile bind` |
| JDK | 17 | Gradle/AGP 8.x |
| Go | >= 1.22 | builds/binds the Go engine |
| gomobile | latest | `go install golang.org/x/mobile/cmd/gomobile@latest` |
| python3 | any (3.13 preferred) | optional; Chaquopy bytecode precompile |
| rsync | any | syncs content + overlay |

Set the environment (typical):

```bash
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/<installed-version>
export PATH=$PATH:$HOME/go/bin
```

## 2. Generate the Flutter project (once)

Flutter's template provides the Gradle wrapper, platform scaffolding, and icons
that we don't check into the repo. Run:

```bash
cd /home/phil/flutterTrain
flutter create --org com.fluttertrain --project-name flutter_train --platforms android flutter_train
```

Keep the generated files; the repo's `android-overlay/` (Gradle + Chaquopy +
MainActivity + sandbox.py) is merged on top by `tools/build_apk.sh` every run,
so your edits there are the source of truth.

## 3. Build

```bash
tools/build_apk.sh
```

Checks performed before the APK is produced:

1. `courseware/` → `flutter_train/assets/courseware/` (rsync, delete-stale)
2. `tools/export_content.py` → `flutter_train/assets/courseware/pack.json`
3. `android-overlay/` → `flutter_train/android/` (rsync)
4. `gomobile bind` the Go engine (only if the `.aar` is missing, or `REBUILD_GO=1`)
5. `flutter build apk --release`

Output:

```
flutter_train/build/app/outputs/flutter-apk/app-release.apk
```

Install on a device/emulator:

```bash
adb install -r flutter_train/build/app/outputs/flutter-apk/app-release.apk
```

The release build signs with the **debug key** so you can side-load it without
configuring keystores. For Play Store publishing, add a real signing config to
`flutter_train/android-overlay/app/build.gradle`.

## 4. First-run verification (offline)

1. Turn on **Airplane mode**.
2. Open the app → the course list must load (it's bundled from `pack.json`, not fetched).
3. Open any Python lesson → tap **Run** on a code block → output appears.
4. Open any Go lesson → tap **Run** → output appears.
5. Take a quiz and the full exam simulator → both grade correctly; exam respects elapsed time.
6. Search finds lessons; bookmarks/notes persist; Settings exports progress to a JSON file.

See `docs/QA_CHECKLIST.md` for the full pass.

## 5. Troubleshooting

| Problem | Fix |
|---|---|
| `gomobile: NDK not found` | set `ANDROID_NDK_ROOT` |
| Chaquopy wants Python 3.13 on build machine | install `python3.13` or ignore (build continues with warnings) |
| Missing gradle wrapper | run `flutter create … flutter_train` again (step 2), do not delete `android/gradle/` |
| `flutter build` can't find assets | run `tools/build_apk.sh` (does the rsync + export) or `rsync -a --delete courseware/ flutter_train/assets/courseware/ && python3 tools/export_content.py` |
| Method channel `No implementation found` | the `.aar` wasn't linked — check `flutter_train/android/app/libs/goengine-release.aar` exists and `dependencies { implementation files(...) }` is present |

## 6. Development loop

- **Content only**: edit `courseware/**` → run `python3 tools/validate_content.py` (+ `verify_python_examples.py`/`verify_go_examples.sh` for runnable blocks) → rebuild.
- **Dart code**: `cd flutter_train && flutter run` (content pack export still needed first: see above).
- **Go engine**: edit `flutter_train/go/engine.go` → `REBUILD_GO=1 tools/build_apk.sh`.
- **Python sandbox**: edit `flutter_train/android-overlay/app/src/main/python/sandbox.py` → rebuild.