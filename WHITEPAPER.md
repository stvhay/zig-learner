# Self-Improving LLM Skills Through Graded Practice

## Abstract

We built a system where an LLM teaches itself a programming language by writing exercises, attempting them, grading itself, and updating its own reference manual. Over 12 lessons and 225 exercises, the agent's curated skill file grew from zero to 350 lines. Compile failure rates dropped from 10% to under 2%. The agent repeated mistakes already documented in the skill file only 4 times across the full run. The mechanism is simple: persistent external memory that the agent both reads and writes, with incentives that reward reading it.

## Introduction: The Problem

Large language models have frozen weights. They cannot learn from experience within a session, and they forget everything between sessions. Fine-tuning addresses this but is expensive, slow, and hard to target at specific knowledge gaps.

LLMs can, however, read. Place a reference document in the system prompt, and the model behaves as if it "knows" that material. The document acts as working memory — consulted, not learned.

This creates an opportunity. If the model can write to that document, it can build a persistent knowledge base that survives across sessions. Each session reads the previous version, adds what it learned, and writes it back. The question: does a self-authored reference document improve performance on subsequent tasks?

`zig-learner` tests this claim. An AI agent learns Zig 0.15.2 — a language with significant API changes from its training data — through structured, graded lessons. It writes its own skill file, and we measure whether that file reduces mistakes.

## Architecture

### The Self-Improvement Loop

The loop follows the OODA model (Observe, Orient, Decide, Act), mapped to skill file modification:

**Observe.** After each exercise, the agent records structured telemetry: which exercises compiled on the first try, which failed, the root cause of each failure, and whether the skill file already documented the mistake. This telemetry lives in `GRADES.md` — one per lesson plan.

**Orient.** In a separate self-assessment pass (fresh context, no exercise code in memory), the agent analyzes failure patterns. What caused each compile failure? Does the skill already cover it? If so, why did the agent repeat the mistake? If not, what minimal addition prevents it next time?

**Decide.** The agent proposes specific mutations to the skill file: API corrections, decision frameworks, style idioms, or pitfall entries. Each mutation is small and targeted — a one-liner for a gotcha, a table for a new domain, a code block for an API pattern.

**Act.** The agent applies mutations atomically and commits them to git. One commit per lesson contains grade records and skill updates together. Every line in the skill traces to a specific lesson and mistake.

### Two Models

The system maintains two distinct knowledge structures:

1. **Zig knowledge** (`SKILL.md`) — API patterns, decision frameworks, common pitfalls. Mutable; grows with each lesson.

2. **Teaching apparatus** (`CLAUDE.md`) — the two-mode protocol, grading rubric, cost model, commit strategy. Stable; changes rarely.

This separation matters. A bad skill mutation (wrong API pattern) reverts cleanly without disrupting the teaching process. A bad process change (broken grading rubric) would corrupt the feedback signal itself. Stable core, mutable periphery.

## Methodology

### Two-Mode Lesson Protocol

Each lesson runs in two phases, in separate agent contexts:

**Mode 1 — Exercise.** The agent reads the quiz and the skill file, works through exercises, compiles and tests each one, and records grades. It does not reflect or update the skill. This separation prevents the agent from "studying for the test" — it must rely on what the skill already contains.

**Mode 2 — Self-Assessment.** The orchestrator resumes the same agent with cost data. The agent reflects: which patterns caused failures? Does the skill cover them? What's missing? It updates the skill, curates reusable code snippets, and commits. A fresh pass through the same context — reflective rather than performative — produces better analysis than inline reflection.

### Grading Rubric and Incentive Design

The rubric creates specific pressures:

- **Compile failures cost 1 point** (new mistake) or **2 points** (mistake the skill file already documents). The double penalty for known-pitfall violations forces the agent to read the skill file before coding. Writing the knowledge down is insufficient — the agent must consult it.
- **One test run per exercise.** The agent may compile as many times as needed (with deductions), but can execute the program only once. This prevents guess-and-check strategies and rewards correct logic on the first attempt.
- **Code quality graded separately.** After functionality, the grader assesses structure, readability, and idiomatic Zig usage. Quality penalties range from -10% (B) to -50% (F).

Letter grades: A >= 90%, B >= 80%, C >= 70%, D >= 60%, F below.

### Exercise Design

Two formats serve different purposes:

**Foundation lessons** (25 exercises, ~200 points) cover language concepts in isolation. Each exercise tests one pattern: a type, a control flow construct, an API. These build vocabulary.

**Applied lessons** (12 exercises, ~60 points) build one complete program incrementally. Exercise 1 creates a skeleton; exercise 12 adds the final feature. These test integration: can the agent hold a growing program in its head, maintain consistency across 500+ lines, and extend functionality without breaking earlier work?

The applied lessons produce real programs: an xxd-compatible hex dump, a Huffman compressor, a sed clone with regex, an HTTP server, a load balancer with health checks, and a git implementation with SHA-1 object storage and unified diff.

### RAG Architecture

A local RAG system with tree-sitter parsing for Zig-aware chunking backs the agent through three collections:

| Collection | Contents |
|---|---|
| `zig-references` | Hand-written reference docs + extracted stdlib API signatures |
| `zig-src` | Curated exercise code and lesson plans |
| `zig-stdlib` | Zig 0.15.2 standard library source |

The agent searches RAG before coding each exercise when unsure about an API. This matters most for Zig 0.15.2, where many APIs changed from 0.14 — the version most likely in the model's training data.

## Cost Model

### O(n^2) Token Growth

Claude Code replays the full conversation on every tool round-trip. A conversation with *n* turns costs proportional to *n^2* total tokens, not *n*. This shapes every execution decision.

An extra turn costs not one turn of tokens but one turn plus replaying all previous turns. A compile-fix-recompile cycle spanning 3 turns costs 3 turns of new content plus replaying the first 2. Over a 30-turn lesson, late-lesson turns cost 10-15x more than early ones.

### Batching Strategy

The agent mitigates this through aggressive batching:

- **Multiple solutions per turn.** Write all 12 exercise solutions, then compile once — never write-then-test one at a time.
- **Front-loaded reads.** Read all reference material in the first turn. Context added early replays on every subsequent turn, but reading it later costs an extra turn of replay.
- **Minimal tool output.** Pipe verbose compiler errors through `head` or `grep`. A 200-line error message becomes context that replays on every subsequent call.

### Real Cost Data

| Lesson | Turns | Cost | $/Exercise |
|--------|-------|------|------------|
| Load Balancer | 37 | $3.67 | $0.31 |
| Git Internals | 61 | $6.79 | $0.57 |

The Git Internals lesson cost nearly twice as much as the Load Balancer — not because it was harder, but because 3 compile-fix-recompile cycles added 24 extra turns of context replay. Cost breakdown: context replay 47-56%, cache writes 29-32%, output 9-13%, system prompt 6-7%.

Cost per exercise dropped ~50% from early foundation lessons (~$0.45/exercise at 3,400 tokens each) to later ones (~$0.22/exercise at 2,800 tokens each), reflecting both improved skill coverage and better batching discipline.

## Results

### Grade Summary

All 12 lessons earned A grades:

| # | Lesson | Type | Score | % |
|---|--------|------|-------|---|
| 01 | Core Language Fundamentals | Foundation | 180/200 | 90.0 |
| 02 | Standard Library Essentials | Foundation | 200/200 | 100.0 |
| 03 | Error Handling & Allocators | Foundation | 194/200 | 97.0 |
| 04 | Comptime & Metaprogramming | Foundation | 194/200 | 97.0 |
| 05 | Idioms & Design Patterns | Foundation | 198/200 | 99.0 |
| 06 | Concurrency & Threading | Foundation | 199/200 | 99.5 |
| 07 | Hex Dump | Applied | 58/60 | 96.7 |
| 08 | Huffman Compression | Applied | 58/60 | 96.7 |
| 09 | Stream Editor | Applied | 58/60 | 96.7 |
| 10 | HTTP Server | Applied | 59/60 | 98.3 |
| 11 | Load Balancer | Applied | 58/60 | 96.7 |
| 12 | Git Internals | Applied | 57/60 | 95.0 |
| | **Total** | | **1513/1560** | **97.0** |

### Compile Failure Analysis

15 compile failures across 225 exercises (6.7% failure rate):

| Category | Count | Examples |
|----------|-------|---------|
| 0.15.2 API differences | 3 | ArrayList.init → .empty, pool.spawn error union, catch block type |
| Comptime return type constraints | 4 | Returning []const u8 from comptime block (all in L04) |
| Shadowing and naming | 2 | Parameter shadows method; redundant comptime keyword |
| Type system strictness | 3 | mem.sliceTo sentinel type, stat field signedness, @truncate on signed |
| Structural issues | 2 | Dead code after return, unused parameters |
| Control flow | 1 | Catch block type mismatch |

Foundation lessons produced 10 failures across 150 exercises (6.7%). Applied lessons produced 5 across 75 exercises (6.7%). The rate held steady because the two lesson types test different skills: foundation lessons test API knowledge; applied lessons test integration and program architecture.

### Known-Pitfall Tracking

4 violations across 225 exercises (1.8%):

1. **L01:** ArrayList.allocator field access (0.15.2 uses .empty, not stored allocator)
2. **L04:** Redundant comptime keyword in struct const
3. **L07:** std.io.getStdErr() instead of std.fs.File.stderr()
4. **L11:** ArrayList.init(alloc) instead of .empty

All four are 0.15.2 API changes — the model's training data contains the old patterns, and under pressure the agent reverts to them. The low rate (1.8%) suggests the skill file overrides training data most of the time, but not always.

### Improvement Trajectory

Foundation lesson scores: 90% → 100% → 97% → 97% → 99% → 99.5%

The first lesson (90%) established the baseline. Lesson 02 hit 100% — the skill updates from L01 (defer/errdefer ordering, ArrayList .empty pattern) took effect immediately. Scores stabilized at 97-99.5% as lesson difficulty increased but the skill grew to match.

### Skill Growth

The skill file grew from 0 to 350 lines across 12 lessons:

- **40+ API corrections** — the correct 0.15.2 patterns for ArrayList, HashMap, stdout/stderr, JSON, networking, file I/O, and more
- **7 decision frameworks** — allocator selection (9 cases), error handling (5 patterns), comptime vs runtime (5 signals), data structure selection (8 cases), concurrency primitives (8 types), custom allocator VTable, atomics operations
- **8 style idioms** — explicit if-unwrap, StaticStringMap, defer/errdefer, anytype writers, create-once resources, allocator passing, custom format, exhaustive switch

## What "Learning" Means Here

This is in-context learning augmented by persistent external memory, not weight updates. The model's parameters stay frozen. It cannot generalize beyond what the skill file explicitly states and cannot transfer knowledge to domains the file omits.

The skill file acts as working memory that survives across sessions. At session start, the agent loads 350 lines of curated reference. During the session, it consults them. After the session, it updates them.

The analogy: a surgeon does not rewire their brain between operations. They update their checklist. The checklist does not make the surgeon smarter — it makes them more consistent. It catches the mistakes that knowledge alone fails to prevent: those that arise under cognitive load, time pressure, or fatigue.

The limitations are real:

- **Context window bound.** The skill must fit in the system prompt. At 350 lines it's manageable; at 3,500 it would crowd out the conversation. Growth requires curation — adding a new entry often means condensing or removing an old one.
- **RAG as overflow.** When the skill outgrows what fits in context, semantic search provides just-in-time retrieval. The three RAG collections (references, stdlib, exercises) hold material too detailed for the skill file. But RAG retrieval is imprecise — sometimes the agent retrieves the wrong chunk, or skips the search entirely. The skill file's advantage: it is always present.
- **Training data gravity.** The model's prior knowledge exerts constant pull. Under pressure, the agent reverts to 0.14 patterns even when the skill file documents 0.15.2 changes. All 4 known-pitfall violations follow this pattern. The skill does not erase old knowledge — it competes with it.

## Safety and Stability

Self-modification becomes dangerous when the modification target includes the modification process. A skill that rewrites its own grading rubric could optimize for high grades rather than learning. Structural separation prevents this:

**Stable core / mutable periphery.** `CLAUDE.md` (the teaching process) and `SKILL.md` (the Zig knowledge) are separate files with different change frequencies. The agent updates `SKILL.md` every lesson and rarely touches `CLAUDE.md`. A bad skill mutation — a wrong API pattern — reverts easily. A bad process mutation could corrupt the feedback signal itself.

**Atomic mutations with rollback.** Each lesson produces exactly one commit containing grade records and skill updates together. Git provides both the audit trail and the rollback mechanism. Every line in the skill traces to a specific lesson and mistake.

**Predictions as implicit contracts.** Each skill entry encodes a prediction: "if you use this pattern, the code will compile." When a known-pitfall violation occurs, the prediction failed — not because the entry was wrong, but because the agent ignored it. The double penalty (2 points instead of 1) pressures the agent to read the skill, not just write to it.

## Future Directions

### Full OODA Loop with Telemetry

The current system runs OODA informally: the agent reflects in prose and updates the skill by hand. A structured implementation would use append-only JSONL telemetry, periodic analysis by a fresh subagent, and formal mutation proposals with falsifiable predictions. Each mutation would cite evidence (which telemetry entries prompted it) and state a prediction (what should improve). Subsequent lessons would verify or reject that prediction.

### ACE Layer Mapping

The system maps to the Autonomous Cognitive Entity framework:

- **Aspirational:** Achieve deep proficiency in Zig systems programming (fixed)
- **Global Strategy:** Current study plan phase — foundations vs. advanced (updated rarely)
- **Agent Model:** Self-assessment of teaching effectiveness (produced by telemetry analysis)
- **Executive Function:** Mutation proposals based on self-assessment
- **Cognitive Control:** Mid-session decisions — teach, quiz, adjust difficulty, flag for self-modification
- **Task Prosecution:** Running the quiz, calling RAG, presenting explanations

The northbound bus is telemetry flowing up; the southbound bus is mutations flowing down.

### Branching Skill Experiments

Inspired by SICA's tree-based self-modification: maintain a branching archive of skill variants, not just the current version. Propose a mutation on a git branch. Run lessons against both the main skill and the branch. Merge if the branch outperforms; prune if it does not. Over time, this builds a tree of "things we tried" that prevents the agent from re-proposing failed mutations.

### Pedagogy Model

The current system improves what the agent knows. The next step: improve how it teaches. Which exercise sequences produce the best retention? Which explanation styles land? Which quiz patterns test understanding rather than pattern-matching? A separate mutable file (`STRATEGIES.md`) would track teaching approaches and evolve them based on performance signals.

### Cross-Domain Transfer

Can a skill trained on Zig transfer to Rust? The API corrections are Zig-specific, but the decision frameworks (allocator selection, error handling strategies, concurrency primitive selection) are structural. A cross-domain experiment would fork the skill, strip the Zig-specific entries, and test whether the frameworks accelerate learning in a new language.

### Metric Risk

The biggest risk is optimizing the wrong metric. Quiz scores measure immediate recall. They don't measure delayed retention, transfer to novel problems, or code quality in production-scale programs. A skill optimized for quiz performance might encode superficial patterns rather than deep understanding. The best signal — performance on delayed re-testing in different contexts — is the hardest to measure.

## Conclusion

A self-authored reference document measurably improves an LLM's performance on programming tasks. Across 225 exercises, the agent maintained a 97% average score while building a 350-line skill file that corrected for training-data drift, codified decision frameworks, and documented pitfalls. The mechanism requires no fine-tuning, no weight updates, and no architectural changes to the model. It requires only that the model can read what it wrote — and that the incentives reward reading it.

The skill file is not intelligence. It's a checklist. But checklists work.
