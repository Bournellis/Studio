# Track 12 - Current Status

- Status: `DELIVERED`
- Ultima atualizacao: `2026-05-28`
- Branch: `codex/draxos-mobile/track-12-boot-decomposition`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-12-boot-decomposition`

## Resultado

`modes/boot/boot.gd` deixou de concentrar action contract, auth/session/update, fluxos online de superficies, ciclo de batalha/replay e helpers visuais compartilhados. O host agora fica responsavel por shell, busy state, notices, erro visual, navegacao, callbacks e ponte com presenters.

Linha de corte:

- Antes da Track 12: aproximadamente `2525` linhas.
- Depois da Track 12: `1301` linhas.
- Orçamento permanente: no maximo `1500` linhas, coberto por teste.

## Fronteiras Atuais

- Presenters renderizam e criam controles.
- Flows executam orquestracao de conta, sessao, superficies online e batalha.
- `AppShellActionContract` centraliza action ids/prefixos/gates/payload.
- `SurfaceUiHelpers` centraliza helpers visuais compartilhados que ainda precisam ser acessiveis pelo host/presenters.
- Servidor segue autoritativo para batalha, recursos, recompensas, matchmaking e compras.

## Validacao

- GUT client: `103` testes, `1662` asserts.
- `tools/validate.gd`: verde apos a decomposicao.
- `git diff --check`: verde.

## Proximo Passo

Executar walkthrough manual Android, Windows e Web autenticado/preview antes de abrir feature nova. A proxima etapa tecnica pode reduzir ainda mais callbacks dinamicos entre presenters, helpers e host, mas sem mexer em UX ate o walkthrough.
