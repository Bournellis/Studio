# AGENTS.md

## Metadata

- status: `active`
- authority: `operational_contract`
- last_verified: `2026-08-27`
- review_when: `governance, portfolio, Git or validation contract changes`
- supersedes: `AGENTS.md before Governance v2`
- superseded_by: `none`

This file governs agent behavior for `D:\Estudio`.

Fabio decides product, priority, human QA, gates, release and product/operations
remote mutations. Routine Git push from `main` to `origin/main` is permanently
delegated to Codex under the exact limits below.

## Authority Order

1. Latest active decision for the affected product or process.
2. `08_Coordenacao_Agentes/Prioridades_Estudio.md` for focus, portfolio status and allowed work.
3. `Projetos/<project>/implementation/current-status.md` for local baseline, gate, risk, validation and next technical step.
4. `08_Coordenacao_Agentes/Estado_Atual.md` as the short portfolio projection.
5. Product and technical contracts local to the selected project.
6. Routers such as README, AGENTS, indexes and dashboards.
7. Historical tracks, Done cards and handoffs.

Routers never override state or product contracts. Shared lore never imports mechanics into a project.

## State And Portfolio Sync

- `Prioridades_Estudio.md` is the only authority for focus, status taxonomy and allowed work.
- Each `implementation/current-status.md` is the only local technical state authority.
- `Estado_Atual.md` is updated only by `portfolio_sync`, `cross_project` or `global_governance` work.
- Local work records `global_sync_needed: yes` in `PortfolioSync_QUEUE.md`; it does not edit global snapshots.
- `Prioridades_Estudio.md` changes only when Fabio changes priority, status or allowed work.
- History belongs in `implementation/history.md`, history ledgers and release history. Done cards and closed handoffs are transient inputs to the Documentation Lite lifecycle.

## Scope Classification

Classify before acting:

- `project_local`: one project, local files and coordination only.
- `operations_local`: local build, QA, evidence or release preparation without remote mutation.
- `cross_project`: intentional change across two or more projects.
- `portfolio_sync`: reflect local state into the global projection.
- `global_governance`: contracts, tooling, templates or process for the workspace.
- `documentation_alignment`: authority, routing or history cleanup without product change.
- `review`: assess evidence; do not mutate unless explicitly requested.
- `implementation`: authorized product/runtime work inside the selected project.

Local-first is mandatory for `project_local` and `operations_local` work.

## Local Coordination

Every official project owns:

```text
08_Coordenacao/
  README.md
  documentation-index.md
  TRIAGE.md
  Kanban/{Backlog,Doing,Review,Done}/
  Handoffs/
```

- New project-local cards and handoffs live there.
- Global Kanban and Handoffs contain current global/cross-project work. Pre-cutover history lives in compact History/ledgers and exact Documentation Lite receipts.
- `TRIAGE.md` lists only live human gates in Review.
- Do not create `08_Coordenacao/Estado.md`; point to `implementation/current-status.md`.

## Gates V3

New cards use `closure_protocol: agent_local_merge_v3` and record technical, human and publication states separately.

- `Review` accepts only `human_gate_status: pending` with an explicit `blocking_decision`.
- `Done` rejects a pending human gate.
- Technical work may be committed, merged and cleaned when automation is green even if a human product gate remains pending.
- Approval, rejection or supersession resolves the human gate and moves the card to Done.
- General approval never implies release, remote mutation beyond the already delegated routine Git synchronization, monetization, device QA, priority change or approval of unrelated gates.
- Product, visual, feel, device, release, monetization and priority decisions remain Fabio's.

## Multi-Agent And Worktrees

`D:\Estudio` is the main coordination/read tree, not an implementation worktree.

```text
D:\Estudio-worktrees\<project>--<agent>--<slug>
codex/<project>/<slug>
<agent>/<project>/<slug>
```

- Every writer uses a dedicated external worktree unless Fabio explicitly authorizes direct work.
- One writer per worktree; no simultaneous edits to the same file.
- The lead owns integration, validation, coordination and final delivery.
- Project agents touch only their project; the global coordinator is the sole writer of shared files.
- Before shared edits, run `git status --short`, `git worktree list` and read the current authority docs.
- Register objective, branch, worktree, intended files, validation and handoff before editing.
- Stop on semantic conflict, ambiguous scene/binary, unexpected generated diff, secret, unexpected remote mutation or a new human decision.

## Git And Remote Boundary

- Agents may perform local branch, commit, rebase, merge, worktree and cleanup operations.
- Use logical commits; do not mix docs, runtime, validation and publication in a mega commit.
- Merge approved technical branches locally with `ff-only` after rebasing onto current `main`.
- Keep worktrees clean; validate after merge, remove worktree, delete branch and prune.
- After validated integration on a clean `main`, the global Codex coordinator
  runs the safe `main` to `origin/main` synchronization in
  `08_Coordenacao_Agentes/Runbooks/GIT_SAFE_PUSH.md`, verifies remote OID equals
  `HEAD` and does not request new authorization.
- Only the runbook's exact preflight fetch and exact push are delegated. `pull`, login/PAT, credential changes, force/force-with-lease, tags, extra branches/refs/remotes and product publication remain prohibited.
- Fetch, authentication, fast-forward, LFS/hook, push or verification failure stops the flow and preserves the local commits.
- Final handoff records `git_sync_status` independently from product publication.
- While the agent commits/merges in a tree, GitHub Desktop and IDEs must not stage, discard or commit in that tree.

## Portfolio Gate And Routing

Read before deep project work:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `Projetos/README.md`
3. `08_Coordenacao_Agentes/Estado_Atual.md`
4. target `AGENTS.md` and `implementation/current-status.md`
5. target local coordination and live card

Route domains:

- football/Copa/ball/goals -> `Projetos/JogoDaCopa/`
- FPS/arena/hitscan/jump pads -> `Projetos/FpsPlayground/`
- roguelike/ship hub/run map/Souls/relics/lanes -> `Projetos/draxos-roguelike-cardgame/`
- mobile/browser/Supabase/autobattler/Base/Internal Alpha -> `Projetos/draxos-mobile/`
- isometric action campaign -> `Projetos/rpg-isometrico/`
- turn-based board/card exploration -> `Projetos/rpg-turnos/`
- `_conceitos/mobile-universe/` -> read-only reference

`Draxos` alone does not select a project. Paused projects allow only consultation, governance and explicitly authorized integrity work unless Fabio explicitly resumes product work.

## Studio Core, Canon And Product Boundaries

- `STUDIO_CORE.md` routes shared lore to the thematic authorities and exact
  provenance snapshots in external `D:\Studio Core` at logical revision
  `lore.v2`; `CANON_CURRENT.md` and `NARRATIVE_WINDOWS.md` are routers, not
  monolithic authorities.
- Every official project declares `shared` or `none` plus adopted domains in its local `STUDIO_CORE.md`.
- `DocsOnly` and `studio_doctor Core` prove the canonical clean Core on `main`, official `origin/main` tracking and equal registry blobs before comparing all six local bindings; drift fails local validation.
- An isolated GitHub checkout without the external Core reports that comparison as unavailable, never as proof of parity; canonical local validation remains required before integration.
- `canon/shared-lore/` contains superseded recovery bridges, not living shared authority.
- `canon/studio-conventions/project-boundaries.md` remains the local operational adoption contract.
- RPG Isometrico product canon lives in `Projetos/rpg-isometrico/docs/canon/`.
- Other projects own their product, mechanics, progression, architecture and platform contracts locally.
- A mechanic crosses projects only through explicit adoption in the receiving project's local contract.
- JogoDaCopa and FpsPlayground inherit no Draxos gameplay/economy/progression/backend rules.
- DraxosMobile inherits no gameplay from the Roguelike, RPG Turnos or RPG Isometrico.
- Shared-universe membership never implies crossover, shared campaign, knowledge between peoples or promotion of local lore; only a literally adopted thematic authority or narrative window can declare a narrower shared scope.

## Godot And Validation

- Expected versions live in `.godot-version`; Godot projects use their local AGENTS and validator contracts.
- Generated resources must be deterministic. Run generator/validator twice when changing generated outputs.
- Validators must not change tracked state; `VALIDATOR_SIDE_EFFECT` is a failure and is never auto-restored.
- Global runners acquire the named `GodotQA` or `AndroidQA` execution resource before touching shared local runtimes.
- Automated runs use an isolated temporary Godot user-data namespace by default; a shared namespace requires a typed manifest declaration and the matching lock.
- Custom validators may emit one `ESTUDIO_JSON:` result contract. When a runner declares it required, missing, malformed, mismatched or `ok: false` output fails the run.
- Use `tools/studio_doctor.ps1` for environment/integrity checks.
- Use `tools/validate_estudio.ps1` with the smallest proportional profile.
- Docs-only work does not require Godot runtime unless a local contract explicitly requires it.
- `FullLocal` never performs remote, physical-device, publication, signing or remote-database operations.

## Documentation Rules

Living authoritative documents carry `status`, `authority`, `last_verified`, `review_when`, `supersedes` and `superseded_by` metadata.

- README, AGENTS, indexes and dashboards are routers without packages, release URLs, markers or next steps.
- Active local state targets 50 lines and must stay at or below 60.
- Paused local state targets 40 lines and must stay at or below 50.
- Routers must stay at or below 100 lines.
- Classify documentation as `live`, `reference`, `evidence` or `historical_redundant`; only the first two belong in the normal search path.
- Normal searches ignore Done, Handoffs, archives and redundant history. Search those paths explicitly only when historical evidence is needed.
- Preserve unique history before deleting duplication; Git history remains the final recovery layer.
- Historical deletion requires an approved cleanup manifest naming every path and its retained authority; classification alone never authorizes deletion.
- Claude/OpenClaw are `historico/deprecated` and may appear only in historical records or explicit compatibility wording.

## Assets, Evidence And Candidate Artifacts

- New runtime assets record origin, hash, license, permitted use and independent integration/publication states.
- Runtime screenshots are the authority for technical integration; visual approval remains a human gate.
- New evidence bundles use `estudio_evidence_v1`; helpers are dry-run by default and never delete historical evidence.
- Mobile candidates are identified by immutable hash. Physical validation must use the exact prepared artifact without rebuild.
- Candidate preparation, qualification, promotion and publication are separate acts; only Fabio may authorize device QA, release or publication.
- Cross-project code similarity is recorded as a convergence candidate, never extracted into shared code without explicit local adoption and two active consumers.

## Hard Stops

Never automate or infer authorization for:

- product, feel, visual or human playtest approval;
- priority or portfolio changes;
- remote mutation, publication or release outside the delegated routine Git synchronization;
- secrets, production signing or credentials;
- physical-device authority;
- importing mechanics between projects;
- expanding a paused project beyond the user's explicit scope.
