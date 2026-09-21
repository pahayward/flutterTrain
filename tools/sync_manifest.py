#!/usr/bin/env python3
"""Regenerate each course manifest's sections[].modules[] lists from the
actual filesystem (authoritative). Also fills module title/order from
front matter when present."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FM = re.compile(r"^---\n(.*?)\n---\n", re.S)


def parse_fm(path: Path) -> dict:
    text = path.read_text()
    m = FM.match(text)
    if not m:
        return {}
    data = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            data[k.strip()] = v.strip().strip('"').strip("'")
    return data


def sync(course_id: str):
    course = ROOT / "courseware" / course_id
    mf_path = course / "manifest.json"
    mf = json.loads(mf_path.read_text())
    sections = (course / "sections")
    for sec in mf["sections"]:
        sec_dir = sections / sec["id"]
        mods = []
        if sec_dir.is_dir():
            for f in sorted(sec_dir.glob("*.md")):
                fm = parse_fm(f)
                mods.append({
                    "id": f.stem,
                    "title": fm.get("title", f.stem.replace("-", " ").title()),
                    "order": len(mods) + 1,
                })
        sec["modules"] = mods
    mf_path.write_text(json.dumps(mf, indent=4) + "\n")
    print(f"{course_id}: {sum(len(s['modules']) for s in mf['sections'])} modules")


if __name__ == "__main__":
    import sys
    which = sys.argv[1:] or [d.name for d in (ROOT / "courseware").iterdir() if d.is_dir()]
    for c in which:
        sync(c)