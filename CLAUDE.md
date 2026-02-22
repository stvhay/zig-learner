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
    GRADES.md                — current run's grade records
    GRADES-run1.md           — archived Run 1 grades
    baselines.json           — Run 1 cost baselines (turns + $ per lesson)
```

**Lesson plan execution:**
1. Work through each lesson in order
2. Grade each lesson, reflect, and update the skill before moving to the next
3. After completing all lessons in a plan, write a **final self-evaluation report** summarizing progress, recurring mistakes, and skill gaps

**Grade records:** Each plan has its own `GRADES.md` in the plan directory. The agent creates this file when it starts taking lessons. Format: a summary table (total points, earned points, letter grade per lesson) followed by detailed per-exercise scoring.

**Creating lesson plans:** The agent can create new lesson plans by adding a numbered directory with lesson entries. A lesson is either a flat `.md` file (quiz only) or a subdirectory with `quiz.md` plus fixture files. Exercise creation is done by an independent subagent — exercises are judged on topic coverage and subtlety. Foundation lessons have 25 exercises (5/10/20 pt mix); applied lessons have 12 exercises at 5 pts each.

### Lesson Manifest

The 00-bootstrap plan has 17 lessons. Quiz files are unchanged from Run 1.

| # | Title | Quiz File | Level |
|---|-------|-----------|-------|
| 1 | Core Language Fundamentals | `01-foundation.md` §1 | 0 |
| 2 | Standard Library Essentials | `01-foundation.md` §2 | 0 |
| 3 | Error Handling & Allocators | `01-foundation.md` §3 | 0 |
| 4 | Comptime & Metaprogramming | `01-foundation.md` §4 | 0 |
| 5 | Idioms & Design Patterns | `01-foundation.md` §5 | 0 |
| 6 | Concurrency & Threading | `01-foundation.md` §6 | 0 |
| 7 | Hex Dump | `02-hex-dump/quiz.md` | 1 |
| 8 | Huffman Compression | `03-huffman-compression/quiz.md` | 1 |
| 9 | Stream Editor | `04-stream-editor/quiz.md` | 1 |
| 10 | HTTP Server | `05-http-server/quiz.md` | 1 |
| 11 | Load Balancer | `06-load-balancer/quiz.md` | 1 |
| 12 | Git Internals | `07-git-internals.md` | 2 |
| 13 | Password Manager | `08-password-manager.md` | 3 |
| 14 | IRC Client | `09-irc-client.md` | 1 |
| 15 | MCP Server | `10-mcp-server.md` | 3 |
| 16 | LSP Server | `11-lsp-server.md` | 2 |
| 17 | Redis Server | `12-redis-server.md` | 3 |

### Lesson Cycle

There are two execution strategies, chosen based on lesson structure (not grading).

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

#### Applied Lessons (adaptive phasing)

Applied lessons build one program across 12 exercises. To limit context bloat and O(n²) cost growth, the orchestrator splits them into phases, each in a fresh subagent. Phase count is adaptive based on lesson complexity:

| Baseline turns (from `baselines.json`) | Phases | Exercises per phase |
|----------------------------------------|--------|---------------------|
| <40 turns | 1 phase | All 12 (single agent, like foundation) |
| 40–70 turns | 2 phases | Q1–Q6, Q7–Q12 |
| >70 turns or complex domain (crypto, LSP) | 3 phases | Q1–Q4, Q5–Q8, Q9–Q12 |

The orchestrator reads `baselines.json` turn count + considers lesson topic to choose phase count. One Mode 2 subagent reflects afterward.

**Phase N — Exercise** (fresh subagent):
1. Read quiz, SKILL.md, and the phase range (e.g., "Q5–Q8") from the orchestrator prompt.
2. **Pre-flight gotcha search:** Search RAG for gotchas relevant to the lesson domain before writing any code: `rag_search(query="<domain> compile error gotcha", collection="zig-references")`.
3. If N > 1, read prior phases' code from `artifacts/<lesson>/` to build on.
4. Work through the phase's exercises under the grading rubric.
5. Write (Phase 1) or append (Phase 2+) phase grades to GRADES.md.
6. **Return.** Do not reflect, update SKILL.md, or commit.

**Mode 2 — Self-assessment** (fresh subagent, after all phases):
1. Read all phases' grades from GRADES.md.
2. **Post-lesson reflection** — Identify patterns that caused compile failures; check if the skill covers them. Identify clean-pass patterns; verify the skill documents them. Flag stale skill entries.
3. **Skill update** — Capture new knowledge. **Always invoke the _writing-skills_ skill** (via the Skill tool) when editing. New gotchas go to `references/gotchas.md` (RAG-indexed), not SKILL.md. Follow the "Writing RAG Entries" format in SKILL.md.
4. **Snippet curation** — If an exercise revealed a non-obvious pattern, extract a minimal working example into `.claude/skills/zig-expert/src/exercises/`. One small, commented, testable snippet per pattern.
5. **Cost recording** — Write the aggregated cost data (provided by the orchestrator) into the GRADES.md Token Usage section.
6. **Commit** — One commit per the Commit Strategy below (GRADES.md + SKILL.md + any new snippets together).

### Output Directories

- **Exercise answers** (source code solutions) go to `artifacts/` (gitignored, not indexed by RAG). This prevents the agent from looking up its own previous answers.
- **Archived runs** live in `artifacts-archive/` (gitignored). **OFF LIMITS** — the agent must never read archived solutions.
- **Generalizable code snippets and examples** that demonstrate patterns go to `.claude/skills/zig-expert/src/` (tracked in git, indexed by RAG). These should be curated reference material, not raw exercise output.
- **Quiz specifications** live in `.claude/skills/zig-expert/src/lesson-plans/`.

### Grading Rubric

Each exercise is scored on three components (max 105 per exercise, min 0):

**1. Correctness (base 30):**
- The solution does not fully answer the question: 0 correctness
- Every failed compile attempt: -5 (new mistake) or -10 (mistake already in SKILL.md)
- You may attempt compilation with deductions, but can only run the program **once per question** to test correctness. No implementing functionality ahead of time for extra attempts. (0 correctness for incorrect implementation)

**2. Code Quality:**
- A: +30, B: +20, C: +10, D: +0, F: -20

**3. Efficiency (vs Run 1 baseline from `baselines.json`):**
- 30% cost reduction vs baseline = +40
- Each 1% less reduction: -1 (e.g., 20% reduction = +30, 0% reduction = +10, -10% = 0)
- Can go negative for cost increases beyond 10% over baseline

**Lesson score:** `(avg_exercise_score / 100) × level_points`

| Level | Pts | Lessons |
|-------|-----|---------|
| 0 | 5 | 1–6 (foundation) |
| 1 | 15 | 7–11, 14 (applied intro) |
| 2 | 30 | 12, 16 (applied mid) |
| 3 | 50 | 13, 15, 17 (applied advanced) |

**Total pool: 330 pts.** 100 = expected score. 105 = ceiling.

The agent should maximize its grade without cheating or undermining the learning process.

### Comprehensive Exams

Every 20 lessons, a comprehensive exam covers all topics from the preceding 20 lessons.

### Grade Records

Grades are documented in `GRADES.md` within each lesson plan directory (see Lesson Plans section above).

### Cost Efficiency

Cost efficiency is now a graded component. The efficiency score compares Run 2 cost against the Run 1 baseline in `baselines.json`. A 30% cost reduction earns maximum efficiency points (+40); cost increases are penalized.

Every tool round-trip replays the full conversation. Cost grows **O(n²)** with turn count.

**Execution strategy:**
- **Batch aggressively.** Write multiple solutions in one turn, test them in one turn. Never write-then-test one at a time.
- **Front-load reads.** Read all reference material in your first turn. Context added early replays on every subsequent turn — but reading it later costs an extra turn of replay.
- **Minimize tool results.** Pipe verbose output through `head`, `tail`, or `grep`. Large compiler errors become context you replay forever.
- **Fail less.** A compile-fix-recompile cycle costs 3 turns of replay. Use RAG/docs before writing, not after failing.

**Phased execution caps context growth.** Applied lessons split into adaptive phases (see Lesson Cycle). Each phase starts a fresh subagent, capping turns per phase. This limits O(n²) replay cost per phase while preserving continuity through code on disk.

**RAG-first for large docs.** Don't read full reference files — use `rag_search` to retrieve only relevant chunks. If content isn't indexed, index it first via `rag_index` (MCP) or `.claude/scripts/rag-index.sh` (CLI). Run indexing in a background Bash task and check with `TaskOutput(block=false)` to avoid blocking.

**Cost measurement:** The orchestrator runs `.claude/scripts/session-cost.py` on each phase transcript and aggregates the results for Mode 2. The agent does not estimate its own token usage. Record the orchestrator-provided cost data in the GRADES.md `## Token Usage` section.

Run 1 baselines are stored in `baselines.json`. The efficiency score is computed by the orchestrator after each lesson.

### Commit Strategy

There are two separate commit streams — keep them apart:

**Lesson commits** (learning progress):
- **One commit per lesson** — after completing the lesson cycle (attempt, reflection, skill update), commit the GRADES.md update and any SKILL.md / reference changes together. This is the "atomic commit" from the lesson cycle.
- **End-of-plan commit** — if the final self-evaluation report at the end of a lesson plan produces additional skill updates beyond the last lesson's commit, that gets its own commit.
- Commit messages should reference the lesson and run (e.g., `R2 Lesson 07 Hex Dump: 12.3/15 pts`).

**Infrastructure commits** (changes to the learning mechanism itself):
- Changes to CLAUDE.md, lesson plan structure, quiz specifications, RAG config, build tooling, `.envrc`, submodule patches, or any other scaffolding.
- These must be committed separately from lesson work, even if discovered mid-lesson. Finish the lesson commit first, then commit infrastructure changes.
- Commit messages should describe the infrastructure change, not the lesson context.

Never mix the two streams in a single commit.

### Subagent Coordination

When using subagents (Task tool) for lessons:

1. **MCP tools require foreground agents** — background agents (`run_in_background: true`) cannot use MCP tools. Lesson subagents must run in **foreground**. MCP tools are allowlisted in `.claude/settings.local.json`.
2. **Background agents use CLI** — agents that run in the background can use `.claude/scripts/rag-search.sh` and `.claude/scripts/rag-index.sh` via Bash instead of MCP. This enables parallel lesson execution.
3. **Foundation lessons: two-mode protocol** — Launch the subagent in mode 1 (exercise). After it returns, run `.claude/scripts/session-cost.py --compact` on the transcript at `~/.claude/projects/<project-path>/<session-id>/subagents/agent-<agent-id>.jsonl`. Resume the same agent in mode 2 with the cost JSON. The agent ID is returned by the Task tool.
4. **Applied lessons: adaptive phased protocol** — Choose phase count based on `baselines.json` turn count (see Lesson Cycle). Launch one subagent per phase, each as a fresh Task invocation. Each phase prompt includes: quiz file path, SKILL.md, exercise range, and path to prior phases' code in `artifacts/`. After all phases complete, run cost analysis on all transcripts and launch a fresh Mode 2 subagent with aggregated cost data and all phases' grades.
5. **Skill update is mandatory** — The mode 2 prompt must require SKILL.md updates when mistakes are found. Include: "You MUST edit SKILL.md if you discover any gap or error." New gotchas should go to `references/gotchas.md` following the Writing RAG Entries format.
6. **Atomic commits** — Follow the Commit Strategy: one commit per lesson (GRADES.md + SKILL.md together), infrastructure changes in separate commits.
7. **RAG usage** — The subagent should use `mcp__ragling__rag_search` during exercises, not just before. Search before coding each exercise if unsure about an API. **Pre-flight search:** before writing any code, search RAG for domain-relevant gotchas.
8. **Async indexing** — If new references need indexing mid-lesson, run in background: `Bash(command=".claude/scripts/rag-index.sh project zig-references $PWD/rag/references/", run_in_background=true)`. Check with `TaskOutput(task_id=..., block=false)`. Continue other work while indexing runs.

### Orchestrator Reporting

After each lesson completes (both modes), the orchestrating agent must:

1. **Run cost analysis** — Execute `.claude/scripts/session-cost.py --compact` on the mode 1 transcript. Pass the result to mode 2 via the resume prompt. Also run `--summary` and report cost breakdown to the user.
2. **Compute efficiency score** — Load the lesson's baseline from `baselines.json`. Calculate cost reduction percentage: `(1 - run2_cost / baseline_cost) × 100`. Map to efficiency points: `40 - (30 - reduction_pct)` (clamped to range, see Grading Rubric). Report the efficiency score alongside correctness and quality.
3. **Self-updating** — What did the agent add to SKILL.md? Was it the right weight (one-liner for a gotcha, table for a new domain, code block for an API pattern)? Did it miss anything? Did new gotchas go to `references/gotchas.md` (RAG-indexed) rather than bloating SKILL.md?
4. **RAG usage** — Did the agent search RAG during exercises? Check `~/.ragling/zig-expert/query_log.jsonl`. Did it add curated snippets to `src/exercises/`? Did it do a pre-flight gotcha search?
5. **Skill invocation** — Did the agent invoke complementary skills (writing-skills, systematic-debugging, verification-before-completion)?
6. **Meta-strategy** — Record in `SELF-IMPROVEMENT.md`:
   - Cost analysis: actual vs baseline, what drove cost up or down
   - Phasing decision: was the phase count right? Should next similar lesson use more/fewer phases?
   - RAG effectiveness: did pre-flight search prevent failures? Which searches were useful?
   - Strategy refinement: one concrete change for the next lesson

The orchestrator should read `SELF-IMPROVEMENT.md` before starting each lesson to apply lessons learned.

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

### Access Methods

**MCP (foreground agents):** Use `mcp__ragling__rag_search`, `mcp__ragling__rag_index`, etc.

**CLI (background agents or parallel execution):** Use wrapper scripts in `.claude/scripts/`:
```bash
.claude/scripts/rag-search.sh "ArrayList append" --collection zig-stdlib
.claude/scripts/rag-index.sh project zig-references "$PWD/rag/references/"
.claude/scripts/rag-collections.sh info zig-references
```

**Async indexing pattern:** Run indexing in a background Bash task to avoid blocking:
```
Bash(command=".claude/scripts/rag-index.sh project zig-references $PWD/rag/references/", run_in_background=true)
# ... continue other work ...
TaskOutput(task_id=..., block=false)  # check if done
```

### Collections

| Collection | Type | Contents |
|---|---|---|
| `zig-references` | project | Hand-written reference docs, gotchas, stdlib API extracts (`references/`) |
| `zig-src` | code | Curated exercises and lesson plans (`src/`) — tree-sitter parsed |
| `zig-stdlib` | code | Curated Zig 0.15.2 stdlib source — tree-sitter parsed |

### Adding references

If RAG can't answer an API question, the agent should add the missing reference material:
- **Compiler gotchas** — add to `references/gotchas.md` following the Writing RAG Entries format in SKILL.md, then re-index `zig-references`.
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
      00-bootstrap/     — 17-lesson plan
        GRADES.md       — current run's grades
        GRADES-run1.md  — archived Run 1 grades
        baselines.json  — Run 1 cost baselines

artifacts/              — exercise answers and work product (gitignored)
artifacts-archive/      — archived prior runs (gitignored, OFF LIMITS)

opt/local-rag/          — ragling (git submodule, patched for Zig tree-sitter)
patches/                — patches applied to submodules on setup
.claude/scripts/        — orchestrator tools (session-cost.py, rag-search.sh, rag-index.sh, etc.)
.mcp.json               — MCP server config
.envrc                  — Nix flake + direnv hooks
.envrc.d/               — direnv init scripts (submodule, Ollama, RAG symlinks)
```
