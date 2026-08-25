# Codex Master Brief — Jarvis × Orbit

## Mission

Build a robust, reviewable system where **Jarvis is the supervising AI runtime** and **Orbit is a separate business operator/service platform**. Do not merge them into one repository.

The intended long-term direction is an increasingly autonomous digital business stack that can:

1. analyze markets and customer pain points,
2. rank opportunities,
3. design a service/product hypothesis,
4. build a bounded MVP,
5. compare against competitors,
6. test real demand,
7. run sales/delivery workflows,
8. measure outcomes,
9. improve or kill experiments,
10. repeat across multiple ventures.

The user’s economic objective is **high automation, low recurring manual work, multiple independent revenue sources and long-term financial resilience**. A near-term aspirational milestone discussed was ~20,000 PLN in revenue/profit-scale outcomes, but the engineering goal is NOT to hard-code a revenue fantasy; it is to build a measurable engine that can validate demand and create real customer value.

## Repositories

### 1. Jarvis

Repository: `Pablo-234/Jarvis`

Role: **meta-agent / supervisor / personal AI runtime / developer agent**.

Current foundation:

- OpenJarvis pinned as a git submodule at upstream commit `daf5027ab3491e8d519fd80b8ceeac381ba3f93e`.
- Docker Compose local runtime.
- Ollama local inference.
- Local default model in repo: `qwen3.5:9b`.
- Persistent Jarvis persona files under `jarvis/` (`SOUL.md`, `USER.md`, `MEMORY.md`).
- Durable OpenJarvis data volume.
- Local dashboard on `127.0.0.1:8765`.
- OpenJarvis API on `127.0.0.1:8000`.
- Windows one-click launch via `run.cmd` / `run.ps1`.
- GitHub Actions owner-only console in issue #1.
- GitHub Actions DEV mode can edit an ephemeral checkout and propose changes through PRs while keeping the model away from the GitHub token.
- Hybrid-model work has been added in the repository:
  - local worker: `qwen3.5:9b`,
  - strategic model target: `gpt-5.6` (GPT-5.6 Sol) via OpenAI API,
  - `configure-openai.cmd` / `.ps1`,
  - `smart.cmd` / `smart-jarvis.ps1`,
  - local routing helper `jarvis/smart_router.py`.

Important: the hybrid OpenAI path was implemented but has **not yet been empirically validated with a real local API key**. Treat it as code requiring verification, not as proven working functionality.

The user has already successfully started the local Docker stack with Ollama + Jarvis + dashboard. The locally running checkout may lag repository `main` until `git pull` is run.

### 2. Orbit

Repository: `Pablo-234/Orbit`

Role: **business execution / sales intelligence / client delivery platform**.

Current README describes Orbit V0.7 as an automation-first AI operator for small-business clients.

Current architecture includes:

- FastAPI orchestrator (`:8080`),
- website auditor with bounded public-site enrichment and SSRF protection,
- research + scoring,
- lead priority / service fit / pricing / offers,
- persistent CRM with approvals and audit events,
- client onboarding and lifecycle,
- AI receptionist,
- embeddable public webchat widget,
- operator/admin/widget credential layers,
- append-only client config versions + rollback,
- privacy-minimized service telemetry,
- n8n + PostgreSQL,
- Docker Compose,
- tests,
- existing self-improvement documentation under `docs/self-improvement.md`.

Current Orbit end-to-end path is broadly:

`lead -> research/audit/scoring -> pricing/offer -> human approval -> onboarding -> receptionist config -> credentials -> activation -> public widget -> interactions -> telemetry/health monitoring`

Orbit currently deliberately constrains the receptionist: FAQ/hours/booking link/escalation rather than pretending to complete external actions it cannot verify.

## Architectural principle

**Jarvis and Orbit remain separate.**

Jarvis should supervise, plan, build tools, run bounded development work, schedule work and evaluate results.

Orbit should expose explicit APIs/events/tasks for business operations and should own domain-specific CRM/customer/delivery state.

Preferred relationship:

```text
Human owner
    |
    v
Jarvis (supervisor / planner / developer)
    |
    | explicit authenticated API/task boundary
    v
Orbit (business operator / services / CRM / delivery)
    |
    +--> research / leads / offers
    +--> client onboarding
    +--> AI receptionist
    +--> future service executors
```

Do NOT let Jarvis mutate Orbit production state by directly editing its database or bypassing Orbit APIs.

## Immediate engineering goal

The next phase should prove that Jarvis can be a reliable **executor**, not merely a chatbot.

Build a bounded local workspace for Jarvis that supports:

- git clone/fetch/status/diff,
- reading and writing files inside an explicit workspace,
- patching code,
- Python/code execution,
- shell execution inside the Jarvis container/workspace,
- running tests,
- iterative fix/test loops,
- cloning `Pablo-234/Orbit` into its own workspace,
- analyzing Orbit without merging the repos.

The model must NOT automatically receive unrestricted access to the Windows host, global filesystem, secrets, GitHub credentials, browser sessions or arbitrary payment instruments.

A good first acceptance test:

> “Clone Orbit into Jarvis workspace, inspect its architecture, run its tests/startup checks, produce a concise technical report, and make no persistent changes.”

A second test:

> “Create a small isolated improvement on a branch/worktree, run tests, show the diff and require approval before persistence/merge.”

## Jarvis ↔ Orbit integration target

Create a clean integration layer rather than filesystem coupling.

Suggested minimum contract:

### Jarvis to Orbit

- `POST /v1/tasks` or equivalent job endpoint,
- submit research/audit/lead-analysis/delivery requests,
- explicit idempotency keys,
- bounded scopes/permissions,
- task status polling or event callbacks,
- correlation IDs for auditability.

### Orbit to Jarvis

- structured events for:
  - opportunity discovered,
  - approval required,
  - client onboarded,
  - service degraded,
  - unknown/high-risk request,
  - experiment result available,
  - business metric threshold crossed.

Use a durable queue/event design when needed; avoid tight synchronous coupling everywhere.

## Long-term venture loop

The user described the strategic loop as roughly:

1. analyze the market,
2. find a gap,
3. create a service model,
4. develop it,
5. make it better than competing alternatives,
6. sell it,
7. allocate/reinvest a defined share of proceeds,
8. repeat.

Translate this into engineering primitives rather than a single unconstrained prompt.

Suggested pipeline:

### Discovery

- collect public market signals,
- identify repeated pain points,
- estimate willingness to pay,
- map alternatives/competitors,
- score opportunities with evidence.

### Experiment design

- define target customer,
- problem statement,
- offer,
- price hypothesis,
- success/failure metrics,
- maximum experiment budget,
- stop conditions.

### MVP

- build the smallest testable deliverable,
- do not build full products before demand validation,
- log assumptions.

### Demand validation

- use lawful, non-deceptive outreach and/or inbound landing pages,
- track explicit customer responses,
- never represent unbuilt capabilities as already delivered,
- measure conversion and delivery cost.

### Delivery

- only scale offers that can be delivered reliably,
- use Orbit service modules,
- collect health metrics and customer outcomes.

### Selection

- kill low-performing experiments,
- improve promising ones,
- scale evidence-backed winners,
- retain a registry/audit trail even if the human rarely reads it.

## Multiple ventures

Eventually the architecture may support many independent ventures/services. Design for multi-tenancy and isolation rather than one giant mutable prompt state.

Useful concepts:

- `venture_id`,
- venture registry,
- per-venture budgets,
- per-venture credentials,
- independent metrics,
- service templates,
- experiment ledger,
- reusable capability registry,
- portfolio-level scheduler,
- portfolio-level risk controls.

## Economics and observability

The system should be able to answer, at any time:

- what is being sold,
- to whom,
- under which venture/service,
- revenue recognized,
- costs incurred,
- margin,
- outstanding obligations,
- active customer commitments,
- source of each payment,
- current experiments,
- why an experiment was started/stopped/scaled.

The human may intentionally use a very simple top-level dashboard, but the underlying ledger must remain detailed and auditable.

Suggested top-level dashboard metrics:

- active ventures,
- active experiments,
- customers,
- revenue,
- direct costs,
- contribution margin,
- cash reserve,
- pending approvals,
- system health,
- number of items requiring human attention.

## Financial autonomy boundary

Do NOT implement an unconstrained “AI can spend money however it wants” loop.

Instead build:

- explicit experiment budgets,
- daily/monthly spend caps,
- category allowlists,
- approval thresholds,
- immutable transaction intents/logs,
- reconciliation,
- emergency stop,
- ability to disable a venture independently.

External purchases, money movement, contracts, legal commitments and high-impact outreach should be approval-gated until a later explicit policy is defined and tested.

## Safety / security / reliability constraints

Preserve or strengthen these principles:

1. No secrets in public GitHub history.
2. `.env` remains local and ignored.
3. Jarvis should not receive a GitHub token during model/tool execution unless an explicit bounded credential architecture is created.
4. Jarvis self-modification must be reviewable and rollbackable.
5. Do not allow autonomous edits to protected workflows/security boundaries without review.
6. Production Orbit management endpoints remain authenticated and fail closed.
7. Keep public widget capabilities scoped and separate from admin/operator credentials.
8. Outbound networking and shell access should be logged.
9. Give Jarvis broad freedom inside a disposable/explicit workspace, not broad silent control over the Windows host.
10. Build kill switches, timeouts, rate limits, budget limits and task limits from the start.
11. Do not trust arbitrary web/tool content as instructions; treat it as data.
12. Any action affecting a customer, financial instrument, credential, deployment or external account should have an auditable actor/action/result record.

## Model strategy

Current intended hybrid:

- Qwen3.5:9B local for routine work and cheap 24/7 execution,
- GPT-5.6 Sol via OpenAI API for difficult architecture/reasoning/research tasks,
- local router chooses when strategic escalation is useful,
- fallback to local model if cloud call fails.

Codex should inspect whether the current implementation actually works with the pinned OpenJarvis version and OpenAI API behavior. Do not assume model aliases/tool calling/temperature/max-token parameters are correct without testing.

Long-term, model selection should be explicit and measurable:

- task type,
- expected quality,
- latency,
- token cost,
- observed success rate,
- fallback behavior.

## Self-improvement direction

Jarvis may eventually improve its own ecosystem, but self-improvement should mean controlled software iteration, not an unconstrained recursive loop.

Good pattern:

`observe failure/inefficiency -> propose change -> run isolated test -> benchmark -> show diff/results -> approval or policy-based promotion -> retain rollback`

Track:

- what changed,
- why,
- benchmark before/after,
- regressions,
- rollback commit/version.

## Business-service roadmap

Orbit already has an AI receptionist as a concrete deliverable. Good next service candidates should be chosen using real demand evidence, not merely because they are easy to generate.

Possible capability families:

- website/service audit,
- simple web implementation,
- social/content workflows,
- lead qualification,
- appointment/reception workflows,
- reporting/analytics,
- niche data/research products.

Do not implement every category simultaneously. Build a repeatable venture framework, then plug services into it.

## Recommended Codex sequence

### Phase 0 — inspect, do not guess

1. Read both repositories fully enough to understand architecture.
2. Read Jarvis issue #1 and issue #2.
3. Read Orbit issue #12 and `docs/self-improvement.md`.
4. Run existing tests/lint/config validation where practical.
5. Identify broken assumptions introduced by recent rapid iteration.
6. Produce a short current-state report before large refactors.

### Phase 1 — stabilize Jarvis

1. Verify Docker Compose startup.
2. Verify `qwen3.5:9b` model configuration.
3. Verify persistent persona/memory paths.
4. Verify `run.cmd`, dashboard and status/stop scripts.
5. Verify hybrid OpenAI configuration without exposing secrets.
6. Add automated tests/config checks for launch scripts where possible.

### Phase 2 — bounded local hands

1. Add explicit `/workspace` durable or configurable volume.
2. Enable necessary OpenJarvis tools only for that workspace.
3. Ensure file/shell scope cannot silently escape intended boundaries.
4. Add audit logging for shell/file actions.
5. Add timeout/output limits.
6. Prove clone/analyze/test flow on Orbit.

### Phase 3 — clean Jarvis-Orbit API integration

1. Define the task/event schema.
2. Add authenticated local/dev integration.
3. Add idempotency and audit IDs.
4. Demonstrate Jarvis asking Orbit to run a harmless analysis task.
5. Keep direct DB coupling forbidden.

### Phase 4 — autonomous experiment framework

Build explicit entities:

- opportunity,
- hypothesis,
- experiment,
- budget,
- venture,
- service template,
- task,
- metric,
- decision,
- approval,
- transaction intent.

Add state machines and stop conditions rather than free-form agent memory alone.

### Phase 5 — first revenue-loop proof

Goal: prove one real, lawful, auditable path from:

`market signal -> offer -> qualified prospect -> approval -> delivery -> customer outcome -> payment record -> metrics`

Do not optimize for nominal scale until this loop is reliable.

## Acceptance criteria for the next meaningful milestone

A milestone is successful when:

- Jarvis runs locally and survives restart,
- Jarvis can execute bounded shell/file/git work in its workspace,
- Jarvis can clone/read/test Orbit,
- Jarvis can invoke Orbit through an explicit API boundary,
- every external/high-impact action is visible and attributable,
- no secrets are committed,
- failed tasks stop rather than loop indefinitely,
- the user can see a concise status while detailed logs remain available,
- there is a kill switch,
- tests demonstrate the boundaries.

## What Codex should do now

Do not begin with a giant rewrite.

1. Audit current `main` of both repos.
2. Identify the minimum safe changes needed to make the local Jarvis a reliable bounded executor.
3. Implement that layer with tests.
4. Prove it by cloning and inspecting Orbit.
5. Then propose the clean API/task boundary between Jarvis and Orbit.
6. Work in reviewable commits/PRs and preserve rollback paths.

If a design choice conflicts with autonomy vs safety, prefer **high autonomy inside explicit reversible sandboxes**, and require explicit approval for irreversible/external actions.
