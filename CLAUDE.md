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

There are two lesson formats with different execution protocols.

#### Foundation Lessons (single-agent)

Foundation lessons have many independent exercises (typically 25). They run in a single subagent with two modes:

**Mode 1 — Exercise:**
1. Read quiz and SKILL.md (once each).
2. Work through exercises under the grading rubric (see below).
3. Write grade table and per-exercise scoring to GRADES.md.
4. **Return.** Do not reflect, update SKILL.md, or commit.

**Mode 2 — Self-assessment** (orchestrator resumes agent with cost data):
1. **Post-lesson reflection** — Identify patterns that caused compile failures; check if the skill covers them. Identify clean-pass patterns; verify the skill documents them. Flag stale skill entries.
2. **Skill update** — Capture new knowledge. **Always invoke the _writing-skills_ skill** (via the Skill tool) when editing.
3. **Snippet curation** — If an exercise revealed a non-obvious pattern, extract a minimal working example into `.claude/skills/zig-expert/src/exercises/`. One small, commented, testable snippet per pattern.
4. **Cost recording** — Write the cost data (provided by the orchestrator) into the GRADES.md Token Usage section.
5. **Commit** — One commit per the Commit Strategy below (GRADES.md + SKILL.md + any new snippets together).

#### Applied Lessons (phased execution)

Applied lessons build one program across 12 exercises. To limit context bloat and O(n²) cost growth, they split into **3 phases of 4 exercises**, each in a fresh subagent. One Mode 2 subagent reflects afterward.

**Phase structure:**

| Phase | Exercises | Purpose |
|-------|-----------|---------|
| 1 | Q1–Q4 | Foundation — core data structures, protocol, basic I/O |
| 2 | Q5–Q8 | Features — user interaction, concurrency, extended commands |
| 3 | Q9–Q12 | Polish — advanced features, validation, end-to-end testing |

**Phase N — Exercise** (fresh subagent, N = 1, 2, 3):
1. Read quiz, SKILL.md, and the phase range (e.g., "Q5–Q8") from the orchestrator prompt.
2. If N > 1, read prior phases' code from `artifacts/<lesson>/` to build on.
3. Work through the phase's 4 exercises under the grading rubric.
4. Write (Phase 1) or append (Phase 2–3) phase grades to GRADES.md.
5. **Return.** Do not reflect, update SKILL.md, or commit.

**Mode 2 — Self-assessment** (fresh subagent, after all 3 phases):
1. Read all 3 phases' grades from GRADES.md.
2. **Post-lesson reflection** — Identify patterns that caused compile failures; check if the skill covers them. Identify clean-pass patterns; verify the skill documents them. Flag stale skill entries.
3. **Skill update** — Capture new knowledge. **Always invoke the _writing-skills_ skill** (via the Skill tool) when editing.
4. **Snippet curation** — If an exercise revealed a non-obvious pattern, extract a minimal working example into `.claude/skills/zig-expert/src/exercises/`. One small, commented, testable snippet per pattern.
5. **Cost recording** — Write the aggregated cost data (provided by the orchestrator) into the GRADES.md Token Usage section.
6. **Commit** — One commit per the Commit Strategy below (GRADES.md + SKILL.md + any new snippets together).

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

### Cost Efficiency

Every tool round-trip replays the full conversation. Cost grows **O(n²)** with turn count.

**Execution strategy:**
- **Batch aggressively.** Write multiple solutions in one turn, test them in one turn. Never write-then-test one at a time.
- **Front-load reads.** Read all reference material in your first turn. Context added early replays on every subsequent turn — but reading it later costs an extra turn of replay.
- **Minimize tool results.** Pipe verbose output through `head`, `tail`, or `grep`. Large compiler errors become context you replay forever.
- **Fail less.** A compile-fix-recompile cycle costs 3 turns of replay. Use RAG/docs before writing, not after failing.

**Phased execution caps context growth.** Applied lessons split into 3 phases of 4 exercises (see Lesson Cycle). Each phase starts a fresh subagent, capping turns at ~15 instead of 40+. This limits O(n²) replay cost per phase while preserving continuity through code on disk.

**Cost measurement:** The orchestrator runs `.claude/scripts/session-cost.py` on each phase transcript and aggregates the results for Mode 2. The agent does not estimate its own token usage. Record the orchestrator-provided cost data in the GRADES.md `## Token Usage` section.

The first run of each lesson establishes a cost baseline. Subsequent runs compare against it.

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

1. **MCP tools require foreground agents** — background agents (`run_in_background: true`) cannot use MCP tools. Lesson subagents must run in **foreground**. MCP tools are allowlisted in `.claude/settings.local.json`.
2. **Foundation lessons: two-mode protocol** — Launch the subagent in mode 1 (exercise). After it returns, run `.claude/scripts/session-cost.py --compact` on the transcript at `~/.claude/projects/<project-path>/<session-id>/subagents/agent-<agent-id>.jsonl`. Resume the same agent in mode 2 with the cost JSON. The agent ID is returned by the Task tool.
3. **Applied lessons: phased protocol** — Launch 3 separate subagents (one per phase), each as a fresh Task invocation (not a resume). Each phase prompt includes: quiz file path, SKILL.md, exercise range (e.g., "Q5–Q8"), and path to prior phases' code in `artifacts/`. After all 3 phases complete, run cost analysis on all 3 transcripts and launch a fresh Mode 2 subagent with the aggregated cost data and all phases' grades.
4. **Skill update is mandatory** — The mode 2 prompt must require SKILL.md updates when mistakes are found. Include: "You MUST edit SKILL.md if you discover any gap or error."
5. **Atomic commits** — Follow the Commit Strategy: one commit per lesson (GRADES.md + SKILL.md together), infrastructure changes in separate commits.
6. **RAG usage** — The subagent should use `mcp__ragling__rag_search` during exercises, not just before. Search before coding each exercise if unsure about an API.

### Orchestrator Reporting

After each lesson completes (both modes), the orchestrating agent must:

1. **Run cost analysis** — Execute `.claude/scripts/session-cost.py --compact` on the mode 1 transcript. Pass the result to mode 2 via the resume prompt. Also run `--summary` and report cost breakdown to the user.
2. **Self-updating** — What did the agent add to SKILL.md? Was it the right weight (one-liner for a gotcha, table for a new domain, code block for an API pattern)? Did it miss anything?
3. **RAG usage** — Did the agent search RAG during exercises? Check `~/.ragling/zig-expert/query_log.jsonl`. Did it add curated snippets to `src/exercises/`?
4. **Skill invocation** — Did the agent invoke complementary skills (writing-skills, systematic-debugging, verification-before-completion)?

Update `SELF-IMPROVEMENT.md` in the plan directory with findings.

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

### Collections

| Collection | Type | Contents |
|---|---|---|
| `zig-references` | project | Hand-written reference docs + stdlib API extracts (`references/`) |
| `zig-src` | code | Curated exercises and lesson plans (`src/`) — tree-sitter parsed |
| `zig-stdlib` | code | Curated Zig 0.15.2 stdlib source — tree-sitter parsed |

### Adding references

If RAG can't answer an API question, the agent should add the missing reference material:
- **Stdlib API gaps** — run `.claude/scripts/extract-stdlib-api.py` to regenerate `references/stdlib/` from the Nix store, then re-index `zig-references`.
- **External docs** — fetch with `WebFetch`, save to `references/`, re-index.
- **Code patterns** — curate into `src/exercises/`, re-index `zig-src`.

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
.claude/scripts/          — orchestrator tools (session-cost.py, scan-skills.py)
.mcp.json               — MCP server config
.envrc                  — Nix flake + direnv hooks
.envrc.d/               — direnv init scripts (submodule, Ollama, RAG symlinks)
```
