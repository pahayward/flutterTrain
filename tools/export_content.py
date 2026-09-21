#!/usr/bin/env python3
"""Export courseware into a single pack.json for Android assets.

The assets system cannot enumerate directories, so we author in
courseware/ (source of truth) and export one JSON blob containing every
course/manifest/module (raw .md text) for the app to parse with the same
content_engine used for user-generated modules.

Usage: tools/export_content.py
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = Path.home()  # replaced below
COURSEWARE = ROOT / "courseware"
OUT = ROOT / "app" / "assets" / "courseware" / "pack.json"


def main():
    if not COURSEWARE.is_dir():
        raise SystemExit("courseware/ missing")
    courses = []
    for course_dir in sorted(COURSEWARE.iterdir()):
        if not course_dir.is_dir():
            continue
        mf_path = course_dir / "manifest.json"
        if not mf_path.exists():
            continue
        manifest = json.loads(mf_path.read_text())
        manifest.setdefault("courseId", course_dir.name)
        sections_dir = course_dir / "sections"
        for sec in manifest.get("sections", []):
            sec_dir = sections_dir / sec["id"]
            modules = []
            if sec_dir.is_dir():
                for f in sorted(sec_dir.glob("*.md")):
                    modules.append({
                        "file": f.name,
                        "markdown": f.read_text(),
                    })
            sec["modules"] = modules
        courses.append(manifest)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(courses, ensure_ascii=False, indent=1))
    total = sum(len(s.get("modules", [])) for c in courses for s in c.get("sections", []))
    print(f"exported {len(courses)} courses, {total} modules -> {OUT}")


if __name__ == "__main__":
    main()