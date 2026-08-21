# Workflow

This file defines when to use direct chat, investigation, analysis, planning, implementation, review, commands, and skills.

It is not a replacement for `CORE.md`. `CORE.md` is always-on behavior. This file is operational guidance for choosing the right amount of process.

## Goal

- Use the smallest workflow that preserves correctness.
- Avoid long plans for simple work.
- Avoid implementation before understanding risky or ambiguous work.
- Keep global instructions light and load detail only when useful.
- Improve response quality independently of the current model or CLI.

## Session Discipline

One task per session. When the task changes, start a new session — do not keep working a different, unrelated task inside the same conversation just because it is open.

Before closing or pausing a task that is not finished, run `/handoff` first, so the next session picks it up from a written state instead of from memory. Wanting to start something unrelated to the last handover mid-session is the signal that tasks are about to mix — stop and write the handoff for the current one before switching.

## First Decision

Before choosing a command or skill, classify the task:

| Type | Definition | Default Action |
|---|---|---|
| `trivial` | typo, copy, local rename, tiny style tweak | do directly |
| `small` | clear, reversible, low-risk, no meaningful edge cases | do directly |
| `medium` | changes behavior, several files, user flow, validation, or logic | compact analysis + short plan |
| `large` | broad feature, architecture, migration, or multiple decisions | full analysis + approval |
| `risky` | auth, payments, security, tenant isolation, data, production config, public contracts | stop + analyze + approval |
| `investigation` | user wants to understand something | explain flow, do not edit |
| `review` | code/diff/PR already exists | findings first |

If classification is unclear, ask one concrete question or state the assumption.

## Output Budgets

| Budget | Use When | Shape |
|---|---|---|
| `brief` | default, trivial/small work | 1-5 bullets or short paragraph |
| `standard` | medium work or useful explanation | concise sections, usually 6-10 bullets |
| `deep` | large/risky/debugging/architecture | structured analysis with summary first |

Default to `brief`. Escalate only when risk, ambiguity, multiple viable options, or user request justifies it.

## When To Use Direct Chat

Use direct chat when:

- The task is `trivial` or `small`.
- Scope is clear.
- The change is reversible.
- There are no meaningful edge cases.
- It does not touch sensitive areas.

Expected behavior: inspect only what is needed, make the change, verify if practical, then summarize briefly.

Do not run `/analyze-feature`, `/create-plan`, or `/dev-pipeline` for simple work unless the user explicitly asks.

## When To Investigate

Use investigation when the user asks how something works, why something happens, where something is validated, or what happens in a flow.

Preferred skill: `code-investigator`.

Expected output: explain business logic, data flow, boundaries, and risks. Do not describe code line by line unless asked. Do not edit code unless the user switches from investigation to implementation.

## When To Debug

Use debugging when there is a bug report, error message, stack trace, failing build, or unexpected behavior.

Preferred command/skill: `/debug-root-cause` or `debug-root-cause`.

Expected output: symptom, evidence, root cause, minimal fix, verification, and regression risk.

For obvious low-risk bugs, the assistant may fix directly after identifying the cause. For unclear or risky bugs, stop after root cause and recommend the fix.

## When To Analyze

Use analysis when the task is `medium`, `large`, `risky`, ambiguous, or has multiple viable solutions.

Preferred command: `/analyze-feature`.

For `medium` work, keep analysis compact: context, recommendation, risks, decision needed.

For `large` or `risky` work, include options, challenge, estimate, edge cases, and explicit approval point.

If the task turns out to be small, say so and recommend direct implementation instead of producing a full artifact.

## When To Plan

Use planning only after a solution is chosen or the user explicitly asks for a plan.

Preferred command: `/create-plan`.

Expected output: incremental steps, affected files, validation, risks, and clear input for implementation.

Do not create a long implementation plan if the change can be safely handled directly.

## When To Implement

Use implementation directly for `trivial` and `small` work.

Use `/dev-pipeline` only when there is an approved plan, clear scope, acceptance criteria, and known risks.

During implementation:

- Do not expand scope.
- Do not refactor unrelated code.
- Preserve existing project patterns.
- Verify with the smallest useful check.
- Report changes, verification, and remaining risks briefly.

## When To Review

Use review when code already exists, before closing meaningful work, or when the user asks for a review.

Preferred command: `/review-work`.

Expected output: findings first, ordered by severity. If no findings, say so and mention residual testing gaps.

Do not lead with praise, summary, or explanation before findings.

## Current Tool Policy

Use the current tool by default.

Do not suggest switching CLI or model unless the user asks, the current tool is blocked, or the task cannot be completed safely with the current capabilities.

If switching tools is necessary, first provide a short handoff: goal, findings, files touched or read, decisions made, next step, and risks.

## Command Matrix

| Situation | Use | Avoid |
|---|---|---|
| Simple edit | direct chat | `/analyze-feature`, `/create-plan` |
| Bug | `/debug-root-cause` | broad refactor first |
| Unknown flow | `code-investigator` | editing while still discovering |
| Medium feature | `/analyze-feature` compact | deep plan before decision |
| Approved solution | `/create-plan` | implementation without scope |
| Approved plan | `/dev-pipeline` | changing architecture mid-run |
| Finished meaningful change | `/review-work` | self-approval without review |

## Escalation Rules

Escalate from direct chat to analysis when:

- Requirements are ambiguous.
- There are meaningful edge cases.
- Multiple solutions are plausible.
- The task affects business logic or user flow.
- The task touches several modules.
- The cost of a wrong change is high.

Escalate to approval before implementation when:

- The work is `large` or `risky`.
- Data can be lost or corrupted.
- Public behavior or contracts change.
- Security, auth, payments, tenant isolation, production config, or migrations are involved.

## De-escalation Rules

De-escalate to direct work when:

- The requested change is small and clear.
- The analysis reveals only one safe option.
- The plan would be longer than the implementation.
- The user explicitly asks for a quick fix and risk is low.

Say that a full plan is unnecessary and proceed.

## Output Defaults

For direct work: final answer should usually include what changed, verification, and any relevant risk.

For analysis: final answer should include context, recommendation, risks, and decision needed.

For plans: final answer should be executable, incremental, and no longer than needed.

For reviews: final answer should start with findings.
