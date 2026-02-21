#!/usr/bin/env python3
"""Scan .claude/skills/ for SKILL.md frontmatter and update .zig-expert.json.

Preserves any existing metadata (e.g. descriptions added by the agent)
while refreshing the skill list from disk.
"""

import json
import re
import sys
from pathlib import Path


def parse_frontmatter(path: Path) -> dict | None:
    """Extract YAML frontmatter fields from a SKILL.md file."""
    text = path.read_text()
    m = re.match(r"^---\s*\n(.*?)\n---", text, re.DOTALL)
    if not m:
        return None
    fields = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            key, _, val = line.partition(":")
            fields[key.strip()] = val.strip()
    return fields


def project_root() -> Path:
    """Derive project root from script location (.claude/scripts/ -> root)."""
    return Path(__file__).resolve().parent.parent.parent


def main():
    project_dir = project_root()
    skills_dir = project_dir / ".claude" / "skills"
    output_path = project_dir / ".zig-expert.json"

    # Load existing data to preserve metadata
    existing = {}
    if output_path.exists():
        try:
            existing = json.loads(output_path.read_text())
        except json.JSONDecodeError:
            pass

    existing_skills = {s["name"]: s for s in existing.get("skills", [])}

    # Scan all skills
    skills = []
    for skill_md in sorted(skills_dir.glob("*/SKILL.md")):
        fm = parse_frontmatter(skill_md)
        if not fm or "name" not in fm:
            continue

        name = fm["name"]
        entry = existing_skills.get(name, {})
        entry["name"] = name
        entry["trigger"] = fm.get("description", "")
        # Preserve any agent-added fields (e.g. "summary", "use_in_lessons")
        skills.append(entry)

    # Detect removed skills
    current_names = {s["name"] for s in skills}
    for old_name, old_entry in existing_skills.items():
        if old_name not in current_names:
            old_entry["_removed"] = True
            skills.append(old_entry)

    output = {
        "version": 1,
        "skills": skills,
    }

    output_path.write_text(json.dumps(output, indent=2) + "\n")


if __name__ == "__main__":
    main()
