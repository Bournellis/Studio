# Track 03K - Animation Pose Restore V2

- Data: `2026-06-11`
- Status: `FIX_VALIDATED`
- Branch: `codex/jogodacopa/track03k-animation-pose-restore-v2`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03k-animation-pose-restore-v2`
- Marker alvo: `JOGO_DA_COPA_TRACK_03K_ANIMATION_POSE_RESTORE_V2_COMPLETE`

## Objetivo

Restaurar a pose base e a vida das animacoes reais do avatar apos o hotfix da 03H deixar o personagem deitado/parcialmente dentro do chao no playtest humano.

## Causa Raiz

A 03H tentou remover drift editando keyframes de root motion manualmente. Esse strip manipulava posicao e quaternion de bones importados (`root` e `pelvis`), zerando componentes em vez de preservar a pose base do rig. Na pratica, a rotacao base do `root` podia ser substituida/zerada e componentes de posicao da pose ficavam incorretos, deitando e afundando o modelo.

## Antes / Depois

Antes:

- Constante: `ROOT_MOTION_BONES = [&"root", &"pelvis"]`.
- `_strip_root_motion()` editava valores de keyframes.
- Lock deferred em runtime continuava zerando X/Z e yaw em `root` e `pelvis`.

Depois:

- Constante: `ROOT_MOTION_BONE = &"root"`.
- Cada clipe UAL duplicado remove tracks completas cujo path aponta para `:root`.
- Nenhum keyframe e reescrito.
- `pelvis` e todos os demais bones permanecem 100% originais.
- `_reset_real_model_pose()` permanece na troca de estado, mas sem lock manual de bones.

## Teste Primeiro

Teste novo:

- `test_real_avatar_idle_pose_stays_upright_after_one_full_loop`

Falha confirmada antes do fix:

- `pelvis.y = 0.0`, abaixo da tolerancia minima de `0.5`.
- `spine_03` e `hand_l` abaixo da base local do avatar.
- Validou o sintoma de personagem enterrado/deitado.

## Guardas Permanentes

- A guarda de drift continua cobrindo estabilidade de `model_instance` e `Skeleton3D` apos uma sequencia de acoes.
- Os clipes UAL relevantes nao podem manter tracks apontando para o bone `root`.
- `Jog_Fwd` deve preservar keys nao-uniformes de `pelvis`, garantindo animacao viva.

## Validacao

- Teste focado de pose: PASS, `1/1`, `23` asserts.
- Teste focado de drift/root/pelvis: PASS, `1/1`, `96` asserts.
- `tools/validate.gd`: PASS, source integrity `27` `.gd/.gdshader` files, `59/59` tests, `733` asserts.

## Proximo Passo

Playtest de Fabio para confirmar pose e vida da animacao. Teste automatizado cobre drift e regressao objetiva, mas o juiz final de qualidade de animacao e o olho humano.
