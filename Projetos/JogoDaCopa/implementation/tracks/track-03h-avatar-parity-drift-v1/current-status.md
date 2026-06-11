# Track 03H - Avatar Parity & Animation Drift Fix V1

- Date: `2026-06-10`
- Branch: `codex/jogodacopa/track03h-avatar-parity-drift-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03h-avatar-parity-drift-v1`
- Status: `COMPLETE`
- Source: playtest humano de Fabio sobre o avatar real da Track 02C-bis

## Goal

Corrigir dois bugs do avatar real sem alterar fisica, forcas, contratos de chute/tap/RMB ou tuning de movimento: bot deve ter paridade visual com o player na cena real e as animacoes nao podem acumular drift de posicao/rotacao.

## Bug 1 Root Cause - Bot Visualmente Em Caixas

A investigacao confirmou que `Superhero_Female_FullBody.gltf` carrega corretamente: o spike pos-import mostra `Armature/Skeleton3D`, 65 bones e meshes `Eyebrows`, `Eyes`, `Superhero_Female`. A cena montada tambem retornava `bot_avatar.debug_has_real_model() == true` e 46 animacoes.

A causa raiz do sintoma era visual/paridade na cena: `FootballBot` herda o corpo primitivo de `FpsCombatant3D`, e apenas `FpsPlayerController` escondia esse `MeshInstance3D`. O bot tinha o avatar real feminino como filho, mas continuava exibindo o capsule/mesh primitivo do combatant, parecendo "caixas" no playtest.

Fix aplicado:

- `FpsCombatant3D` ganhou `set_combatant_body_visible()` e `debug_is_combatant_body_visible()`.
- Player e bot usam o mesmo contrato para esconder o corpo primitivo quando o avatar real esta ativo.
- O teste de cena montada em `football.tscn` agora exige `debug_has_real_model() == true`, `debug_get_animation_count() >= 40` para player/bot e corpo primitivo invisivel em ambos.
- `PlayerAvatar3D` agora emite `push_error` permanente com causa em qualquer falha de load/build do modelo real ou da biblioteca UAL.

## Bug 2 Root Cause - Drift De Animacao

O GLB `UAL1_Standard.glb` tem tracks de `root`/`pelvis` em todos os clipes principais. A inspecao mostrou tracks de posicao em `root` e posicao/rotacao em `pelvis` para `Idle`, `Jog_Fwd`, `Sprint`, `Roll`, `Hit_Chest`, `Push`, `Jump_*`, `Dance` e `Idle_Talking`.

A causa raiz era dupla:

- As animacoes UAL carregadas diretamente permitiam translacao horizontal e yaw de `root`/`pelvis`, deixando a orientacao visual depender da pose do skeleton em vez do node pai logico.
- Clipes nao-loop e transicoes do `AnimationTree` podiam manter a ultima pose/blend aplicada apos dash/hit/chute, acumulando desalinhamento perceptivel entre direcao de movimento e corpo.

Fix aplicado:

- Ao copiar os clipes para a `AnimationLibrary`, `PlayerAvatar3D` zera X/Z de tracks de posicao e yaw de tracks de rotacao em `root`/`pelvis`, preservando Y vertical.
- A library inclui animacao `RESET`.
- Toda troca de estado reseta pose/local transform com `Skeleton3D.reset_bone_poses()`.
- Uma trava runtime remove X/Z e yaw de `root`/`pelvis` apos o avanco do `AnimationTree`, garantindo que o facing venha exclusivamente do `CharacterBody3D` pai.
- Teste novo simula 20 acoes alternadas (`slide`, `kick`, `hit`, `idle`, `strong_kick`, `push`, `flip`, `move`, `emote`, `celebrate`) e exige model/skeleton sem drift local e root/pelvis sem translacao horizontal/yaw dentro da tolerancia.

## Validation Log

- `tools/validate.gd`: PASS, 57 tests, 724 asserts.
- Source integrity: PASS, 26 `.gd/.gdshader` files loaded outside `addons/`.
- Known validation noise: GUT UID/text-path warnings ao carregar testes.

## Delivery

- Register commit: `4adb4d1 docs: register track 03h avatar parity drift`
- Fix commit: `0d9ab43 fix: stabilize real avatars in football scene`
- Next step: playtest de confirmacao avatar/bot + decisao da proxima serie.
