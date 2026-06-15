# DraxosMobile Hardening Done: client-shell - Arena UX Readability Recovery

## Metadata

- data: `2026-06-15`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/arena-ux-readability-recovery`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-ux-readability-recovery`
- commits: `52c870c7 fix(draxos-mobile): clarify arena ux recovery loop`

## Resultado

Implementado candidato local estreito para a prova humana da Arena PVE. A mudanca nao publica pacote, nao altera backend, nao muda economia/tuning e nao expande conteudo.

## Mudancas

- `arena_surface_presenter.gd`: adiciona roteiro visivel da Arena, CTA especifica para tutorial/primeira arena real, tentativa ativa mais legivel, consequencia clara de abandono/retomada e leitura de buff aplicado ao proximo duelo.
- `arena_surface_text.gd`: centraliza textos de roteiro, CTA recomendada e resumo de recompensa sem expor token tecnico do backend.
- `arena_lifecycle_flow.gd`: melhora feedback apos iniciar Arena, aplicar buff, abandonar e confirmar resumo.
- `test_boot_mobile_ui.gd`: cobre roteiro, CTA, buff temporario, resumo, abandono/retomada e tentativa ativa.
- `smoke_responsive_layout.gd`: atualiza smoke de layout para a CTA da primeira arena real.

## Validacao

- `git diff --check`: `PASS`
- `Godot --headless --path . -s res://tools/validate.gd`: `PASS` (`285/285` testes GUT)
- `Godot --headless --path . -s res://tools/smoke_responsive_layout.gd`: `PASS`
- `validate_foundation.ps1 -Profile ClientQuick`: `PASS` (DocsOnly + ClientQuick, GUT `285/285`, smokes runtime/foundation/layout/modes/exports)

## Remote Mutation / Publication

- remote mutation/publication run: `no`
- preserved boundary: `no deploy, no Supabase/Cloudflare mutation, no export/publication`

## Proximo Passo

Fabio/tester deve executar a prova humana em `Projetos/draxos-mobile/docs/arena-pve-product-proof.md` e registrar o veredito antes de qualquer pacote oficial, tuning, economia, PVP, conteudo novo, visual final ou expansao Openworld.
