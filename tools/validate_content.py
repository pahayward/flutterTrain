#!/usr/bin/env python3
"""Validate flutterTrain courseware against COURSEWARE_FORMAT.md v1."""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
COURSEWARE = ROOT / "courseware"
KNOWN_ALERTS = {"note", "tip", "warning", "trap", "key"}
VALID_LANGUAGES = {"python", "golang", "sql", "typescript"}
FRONT_MATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.S)
FENCE_RE = re.compile(r"^```(\w*)( [^\n]*)?\n(.*?)^```", re.M | re.S)


def parse_front_matter(text: str):
    m = FRONT_MATTER_RE.match(text)
    if not m:
        return {}, text.split("---", 2)[-1] if text.startswith("---") else text
    return yaml_safe(m.group(1)), text[m.end():]


def yaml_safe(s: str):
    """Minimal YAML subset parser (no pyyaml dependency guarantees)."""
    try:
        import yaml  # type: ignore
        return yaml.safe_load(s) or {}
    except ImportError:
        data = {}
        for line in s.splitlines():
            if ":" in line and not line.startswith(" "):
                k, v = line.split(":", 1)
                v = v.strip().strip('"').strip("'")
                data[k.strip()] = v
        return data


def load_manifest(course_dir: Path):
    mf = json.loads((course_dir / "manifest.json").read_text())
    if "courseId" not in mf:
        mf["courseId"] = course_dir.name
    return mf


def validate_fences(text: str, path: Path, errors: list):
    idx = 0
    while True:
        m = FENCE_RE.search(text, idx)
        if not m:
            break
        if text.count("```", 0, m.start()) % 2 == 1:  # odd markers = unclosed fence
            errors.append(f"{path}: unbalanced fence near offset {m.start()}")
            return
        idx = m.end()


def validate_module(path: Path, errors: list, warnings: list):
    text = path.read_text()
    fm, body = parse_front_matter(text)
    for field in ("id", "title", "order", "section", "language"):
        if field not in fm:
            errors.append(f"{path}: missing front matter field {field!r}")
            return
    if fm["language"] not in ("python", "golang", "sql", "typescript"):
        errors.append(f"{path}: invalid language {fm['language']!r}")
    if fm.get("type", "lesson") not in ("lesson", "cheatsheet"):
        errors.append(f"{path}: invalid type")
    if path.stem != fm["id"]:
        errors.append(f"{path}: filename stem != id")
    if not isinstance(fm["order"], int):
        errors.append(f"{path}: order must be int")
    validate_fences(body, path, errors)

    # quiz / exam bank blocks
    for blockname in ("## Quiz", "## ExamQuestions"):
        idx = body.find(blockname)
        if idx == -1:
            continue
        rest = body[idx + len(blockname):]
        m = re.search(r"```(?:yaml)?\n(.*?)\n```", rest, re.S)
        if not m:
            errors.append(f"{path}: {blockname} without YAML code block")
            continue
        data = yaml_safe(m.group(1))
        items = data.get("questions", data.get("bank", []))
        for i, q in enumerate(items):
            # Exam banks use the documented `question` key (COURSEWARE_FORMAT.md);
            # quizzes use `prompt`. Normalise so both pass the same checks.
            if blockname == "## ExamQuestions" and "prompt" not in q and "question" in q:
                q = dict(q)
                q["prompt"] = q["question"]
            for field in ("prompt", "type", "choices", "answer", "explanation"):
                if field not in q:
                    errors.append(f"{path}: {blockname} item {i} missing {field}")
                    continue
            if q.get("type") not in ("single", "multi"):
                errors.append(f"{path}: {blockname} item {i} bad type")
            if len(q.get("choices", [])) < 2:
                errors.append(f"{path}: {blockname} item {i} < 2 choices")
            if q.get("type") == "single" and len(q.get("answer", [])) != 1:
                errors.append(f"{path}: {blockname} item {i} single answer != 1")

    for line in body.splitlines():
        if "> [!".lower() in line.lower():
            m = re.match(r"\s*>\s*\[!(note|tip|warning|trap|key)\]", line, re.I)
            if not m or m.group(1).lower() not in KNOWN_ALERTS:
                errors.append(f"{path}: unknown alert: {line.strip()[:60]}")
    return


def main():
    if not COURSEWARE.is_dir():
        print("courseware/ dir not found (run from repo root)")
        sys.exit(1)
    errors, warnings = [], []
    for course_dir in sorted(COURSEWARE.iterdir()):
        if not course_dir.is_dir():
            continue
        mf = load_manifest(course_dir)
        section_ids = {s["id"] for s in mf.get("sections", [])}
        sec_dir = course_dir / "sections"
        if not sec_dir.is_dir():
            errors.append(f"{course_dir}: missing sections/")
            continue
        known = set()
        for f in sorted(sec_dir.iterdir()):
            if not f.is_dir():
                continue
            if not f.name.split("-", 1)[0].isdigit():
                warnings.append(f"{f}: section dir not numeric-prefixed")
            for mod in sorted(f.rglob("*.md")):
                known.add(mod.stem)
                validate_module(mod, errors, warnings)
        for s in mf.get("sections", []):
            if s["id"] not in section_ids:
                continue
            for m in s.get("modules", []):
                if m["id"] not in known:
                    errors.append(f"{course_dir}: manifest module {m['id']} has no file")

    if warnings:
        print(f"{len(warnings)} warning(s)")
        for w in warnings:
            print("  W ", w)
    if errors:
        print(f"{len(errors)} error(s)")
        for e in errors:
            print("  E ", e)
        sys.exit(1)
    print("courseware OK")
    sys.exit(0)


if __name__ == "__main__":
    main()