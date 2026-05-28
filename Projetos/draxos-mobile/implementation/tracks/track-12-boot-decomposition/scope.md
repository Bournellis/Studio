# Track 12 - Boot Decomposition

- Status: `DELIVERED`
- Data: `2026-05-28`
- Branch: `codex/draxos-mobile/track-12-boot-decomposition`
- Base: `codex/draxos-mobile/track-11-consolidation`

## Objetivo

Transformar `modes/boot/boot.gd` em um app shell fino sem mudar produto, UX, backend, economia, schema, rotas, textos ou cenas `.tscn`.

## Entregas

- `modes/boot/ui/app_shell_action_contract.gd`: ids, prefixos, payloads, replay/update gate e classificacao de action.
- `modes/boot/flows/account_session_flow.gd`: guest, login, signup, refresh, reset, save selection/creation e update/runtime checks.
- `modes/boot/flows/surface_action_flow.gd`: Base, Social, Competition e Shop online, sempre delegando autoridade ao servidor.
- `modes/boot/flows/battle_lifecycle_flow.gd`: request/latest/history/replay/skip/summary/logs sem simulacao client-side.
- `modes/boot/surfaces/surface_ui_helpers.gd`: facade de helpers visuais compartilhados pelos presenters.
- Guardas em `tests/client/test_boot_mobile_ui.gd` para manter `boot.gd` abaixo de 1500 linhas, ids centralizados, presenters sem rede/mutacao direta de sessao e flows sem criacao de controles visuais.

## Fora Do Escopo

- Feature nova, tuning numerico, mudanca de economia, schema Supabase, Edge Functions, assets finais, publicacao de builds ou edicao manual de `.tscn`.
