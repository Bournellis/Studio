# DraxosMobile Foundation Hardening V2 - Worktree Audit

- data: `2026-06-01`
- agente: `Codex`
- pacote: `Foundation Hardening V2 - Expansion Enforcement`
- branch integradora: `codex/draxos-mobile/foundation-hardening-v2`
- worktree integradora: fechada apos merge/publicacao
- closeout operacional: `2026-06-01`

## Resultado

Foundation Hardening V2 foi publicado, promovido para `master` e fechado para
playtest funcional. As worktrees limpas do pacote V2, a worktree de hotfix
`v2-login-cors-hotfix` e duas worktrees historicas limpas foram removidas via
`git worktree remove`; as branches foram preservadas.

## Worktrees Fechadas

| Classificacao | Branch | Resultado |
|---|---|---|
| `closed-integrated` | `codex/draxos-mobile/foundation-hardening-v2` | Worktree removida; branch preservada. |
| `closed-integrated` | `codex/draxos-mobile/foundation-hardening-v2-coord-canon-docs` | Worktree removida; branch preservada. |
| `closed-integrated` | `codex/draxos-mobile/foundation-hardening-v2-backend-mode-enforcement` | Worktree removida; branch preservada. |
| `closed-integrated` | `codex/draxos-mobile/foundation-hardening-v2-client-session-enforcement` | Worktree removida; branch preservada. |
| `closed-integrated` | `codex/draxos-mobile/foundation-hardening-v2-validation-security-gates` | Worktree removida; branch preservada. |
| `closed-integrated` | `codex/draxos-mobile/foundation-hardening-v2-data-labs-mode-decisions` | Worktree removida; branch preservada. |
| `closed-integrated` | `codex/draxos-mobile/foundation-hardening-v2-release-ops-keystore` | Worktree removida; branch preservada. |
| `closed-integrated` | `codex/draxos-mobile/v2-login-cors-hotfix` | Worktree removida; branch preservada. |
| `closed-historical` | `codex/draxos-mobile/pve-arena-direction` | Worktree limpa removida; branch preservada para consulta historica. |
| `closed-historical` | `codex/draxos-mobile/rpgsuave-doc` | Worktree limpa removida; branch preservada para consulta historica. |

## Worktrees Antigas Ainda Preservadas

| Classificacao | Branch | Worktree | Motivo |
|---|---|---|---|
| `handoff-needed` | `codex/draxos-mobile/arena-backend` | `D:\Estudio-worktrees\draxos-mobile--codex--arena-backend` | Worktree antiga com estado nao limpo; preservar ate revisao/handoff explicito. |
| `handoff-needed` | `codex/draxos-mobile/arena-client-labs` | `D:\Estudio-worktrees\draxos-mobile--codex--arena-client-labs` | Worktree antiga com estado nao limpo; preservar ate revisao/handoff explicito. |

Estado restante esperado em `git worktree list` apos o closeout:

- `D:\Estudio` em `master`;
- `D:\Estudio-worktrees\draxos-mobile--codex--arena-backend`;
- `D:\Estudio-worktrees\draxos-mobile--codex--arena-client-labs`.

## Nota Operacional

Uma tentativa de remocao da worktree `foundation-expansion-readiness` reportou `Permission denied`, mas o checkout nao permaneceu registrado em `git worktree list` apos `git worktree prune`. Se restar diretorio fisico fora do registro Git, tratar como limpeza manual futura, nao como lane ativa.

Android release signing fica como divida controlada, nao como bloqueio do
playtest funcional: o APK hotfix2 usa `debug_fallback`, e a keystore release
deve ser reaplicada somente antes de distribuicao Android mais ampla, teste de
atualizacao por assinatura ou Play Console.
