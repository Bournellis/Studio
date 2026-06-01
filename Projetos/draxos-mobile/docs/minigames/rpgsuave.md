# Rpgsuave Bosque

- Status: `INTERNAL_ALPHA_LABS_DEV`
- Mode id: `rpgsuave`
- Slice id: `forest`
- Ruleset: `rpgsuave_forest_ruleset_v0`, version `1`
- Entry action: `open_minigame_shell:rpgsuave`
- Surface: Labs Dev, fullscreen gameplay sem app chrome
- Public CTA: nao
- Release root: `internal-alpha/v0-rpgsuave-visual-upgrade-v1-20260531-809c4dc`
- Ultima atualizacao: `2026-05-31`

## Objetivo

Rpgsuave Bosque existe para testar sensacao de jogo rapido dentro do shell
DraxosMobile. Em Labs Dev, o jogador anda no mapa, para perto de recursos,
coleta, enche o bolso, volta ao bau, deposita e usa crafting local para
upgrades simples. Na publicacao internal alpha, a sessao normal tambem exercita
a ponte server-authoritative de recompensa limitada; falha de rede preserva o
resultado local como pending mutation.

## Publicacao Internal Alpha - Visual Upgrade v1

Publicado em `2026-05-31` para playtest humano interno:

- Portal:
  `https://b5b7a32a.draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Web:
  `https://b5b7a32a.draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Android APK:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-rpgsuave-visual-upgrade-v1-20260531-809c4dc/downloads/draxos-mobile-alpha.apk`
- PC ZIP:
  `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-rpgsuave-visual-upgrade-v1-20260531-809c4dc/downloads/draxos-mobile-alpha.zip`

Validacao concluida: Full gate local limpo, export Android/PC/Web,
upload Storage, pacote Cloudflare Pages, deploy manifest remoto, smoke remoto de
manifest, smoke remoto de artefatos com SHA completo de APK/ZIP e
`internal_alpha_remote_smoke` com auth email, batalha e minigame verdes. O
proximo gate e playtest humano em mobile portrait; nao abrir CTA publico no
Refugio antes dessa leitura.

## Visual Upgrade V1

O pacote Visual Upgrade v1 transforma o Bosque de prototipo em painel para
minigame fullscreen mobile portrait:

- `minigame_shell` e tratado como rota de gameplay fullscreen;
- `RpgsuaveForestScreen` monta mundo, HUD, joystick e mochila dentro do canvas
  do jogo;
- camera logica fica centralizada no personagem e clampada ao mundo virtual
  `960x1400`;
- o mundo continua full-bleed em desktop/web, com HUD preso a margens seguras;
- input player-facing e apenas joystick virtual fixo no canto inferior
  esquerdo;
- teclado, setas, WASD, click-to-move e toque no mapa nao movem o personagem;
- `set_debug_joystick_vector(Vector2)` existe apenas para smoke/teste headless;
- botoes `Mochila`, `Depositar`, `Completar` e `Voltar` ficam dentro da tela do
  minigame;
- `Depositar` so fica ativo dentro do raio do bau;
- dados extras e detalhes dev ficam escondidos em
  `Mochila > Sessao > Detalhes tecnicos`;
- assets do slice sao procedurais em Godot (`_draw()`), sem PNG/JPG/SVG novos.

Componentes client:

- `RpgsuaveForestScreen`: orquestra modelo, sessao, HUD, joystick e sheet;
- `RpgsuaveForestWorldView`: terreno, camera, zonas, recursos, personagem e
  feedback procedural;
- `RpgsuaveVirtualJoystick`: input touch/mouse do joystick;
- `RpgsuaveInventorySheet`: bolso, bau, craft, sessao e detalhes tecnicos.

## Slice Travado

O primeiro slice e `Bosque`, nao open world completo.

Mapa v0:

- casa/local base com bau;
- floresta com galhos, folhas, madeira, pedras, cogumelos, fungos, insetos e resina;
- subzona leve de cemiterio/crematorio simbolico;
- `cinzas_preview`, `ossos_preview` e `po_osso_preview` continuam materiais
  locais/preview; o servidor so aceita o resultado limitado no `complete` e
  converte para recompensas pequenas/auditaveis quando elegivel.

Fora do escopo v0:

- combate;
- inimigos;
- ranking;
- guilda;
- Battle Pass;
- economia premium;
- criacao de personagem separada;
- CTA publico no Refugio.

## Gameplay Local

Controles:

- joystick virtual fixo no canto inferior esquerdo;
- input de teste: `set_debug_joystick_vector(Vector2)`;
- sem teclado, setas, WASD, click-to-move ou toque no mapa como movimento
  player-facing.

Parametros:

- mundo virtual: `960x1400`;
- personagem inicial: `(220, 330)`;
- bau/base: `(220, 250)`;
- velocidade base: `160 px/s`;
- capacidade base: `20.0`;
- penalidade de movimento inicia em `60%` da capacidade;
- velocidade minima carregado: `80 px/s`;
- `trilha_aberta_1` eleva velocidade minima para `95 px/s`;
- coleta exige ficar parado perto do recurso;
- raio de coleta: `40 px`;
- coleta cancela ao mover ou passar de `52 px`;
- bolso cheio bloqueia coleta.

## Recursos Locais

IDs locais iniciais:

`madeira`, `galho`, `folha`, `folha_seca`, `pedra`, `pedra_pequena`,
`cogumelo`, `fungo`, `inseto`, `resina`, `cinzas_preview`, `ossos_preview`,
`po_osso_preview`.

Tempos iniciais:

- `folha`: `0.8s`;
- `galho`: `1.2s`;
- `pedra_pequena`: `1.5s`;
- `madeira`: `2.5s`;
- `pedra`: `3.0s`;
- `cogumelo`, `fungo`, `inseto`, `resina`: `1.5s` a `2.2s`;
- previews de cinzas/ossos/po: `2.5s`.

## Crafting Local

Progressao local do modo:

- `bolsa_simples_1`: capacidade `20 -> 25`;
- `maos_rituais_1`: coleta `10%` mais rapida;
- `trilha_aberta_1`: velocidade minima carregado `80 -> 95 px/s`;
- `fogueira_estavel_1`: converte `galho + folha_seca` em `cinzas_preview`.

Essa progressao nao e saldo de Base/Conta.

## Modos De Execucao

`dev_local`:

- fallback local;
- sem rede;
- resultado e preview local;
- usado para testar sensacao de jogo quando a ponte nao estiver habilitada ou a
  rede falhar antes do start.

`integrated_alpha`:

- ativado nesta publicacao via `draxos_mobile/minigames/rpgsuave/integrated_alpha=true`;
- exige sessao valida e save normal;
- abre sessao por `POST /minigames/session/start`;
- completa por `POST /minigames/session/complete`;
- falha de rede preserva resultado local e pending mutation.

## Reward Bridge

O cliente envia apenas resultado limitado:

- `session_id`;
- `session_seconds`;
- `deposited_items`;
- `activity_score`;
- `ruleset_id`;
- `ruleset_version`.

O servidor valida limites, rejeita adulteracao, aplica clamp de plausibilidade e
converte para recompensa pequena e diaria:

- `energia`;
- `ossos`;
- `xp` pequeno.

Recompensa real sempre passa por RPC `service_role`, idempotencia
`request_id/request_hash` e ledger em `resource_transactions`.

## Arquivos

- Client registry: `modes/boot/ui/minigame_shell_registry.gd`
- Gameplay: `dev/minigames/rpgsuave/rpgsuave_forest_model.gd`
- Tela: `dev/minigames/rpgsuave/rpgsuave_forest_screen.gd`
- Backend domain: `server/functions/_shared/minigame_domain.ts`
- Edge Function: `server/functions/minigames/index.ts`
- Migration: `server/schema/migrations/202605310001_minigame_platform_v0.sql`
- Smokes/tests: `tools/smoke_rpgsuave_forest.gd`, `tests/client/test_rpgsuave_minigame_dev.gd`, `server/tests/minigame_*`
- Visual smokes: `tools/smoke_rpgsuave_visual_layout.gd`
