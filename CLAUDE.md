# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Build a Claude skill that masters Zig 0.15.2 through structured, graded lessons with self-evaluation. The deliverable is accumulated Zig expertise encoded as a reusable skill at `.claude/skills/zig-expert/`.

## Training Protocol

When invoked, the agent should:

1. Evaluate its current state of learning (as represented in the skill)
2. Estimate what learning can be added using ~500k tokens
3. Execute the next lesson plan (or create one), and update the skill
4. Use subagents when appropriate to manage context

### Lesson Plans

Training is organized into **lesson plans** — numbered directories containing ordered lessons. Each plan focuses on a theme (e.g., language fundamentals, applied projects). The agent works through lessons sequentially, with grading and self-improvement between each.

```
.claude/skills/zig-expert/src/lesson-plans/
  00-bootstrap/              — plan directory
    01-foundation.md         — lesson (quiz-only → flat .md file)
    02-hex-dump/             — lesson (quiz.md + fixture files → directory)
      quiz.md
      test1.txt, ...
    07-git-internals.md      — lesson (quiz-only → flat .md file)
    ...
    GRADES.md                — per-plan grade records (created by agent)
```

**Lesson plan execution:**
1. Work through each lesson in order
2. Grade each lesson, reflect, and update the skill before moving to the next
3. After completing all lessons in a plan, write a **final self-evaluation report** summarizing progress, recurring mistakes, and skill gaps

**Grade records:** Each plan has its own `GRADES.md` in the plan directory. The agent creates this file when it starts taking lessons. Format: a summary table (total points, earned points, letter grade per lesson) followed by detailed per-exercise scoring.

**Creating lesson plans:** The agent can create new lesson plans by adding a numbered directory with lesson entries. A lesson is either a flat `.md` file (quiz only) or a subdirectory with `quiz.md` plus fixture files. Exercise creation is done by an independent subagent — exercises are judged on topic coverage and subtlety. Each exercise is difficulty 1 (5 pts), 2 (10 pts), or 3 (20 pts), totaling 200 +/- 20 points for foundation lessons or 60 +/- 10 points for applied lessons.

### Lesson Cycle

Each lesson follows this cycle:

1. **Graded attempt** — The agent takes the exercises under the grading rubric (see below).
2. **Post-lesson reflection** — After grading, the agent must:
   - Identify patterns that caused compile failures; check if the skill covers them; update if not
   - Identify patterns that led to clean passes; verify the skill documents them
   - Flag skill entries that seem wrong or stale
3. **Skill update** — Capture new knowledge into the skill. **Always invoke the _writing-skills_ skill** (via the Skill tool) when editing — it defines structure, CSO, and quality standards.
4. **Snippet curation** — If any exercise revealed a non-obvious pattern, extract a minimal working example into `.claude/skills/zig-expert/src/exercises/` (or a new file there). These are indexed by RAG and help future sessions find working code. Don't dump raw solutions — curate: one small, commented, testable snippet per pattern.
5. **Commit** — Commit per the Commit Strategy below (one lesson commit with GRADES.md + SKILL.md + any new snippets together).

### Output Directories

- **Exercise answers** (source code solutions) go to `artifacts/` (gitignored, not indexed by RAG). This prevents the agent from looking up its own previous answers.
- **Generalizable code snippets and examples** that demonstrate patterns go to `.claude/skills/zig-expert/src/` (tracked in git, indexed by RAG). These should be curated reference material, not raw exercise output.
- **Quiz specifications** live in `.claude/skills/zig-expert/src/lesson-plans/`.

### Grading Rubric

For each exercise:
- The solution does not fully answer the question: -100%
- Every failed compile attempt deducts 1 point (new mistake) or 2 points (mistake already in the skill knowledge base)
- You may attempt compilation with deductions, but can only run the program **once per question** to test correctness. No implementing functionality ahead of time for extra attempts. (-100% for incorrect implementation)
- A: >=90%, B: >=80%, C: >=70%, D: >=60%, otherwise F

After the test, code quality is graded separately. Quality penalties: B: -10%, C: -20%, D: -30%, F: -50%.

The agent should maximize its grade without cheating or undermining the learning process.

### Comprehensive Exams

Every 20 lessons, a comprehensive exam covers all topics from the preceding 20 lessons.

### Grade Records

Grades are documented in `GRADES.md` within each lesson plan directory (see Lesson Plans section above).

### Token Efficiency

The first time a lesson or lesson plan is executed, token usage is recorded to establish a baseline. After that, it becomes a performance metric.

**Good habits** (practice now):
- Read the quiz section once, not per-exercise. Read SKILL.md once at the start.
- Use RAG over full file reads — targeted `rag_search` vs. 500k+ tokens of reference files.
- Batch difficulty-1 exercises with similar patterns without re-reading the spec for each.

**Record in GRADES.md** — every lesson's grade record must include a "## Token Usage" section with:
- Estimated total tokens consumed (input + output)
- Number of tool calls
- Tokens per exercise (total / exercise count)

The orchestrating agent will append `Actual (Task tool)` to each Token Usage section after the lesson completes, using the `total_tokens` and `tool_uses` reported by the Task tool. The agent's self-estimates serve as a point of comparison but are not ground truth.

On subsequent runs, compare against the baseline.

### Commit Strategy

There are two separate commit streams — keep them apart:

**Lesson commits** (learning progress):
- **One commit per lesson** — after completing the lesson cycle (attempt, reflection, skill update), commit the GRADES.md update and any SKILL.md / reference changes together. This is the "atomic commit" from the lesson cycle.
- **End-of-plan commit** — if the final self-evaluation report at the end of a lesson plan produces additional skill updates beyond the last lesson's commit, that gets its own commit.
- Commit messages should reference the lesson (e.g., `Lesson 02 Hex Dump: 55/60 (A)`).

**Infrastructure commits** (changes to the learning mechanism itself):
- Changes to CLAUDE.md, lesson plan structure, quiz specifications, RAG config, build tooling, `.envrc`, submodule patches, or any other scaffolding.
- These must be committed separately from lesson work, even if discovered mid-lesson. Finish the lesson commit first, then commit infrastructure changes.
- Commit messages should describe the infrastructure change, not the lesson context.

Never mix the two streams in a single commit.

### Subagent Coordination

When using subagents (Task tool) for lessons:

1. **MCP tools require foreground agents** — background agents (`run_in_background: true`) architecturally cannot use MCP tools. Lesson subagents must run in **foreground** to access RAG. MCP tools are allowlisted in `.claude/settings.local.json` so they don't require per-call prompting.
2. **Skill update is mandatory** — The subagent prompt must explicitly require SKILL.md updates when mistakes are found. The agent must not just *recommend* updates in GRADES.md — it must *make* them. Include: "You MUST edit SKILL.md if you discover any gap or error."
3. **Atomic commits** — Follow the Commit Strategy: one commit per lesson (GRADES.md + SKILL.md together), infrastructure changes in separate commits.
4. **RAG usage** — The subagent should use `mcp__ragling__rag_search` to look up API details, pitfalls, and patterns *during* exercises, not just before. Search before coding each exercise if unsure about an API.

## Skill Discovery

On session start, a hook runs `.claude/scripts/scan-skills.py` to populate `.zig-expert.json`. Use `.claude/scripts/skill.py` to list, view, and annotate skills. Notes persist across sessions. When launching lesson subagents, include annotated skills in the prompt so the subagent knows what to invoke (it has the Skill tool but can't see the skill list).

## Self-Update Protocol

This file, the skill at `.claude/skills/zig-expert/SKILL.md`, and the skill references should all be kept in sync as the project evolves:

- **Discover new Zig patterns or breaking changes** — update the skill
- **Find the skill has gaps or errors** — fix immediately, don't defer
- **Any skill edit** — invoke the _writing-skills_ skill first

## Environment

- **Zig version**: 0.15.2 (installed via Nix)
- APIs changed significantly from 0.14 — see the skill's "0.15.2 API Corrections" section

### Building and Testing

There is no project-level `build.zig`. Agents compile individual `.zig` files directly:

```bash
zig test path/to/exercise.zig          # run tests in a file
zig build-exe path/to/program.zig      # compile a standalone program
```

## RAG

A local RAG ([ragling](https://github.com/aihaysteve/local-rag)) indexes skill references and code for semantic search. The MCP server starts automatically (configured in `.mcp.json`). Use `rag_search` to query; use `rag_index` to re-index after changes. The `rag/` symlinks (created by `.envrc.d/ragling.sh`) give ragling clean paths into `.claude/skills/zig-expert/`.

## Architecture

```
.claude/skills/zig-expert/
  SKILL.md              — skill definition (loaded into agent context)
  ragling.json          — RAG config (db stored in ~/.ragling/zig-expert/)
  references/           — Zig reference docs (indexed by RAG as markdown)
  src/                  — curated code examples and lesson plans (indexed by RAG)
    exercises/          — generalizable Zig code examples with tests
    lesson-plans/       — numbered plan directories
      00-bootstrap/     — first plan (12 lessons, GRADES.md created on use)

artifacts/              — exercise answers and work product (gitignored)

opt/local-rag/          — ragling (git submodule, patched for Zig tree-sitter)
patches/                — patches applied to submodules on setup
.mcp.json               — MCP server config
.envrc                  — Nix flake + direnv hooks
.envrc.d/               — direnv init scripts (submodule, Ollama, RAG symlinks)
```
