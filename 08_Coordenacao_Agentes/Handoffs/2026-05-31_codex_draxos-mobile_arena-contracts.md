# DraxosMobile - Arena Contracts

- Agente: Codex
- Branch: `codex/draxos-mobile/arena-contracts`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-contracts`
- Base: `codex/draxos-mobile/pve-arena-integration` (`e5ee829`) apos checkpoint de coordenacao; branch recriada por reset local preservando e reaplicando o diff de contracts/content.
- Objetivo: etapa documental/data-driven de Arena PVE Initial, restrita a docs, contratos, dados e ruleset.
- Arquivos previstos: `Projetos/draxos-mobile/docs/pve-arena-v1.md`, `docs/design-pending.md`, `docs/game-design-document.md`, `docs/product-brief.md`, `docs/contracts/*.md`, `data/definitions/pve_arenas.json`, `pve_enemies.json`, `arena_buffs.json`, `arena_rewards.json`, `tools/generate_foundation_ruleset.ts`, `server/tests/foundation_ruleset_test.ts`, ruleset/mirrors gerados.
- Documentos lidos: `AGENTS.md`, `08_Coordenacao_Agentes/Prioridades_Estudio.md`, `Projetos/README.md`, `08_Coordenacao_Agentes/Estado_Atual.md`, `canon/canon-brief.md`, `Projetos/draxos-mobile/AGENTS.md`, `docs/agent-operating-manual.md`, `docs/documentation-index.md`, `docs/foundation-app-v0-audit.md`, `docs/foundation-expansion-readiness.md`, `docs/foundation-loop-audit.md`, `docs/pve-arena-initial-direction.md`, `docs/product-vision.md`, `docs/product-brief.md`, `docs/game-design-document.md`, `docs/design-pending.md`, contratos de API/content/battle-log/database/ruleset.
- Validacao planejada: `git diff --check`, gerar `foundation_ruleset_v0`, `npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts` e checks rapidos aplicaveis sem backend remoto.
- Proximo handoff: contracts/data prontos para backend/client agents conectarem endpoints e UI sem reabrir decisoes de produto.
