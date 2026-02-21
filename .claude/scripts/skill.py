#!/usr/bin/env python3
"""Manage skill discovery and agent notes.

Usage:
    skill.py                      List all skills
    skill.py <name>               Show one skill
    skill.py <name> <note>        Add agent note
    skill.py <name> --delete      Remove agent note
"""

import json
import sys
from pathlib import Path

DB = Path(__file__).resolve().parent.parent.parent / ".zig-expert.json"


def load():
    if not DB.exists():
        return []
    return json.loads(DB.read_text()).get("skills", [])


def save(skills):
    DB.write_text(json.dumps({"version": 1, "skills": skills}, indent=2) + "\n")


def fmt(s):
    parts = [s["name"], "-", s.get("trigger", "")]
    note = s.get("note")
    if note:
        parts += [":", note]
    return " ".join(parts)


def main():
    skills = load()
    if not skills:
        print("No skills found. Run scan-skills.py first.", file=sys.stderr)
        sys.exit(1)

    args = sys.argv[1:]

    # List all
    if not args:
        for s in skills:
            print(fmt(s))
        return

    name = args[0]
    entry = next((s for s in skills if s["name"] == name), None)
    if not entry:
        print(f"Unknown skill: {name}", file=sys.stderr)
        sys.exit(1)

    # Show one
    if len(args) == 1:
        print(fmt(entry))
        return

    # Delete note
    if args[1] == "--delete":
        entry.pop("note", None)
        save(skills)
        return

    # Set note
    entry["note"] = " ".join(args[1:])
    save(skills)


if __name__ == "__main__":
    main()
