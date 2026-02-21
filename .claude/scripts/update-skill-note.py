#!/usr/bin/env python3
"""Update a skill's agent notes in .zig-expert.json.

Usage:
    python3 .claude/scripts/update-skill-note.py <skill-name> <note>
    python3 .claude/scripts/update-skill-note.py <skill-name> --remove

Examples:
    python3 .claude/scripts/update-skill-note.py writing-skills "Required before any SKILL.md edit. Defines structure and CSO."
    python3 .claude/scripts/update-skill-note.py systematic-debugging "Invoke on compile failures — structured root cause before retry."
    python3 .claude/scripts/update-skill-note.py design-principles --remove
"""

import json
import sys
from pathlib import Path


def main():
    if len(sys.argv) < 3:
        print("Usage: update-skill-note.py <skill-name> <note | --remove>", file=sys.stderr)
        sys.exit(1)

    skill_name = sys.argv[1]
    note = sys.argv[2]
    remove = note == "--remove"

    path = Path.cwd() / ".zig-expert.json"
    if not path.exists():
        print(f"Error: {path} not found. Run scan-skills.py first.", file=sys.stderr)
        sys.exit(1)

    data = json.loads(path.read_text())

    found = False
    for entry in data.get("skills", []):
        if entry["name"] == skill_name:
            if remove:
                entry.pop("note", None)
                print(f"Removed note from {skill_name}")
            else:
                entry["note"] = note
                print(f"Updated {skill_name}: {note}")
            found = True
            break

    if not found:
        print(f"Error: skill '{skill_name}' not found in .zig-expert.json", file=sys.stderr)
        sys.exit(1)

    path.write_text(json.dumps(data, indent=2) + "\n")


if __name__ == "__main__":
    main()
