# DraxosMobile Mode Catalog V1

- Status: `VIVO`
- Contract: `MINIGAME_PLATFORM_V1`
- API surface: `/modes`
- Client route/action: `mode_shell`, `open_mode_shell:<mode_id>`
- Registry source: `mode_registry`
- Descriptor source: `data/definitions/modes/<mode_id>/metadata.json`
- Placeholder source: `data/definitions/modes/<mode_id>/placeholder.json`

Este catalogo substitui o registro centrado em `rpgsuave/forest`. A plataforma continua sendo chamada de Minigame Platform por historico de arquitetura, mas o produto agora trata os pilares jogaveis como **modos oficiais** em pe de igualdade.

## Modos Oficiais

| mode_id | Player-facing entry | Default slice | Status V1 | Surface | Build ownership | Economia |
| --- | --- | --- | --- | --- | --- | --- |
| `basebuilder` | Refugio/Base | `refugio` | `active` | Refugio/Base atuais | Base, estruturas, crafting de base e upgrades | Usa endpoints core de Base; pode receber/consumir recursos compartilhados |
| `autobattler` | Arena PVE | `pve_arena` | `active` | Arena PVE atual | Instrumento, Doutrina, Familiar, spells, potions e Preparacao interna | Usa endpoints `arena/pve/*`, battle rewards e ledger existentes |
| `openworld` | Bosque | `forest` | `active` (`internal_alpha`) | Fullscreen `mode_shell` via `open_mode_shell:openworld` | Bosque com snapshot remoto + Reward Bridge limitado | Pode emitir recompensas pequenas apenas via snapshot validado por RPC, idempotencia e ledger |
| `towerdefense` | Oculto | `tbd` | `planned_disabled` | Sem entrada player-facing | Build propria futura: torre central, spells, pets e upgrades | Sem recompensa ate contrato proprio |
| `cardgame` | Oculto | `tbd` | `planned_disabled` | Sem entrada player-facing | Build propria futura; sem relacao mecanica com o projeto Steam | Sem recompensa ate contrato proprio |

## Descriptors Declarativos

Cada modo oficial tem uma pasta em `data/definitions/modes/<mode_id>/` com:

- `metadata.json`: identidade, status, route/action, ruleset pointer,
  ownership, docs e freeze.
- `placeholder.json`: reserva nao jogavel para futuros slices. Este arquivo deve
  manter `playable=false`, `launchable=false` e `reward_enabled=false`.

O registry client (`modes/boot/ui/mode_shell_registry.gd`) expoe os caminhos dos
descriptors para validacao local. Os descriptors desta lane nao adicionam
gameplay, tuning, rewards, backend, schema ou publicacao.

Enforcement estrito:

- `tools/mode_definitions/schema.ts` define o schema aceito.
- `tools/mode_definitions/scaffold_mode.ts` gera scaffolds futuros em modo
  dry-run por padrao.
- `server/tests/mode_definitions_schema_test.ts` bloqueia campos extras,
  diretorios nao aprovados, placeholders jogaveis e decision packs sem freeze.
- `tools/validate_mode_definitions.ps1` roda o pacote local de validacao dos
  descriptors.

Um novo modo ou slice nao entra no catalogo apenas por criar JSON. Primeiro
precisa de decision pack, contrato vivo, update de registry/ruleset e aprovacao
humana.

## Entradas Player-Facing Diretas

Para V1 Internal Alpha:

- Refugio/Base permanece a superficie principal de base e estruturas.
- Arena PVE abre diretamente o loop Autobattler; a Preparacao vive dentro de Arena PVE abaixo de `Iniciar Arena PVE`.
- Bosque abre diretamente `open_mode_shell:openworld`.
- Towerdefense e Cardgame permanecem no registry tecnico, mas ficam ocultos para o player ate pacote jogavel aprovado.

O shell nao deve expor uma tela/rota/menu `mode_hub` player-facing. Um modo so
pode virar entrada publica direta quando passar por:

- descriptor e doc vivos;
- design contract vivo;
- row completa em `mode_registry`;
- ruleset versionado;
- `mode_limit_policies`;
- disable/rollback testado;
- admin/ops funcional;
- telemetria `mode_analytics_v1`;
- Reward Bridge com ledger, quando emitir recursos;
- bloqueio de reward real no `progression_lab`;
- smoke mobile portrait;
- GUT client, backend tests e Full validation;
- aprovacao humana registrada em handoff/status.

## Decisoes Travadas

- `rpgsuave` foi renomeado de verdade para `openworld`.
- O primeiro slice do Openworld e `openworld/forest`; a entrada player-facing direta e `Bosque`.
- `openworld/forest` usa `openworld_forest_ruleset_v1`; v0 fica apenas historico de prototipo local.
- Oficial aqui significa `mode_registry.status=active` no canal `internal_alpha`, nao publicacao publica.
- `/minigames` nao e contrato ativo em V1.
- `open_minigame_shell` e `minigame_shell` nao sao contrato ativo em V1.
- Cardgame do DraxosMobile compartilha lore com outros projetos, mas nao herda mecanicas do `draxos-roguelike-cardgame`.
- Towerdefense futuro usa fantasia de heroi/mago em torre central estatica contra hordas.

## Decision Packs

- `docs/minigames/openworld-decision-pack.md`: Openworld fica limitado ao Bosque
  atual; expansao de mapa, combate, risco ou rewards exige pacote proprio.
- `docs/minigames/towerdefense-decision-pack.md`: Towerdefense fica
  planned/disabled e oculto ao player ate contrato de torre/hordas/rewards.
- `docs/minigames/cardgame-decision-pack.md`: Cardgame fica planned/disabled,
  oculto ao player e sem heranca mecanica do projeto Steam.
