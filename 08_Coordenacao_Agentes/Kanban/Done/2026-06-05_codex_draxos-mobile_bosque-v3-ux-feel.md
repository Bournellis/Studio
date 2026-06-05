# Done - DraxosMobile Bosque v3 UX/Feel

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/bosque-v3-ux-feel`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-v3-ux-feel`
- status: `IMPLEMENTED_LOCAL_PENDING_PUBLICATION`
- remote publication: approved by Fabio in-thread for final main URL publication

## Objetivo

Fechar o gate de playtest OK do Technical Hardening e entregar Bosque v3 UX/Feel: colisao/spawn mais confiavel, feedback visual e textual mais claro, resumo de visita melhor, sessao/resync player-facing e landmarks leves sem expandir Openworld alem do Bosque.

## Entregue Localmente

- `DMOB-D074` tratado como decisao operacional: playtest do Technical Hardening ficou OK e o proximo pacote escolhido e Bosque v3 UX/Feel.
- Resource node `node_inseto_01` reposicionado para fora de bloqueadores; arvores/pedras bloqueantes tiveram area de colisao reduzida levemente para diminuir falso positivo de spawn/contato.
- Teste de ruleset garante que resource nodes fiquem fora de bloqueadores e bordas perigosas.
- Bosque ganhou estados visuais de proximidade/coleta, marcadores de pickup, diferenca visual entre bloqueadores e decoracao, glow de fogueira e landmarks procedurais nao bloqueantes.
- HUD, inventory sheet, deposito, craft, resumo de visita e mensagens de sessao/resync ficaram player-facing, com menos texto tecnico.
- Deposito agora exige estar perto do bau e ter itens no bolso; craft informa pronto/faltante de forma legivel.

## Validacao Local Ja Executada

- `git diff --check`: PASS.
- `npx -y deno test --allow-read server/tests/openworld_ruleset_definition_test.ts`: PASS, 5 tests.
- `npx -y deno check server/tests/openworld_ruleset_definition_test.ts`: PASS.
- `Godot --headless --path . -s res://tools/smoke_openworld_forest.gd`: PASS.
- `Godot --headless --path . -s res://tools/smoke_modes_visual_layout.gd`: PASS.
- `Godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`: PASS, 226 tests.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile FullLocal -NoProjectWrites`: BLOCKED only in `DatabaseLocal`; Docker Desktop/Supabase local is not running (`127.0.0.1:54321/54322` refused, Docker pipe missing). DocsOnly, ServerQuick, ClientQuick, ModePlatform and ReleaseDryRun stages inside the same run passed before the DatabaseLocal failures.

## Pendente Nesta Entrega

- Commitar e mergear ao `master`.
- Publicar via `publish_internal_alpha.ps1 -Mode FullPublish -ReleaseRoot <root> -ConfirmRemoteMutation`.
- Atualizar fallback/docs/guards com release root, hashes e preview reais da publicacao.
- Rodar validacao remota contra `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
