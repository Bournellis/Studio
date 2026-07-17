# Runbook de pacote e publicação — JogoDaCopa

## Metadata

- status: living
- authority: runbook
- last_verified: 2026-07-16
- review_when: presets, limites de pacote ou processo de publicação mudarem
- supersedes: publication-readiness cumulativo anterior ao cutover v2
- superseded_by: none

Este documento governa o processo, não a release atual. Pacotes, URLs, tentativas, rollbacks e aprovações vivem somente em `release-history.md`.

## Pacote local

1. Execute import headless em worktree nova.
2. Execute `tools/validate.gd --profile=full` com árvore rastreada estável.
3. Gere export Web single-threaded local.
4. Execute `tools/publish_web.ps1 -Mode Package`; nunca use modo de publicação automática em fechamento técnico.
5. Confirme limites de asset e tamanho comprimido.
6. Sirva o pacote por HTTP local e faça smoke no Chrome.
7. Registre evidência e resultado no card local.

## Gates

- Boot, menu, partida, bola, SUPER, gol, pause e resultado devem permanecer funcionais.
- Chrome local não pode registrar erro de página/console nem hitch no primeiro minuto.
- Cena noturna exige contrato de `WorldEnvironment` e luma do céu abaixo de 90/255.
- UI alterada exige clique real e capturas em 1920x1080, 1366x768 e 1280x720.
- Feel, câmera, áudio e visual permanecem gates humanos.

## Autoridade e hard stops

Publicação, domínio, Cloudflare, remoto e promoção de release exigem autorização e execução de Fabio. O agente pode produzir pacote local e evidência; não publica, não confirma baseline humana e não altera a linhagem sem um evento real.
