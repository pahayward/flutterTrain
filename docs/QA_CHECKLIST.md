# QA Checklist

Smoke-test every release APK against this list. Expected result for every item:
**PASS** (or a filed bug).

## Content & loading (offline)
- [ ] Fresh install with Airplane mode on → course list shows **PCPP1** and **Go: Zero to Hero**.
- [ ] Course cards show live progress bars (0% on first launch).
- [ ] Manually add a module to a section → long-press/hard refresh → it appears; remove → gone (user-content overlay is `Documents/courseware/`).
- [ ] Search finds a lesson by title and by a body keyword; snippet highlights term.

## Python engine (Chaquopy)
- [ ] Lesson in section `01-object-oriented` → tap **Run** → prints expected output.
- [ ] Lesson with `eval=no` code (GUI/network-to-internet) shows either no Run button, or a disabled button with a note.
- [ ] Python timeout: looped `while True: pass` returns a timeout error (≤ ~8s), app stays responsive.
- [ ] Python error: a `name_error_here` example shows exception text (traceback) in red.
- [ ] Running two blocks back-to-back quickly doesn't interleave output.

## Go engine (yaegi via gomobile)
- [ ] Lesson in `00-foundations` → tap **Run** → prints output.
- [ ] Goroutine/channel example runs and prints (part `04-methods-interfaces`, `07-concurrency`).
- [ ] Go generics example (tagged `eval=no`) shows a disabled Run + rationale note.
- [ ] Go timeout: infinite `select{}` errors out, app stays responsive.

## Lessons & reader
- [ ] Chapter scroll position restored after leaving and re-entering.
- [ ] **Mark complete** toggles and updates course/section progress.
- [ ] Bookmark icon persists across restarts; shows in Settings → Bookmarks.
- [ ] Personal notes dialog saves; entry survives restart.
- [ ] Prev/Next walks the section; at the final lesson **Done** pops back to course screen.

## Quizzes & exam simulator
- [ ] Lesson quiz: single-select and multi-select both check correctly; explanation shown.
- [ ] Wrong answer → score stays; correct → increments. Re-answer after **Previous** works.
- [ ] Exam simulator: question count = examMode.questionCount (45/40), timer ticks and hard-stops at 0:00.
- [ ] Exam result shows score/total/percentage and pass threshold; a **Retry** option appears on failure.
- [ ] Result is recorded in Overview → Recent exams.

## Sharing
- [ ] Lesson share button opens the share sheet with a `.md` file holding the title, course/section metadata, and full lesson body.
- [ ] Quiz share sends the question and choices; answer + explanation included only once answered correctly.
- [ ] Share button is hidden during the timed exam simulator.

## Settings & data
- [ ] Export progress → JSON file appears under app documents; readable.
- [ ] Reset all progress wipes module state; restarts clean.
- [ ] Rapid practice (from course screen) mixes questions from all sections.

## Build pipeline
- [ ] `python3 tools/validate_content.py` → `courseware OK`.
- [ ] `python3 tools/export_content.py` → `exported 2 courses, 96 modules`.
- [ ] `tools/verify_go_examples.sh` → `runnable=213 failed=0`.
- [ ] `tools/build_apk.sh` produces `app-release.apk`, arm64, installable via `adb install -r`.
- [ ] APK size is sane (< ~140MB) given embedded CPython 3.13 + Go engine.