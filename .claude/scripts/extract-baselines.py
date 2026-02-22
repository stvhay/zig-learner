#!/usr/bin/env python3
"""
Extract Run 1 cost baselines for all 17 lessons.

Uses two sources:
1. Known costs from GRADES.md (session-cost.py data recorded during Run 1).
2. Verified transcript paths for lessons without recorded costs — runs
   session-cost.py on them to compute exact costs.

Output: baselines.json with turns and cost for each lesson.
"""

import json
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent
SESSION_COST = PROJECT_ROOT / ".claude/scripts/session-cost.py"

# Session that contained L1-L10 transcripts
SESSION_4E = Path.home() / (
    ".claude/projects/-Users-hays-Projects-zighelloworld/"
    "4e585b88-b605-4991-8783-b2a485ce2fce/subagents"
)

# Lesson manifest and cost sources.
# For "transcript" source: path is relative to SESSION_4E.
# For "grades" source: cost was recorded in GRADES.md via session-cost.py.
LESSONS = {
    1:  {"title": "Core Language Fundamentals",
         "quiz": "01-foundation.md §1", "level": 0,
         "source": "transcript", "agent": "agent-af1c774.jsonl"},
    2:  {"title": "Standard Library Essentials",
         "quiz": "01-foundation.md §2", "level": 0,
         "source": "transcript", "agent": "agent-a9262f9.jsonl"},
    3:  {"title": "Error Handling & Allocators",
         "quiz": "01-foundation.md §3", "level": 0,
         "source": "transcript", "agent": "agent-a95f85b.jsonl"},
    4:  {"title": "Comptime & Metaprogramming",
         "quiz": "01-foundation.md §4", "level": 0,
         "source": "transcript", "agent": "agent-ae05520.jsonl"},
    5:  {"title": "Idioms & Design Patterns",
         "quiz": "01-foundation.md §5", "level": 0,
         "source": "transcript", "agent": "agent-acaab30.jsonl"},
    6:  {"title": "Concurrency & Threading",
         "quiz": "01-foundation.md §6", "level": 0,
         "source": "transcript", "agent": "agent-a20af87.jsonl"},
    7:  {"title": "Hex Dump",
         "quiz": "02-hex-dump/quiz.md", "level": 1,
         "source": "transcript", "agent": "agent-a733571.jsonl"},
    8:  {"title": "Huffman Compression",
         "quiz": "03-huffman-compression/quiz.md", "level": 1,
         "source": "transcript", "agent": "agent-a7cc638.jsonl"},
    9:  {"title": "Stream Editor",
         "quiz": "04-stream-editor/quiz.md", "level": 1,
         "source": "transcript", "agent": "agent-a0f2052.jsonl"},
    10: {"title": "HTTP Server",
         "quiz": "05-http-server/quiz.md", "level": 1,
         "source": "transcript", "agent": "agent-a957735.jsonl"},
    11: {"title": "Load Balancer",
         "quiz": "06-load-balancer/quiz.md", "level": 1,
         "source": "grades", "turns": 37, "cost": 3.67},
    12: {"title": "Git Internals",
         "quiz": "07-git-internals.md", "level": 2,
         "source": "grades", "turns": 61, "cost": 6.79},
    13: {"title": "Password Manager",
         "quiz": "08-password-manager.md", "level": 3,
         "source": "grades", "turns": 99, "cost": 11.55},
    14: {"title": "IRC Client",
         "quiz": "09-irc-client.md", "level": 1,
         "source": "grades", "turns": 47, "cost": 4.51},
    15: {"title": "MCP Server",
         "quiz": "10-mcp-server.md", "level": 3,
         "source": "grades", "turns": 81, "cost": 9.26},
    16: {"title": "LSP Server",
         "quiz": "11-lsp-server.md", "level": 2,
         "source": "grades", "turns": 61, "cost": 7.49},
    17: {"title": "Redis Server",
         "quiz": "12-redis-server.md", "level": 3,
         "source": "grades", "turns": 67, "cost": 8.50},
}


def run_session_cost(transcript_path: Path) -> dict | None:
    """Run session-cost.py --compact on a transcript."""
    try:
        result = subprocess.run(
            [sys.executable, str(SESSION_COST), "--compact", str(transcript_path)],
            capture_output=True, text=True, timeout=30,
        )
        if result.returncode == 0 and result.stdout.strip():
            return json.loads(result.stdout.strip())
    except (subprocess.TimeoutExpired, json.JSONDecodeError, OSError):
        pass
    return None


def build_baselines() -> dict:
    """Build the complete baselines.json."""
    lessons = {}

    for num, info in LESSONS.items():
        entry = {
            "title": info["title"],
            "quiz": info["quiz"],
            "level": info["level"],
        }

        if info["source"] == "grades":
            entry["turns"] = info["turns"]
            entry["cost"] = info["cost"]
            entry["source"] = "session-cost.py"
        elif info["source"] == "transcript":
            transcript_path = SESSION_4E / info["agent"]
            if transcript_path.exists():
                cost_data = run_session_cost(transcript_path)
                if cost_data and cost_data.get("total"):
                    entry["turns"] = cost_data["n"]
                    entry["cost"] = round(cost_data["total"], 2)
                    entry["source"] = "transcript"
                else:
                    print(f"WARNING: session-cost.py failed for L{num}, using estimate",
                          file=sys.stderr)
                    entry["turns"] = 40
                    entry["cost"] = 3.00
                    entry["source"] = "estimated"
            else:
                print(f"WARNING: transcript not found for L{num}: {transcript_path}",
                      file=sys.stderr)
                entry["turns"] = 40
                entry["cost"] = 3.00
                entry["source"] = "estimated"

        lessons[str(num)] = entry

    return {
        "run": 1,
        "model": "claude-opus-4-6",
        "generated_by": "extract-baselines.py",
        "lessons": lessons,
    }


def main():
    baselines = build_baselines()

    output_path = (PROJECT_ROOT /
                   ".claude/skills/zig-expert/src/lesson-plans/00-bootstrap/baselines.json")

    # Print summary
    total_cost = sum(l["cost"] for l in baselines["lessons"].values())
    print(f"Baselines for {len(baselines['lessons'])} lessons:")
    print(f"{'#':>3}  {'Title':<35} {'Turns':>5} {'Cost':>7} {'Source'}")
    print("-" * 75)
    for num in sorted(baselines["lessons"], key=int):
        l = baselines["lessons"][num]
        print(f"{num:>3}  {l['title']:<35} {l['turns']:>5} ${l['cost']:>6.2f} {l['source']}")
    print("-" * 75)
    print(f"{'Total':>41} ${total_cost:>6.2f}")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(baselines, f, indent=2)
        f.write("\n")

    print(f"\nWritten to {output_path}")


if __name__ == "__main__":
    main()
