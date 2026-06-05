# DraxosMobile Done: Project Coherence Hardening

## Metadata

- data: `2026-06-04`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `validation-release`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/project-coherence-hardening`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--project-coherence-hardening`

## Resultado

Revisao completa de coerencia do projeto DraxosMobile apos a publicacao
Openworld Main Menu Sync. O trabalho fechou lacunas entre documentacao viva,
contratos, release fallback, validadores e runtime guardrails antes do proximo
ciclo de playtest humano.

Principais entregas:

- docs vivos, portfolio, painel visual, canon brief e runbooks alinhados ao
  pacote atual `Openworld Main Menu Sync`, release root
  `internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8` e preview
  `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`;
- Foundation Hardening V2 reclassificado como baseline historico/de hardening,
  sem competir com o pacote remoto atual;
- fallback do Edge Function `release` atualizado para o pacote publicado atual,
  com contrato `NOT_FOUND` para rotas desconhecidas;
- smokes de release reforcados para exigir release root esperado e rejeitar
  roots legados;
- runtime client bloqueia mutation quando `release/config` estiver em fallback,
  read-only ou sem `mutable_gameplay_state`;
- sessao email/senha ganhou refresh por `refresh_token` antes de recuperar save;
- Openworld passa a usar token ativo do store e bloqueia start/event/complete/
  abandon/resync de mutations quando guardrails remotos nao permitem escrita;
- CORS default inclui dominio oficial e preview atual sem wildcard;
- Cloudflare package agora exige `-StaticAssetBaseUrl` versionado, evitando
  pacote com asset root antigo por default;
- smokes visuais de modos cobrem tambem `1920x1080`;
- exemplos de release root em docs vivos foram trocados por placeholder
  versionado generico, evitando copiar nomes de pacote historico.

## Validacao

Executado nesta worktree:

- `git diff --check`: PASS
- `validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`: PASS
- `check_foundation_expansion_readiness.ps1`: PASS
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS apos
  importacao headless local do Godot para registrar class_names nesta worktree;
  222 testes GUT passaram, alem dos smokes runtime, hardening, responsive,
  modes visual layout e exports.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS apos
  fechamento deste card em Done. Release manifest typecheck, release plan
  dry-run, release safety, Android keystore gate, Track 13 readiness e Agent Ops
  foundation ficaram verdes.

## Proximo Passo

Commitar, mesclar em `master` e remover a worktree se a auditoria final de git
ficar limpa.
