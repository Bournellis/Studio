# DraxosMobile - Foundation Audit Doc Alignment

- status: `Done`
- projeto: `draxos-mobile`
- agente: `Codex`
- branch: `codex/draxos-mobile/foundation-app-v0-audit`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-app-v0-audit`
- base: `42b6840`
- data: `2026-05-28`

## Objetivo

Alinhar a documentacao viva do DraxosMobile para a etapa `FOUNDATION_AUDIT_ACTIVE`, deixando claro que o projeto atual e uma base implementada para refinamento e que o foco imediato e auditar o loop interno pos-login.

Loop prioritario:

`Base -> coletar recursos -> evoluir base -> batalhar -> receber recompensas -> verificar base novamente`

## Fora De Escopo

- Implementar codigo, schema, backend, assets, gameplay ou balanceamento.
- Criar uma Track numerada nova.
- Apagar historico util de tracks antigas.
- Tratar armas, spells, economia, tema, nomes, visual final ou apresentacao da batalha como prioridade atual.

## Arquivos Pretendidos

- `AGENTS.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/README.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/docs/product-vision.md`
- `Projetos/draxos-mobile/docs/product-brief.md`
- `Projetos/draxos-mobile/docs/game-design-document.md`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/docs/product-vision.md`
- `Projetos/draxos-mobile/docs/product-brief.md`
- `Projetos/draxos-mobile/docs/game-design-document.md`
- `Projetos/draxos-mobile/docs/design-pending.md`

## Validacao Planejada

```powershell
git diff --check
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick -RequireClean:$false
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_agent_ops_foundation.ps1 -ProjectDir .
```

Tambem rodar buscas de drift para garantir que Track 15/16, balanceamento, armas, spells, Battle Pass, economia e visual final nao aparecem como foco operacional atual nos docs vivos.

## Handoff

Entregar os docs vivos alinhados, com Track 16 preservada como ultimo pacote tecnico local e Foundation Audit como proxima etapa operacional.

## Entrega

- Docs vivos e coordenacao alinhados para `FOUNDATION_AUDIT_ACTIVE`.
- Track 16 preservada como ultimo pacote tecnico local, nao como foco operacional atual.
- Loop pos-login registrado como foco da proxima auditoria: Base -> coletar recursos -> evoluir base -> batalhar -> receber recompensas -> verificar base novamente.
- Conteudo de armas, spells, economia, visual, tema e apresentacao de batalha rebaixado para substancia/mock.

## Validacao Executada

- `git diff --check`: passou.
- `tools/check_agent_ops_foundation.ps1`: passou apos mover este card para Done.
- `tools/validate_foundation.ps1 -Profile Quick`: falhou por drift preexistente de mirrors SQL entre `server/schema/migrations` e `supabase/migrations` em `202605270003_internal_alpha_private_downloads.sql`; fora do escopo deste pacote documental.
