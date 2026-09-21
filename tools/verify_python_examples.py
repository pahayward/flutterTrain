#!/usr/bin/env python3
"""Smoke-run every runnable Python block in the courseware.

Reuses the same execution model as the on-device sandbox (exec + capture) so
content verified here is highly likely to run on Android.

Usage:
    python3 tools/verify_python_examples.py [--course python-pcpp1] [--just section-id]
"""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FENCE = re.compile(r"^```(python)([^\n]*)\n(.*?)^```", re.M | re.S)

SANDBOX = """
import contextlib, io, json
out, err = io.StringIO(), io.StringIO()
try:
    with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
        exec(compile(%r, "<sandbox>", "exec"), {"__name__": "__main__"})
    ok = True; e = ""
except BaseException as exc:
    ok = False; e = "%%s: %%s" %% (type(exc).__name__, exc)
print(json.dumps({"ok": ok, "err": e, "stdout": out.getvalue(), "stderr": err.getvalue()}))
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--course", default="python-pcpp1")
    ap.add_argument("--just")
    args = ap.parse_args()

    course = ROOT / "courseware" / args.course
    files = sorted(course.rglob("*.md"))
    if args.just:
        files = [f for f in files if f.parent.name.startswith(args.just)]

    total = failed = skipped = 0
    for path in files:
        text = path.read_text()
        blocks = FENCE.findall(text)
        for fenced in blocks:
            lang, info, code = fenced
            if "eval=no" in info:
                skipped += 1
                continue
            total += 1
            verdict = run_block(code)
            if verdict["ok"]:
                out = verdict["stdout"].strip()
                kind = "ok"
                msg = out[:60].replace("\n", "\\n") if out else "(no output)"
            else:
                failed += 1
                kind = "FAIL"
                msg = verdict["err"]
            print(f"{kind:4} {path.relative_to(ROOT)}  {msg}")

    print(f"\n{len(files)} files | {total} runnable | {failed} failed | {skipped} marked eval=no")
    sys.exit(1 if failed else 0)


def run_block(code: str):
    # prefix an indent so multi-line blocks work inside the exec wrapper
    indented = code.replace("\n", "\\n").join([""])  # placeholder not used
    payload = SANDBOX % code
    r = subprocess.run(
        [sys.executable, "-c", payload],
        capture_output=True, text=True, timeout=30,
    )
    try:
        return json.loads(r.stdout.strip().splitlines()[-1])
    except Exception:
        return {"ok": False, "err": f"runner crashed: {r.stderr[:200]}"}


if __name__ == "__main__":
    main()