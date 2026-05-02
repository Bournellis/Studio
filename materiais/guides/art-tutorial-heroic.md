# Tutorial de Arte — Personagem Heroic + Martelo

> Historical Unity tutorial. This file records the completed legacy art experiment and should not be used as the active Godot production workflow. For current asset work, follow `materiais/guides/art-pipeline.md`, `Projetos/rpg-isometrico/docs/platform-art-and-export-guidance.md`, and the active track docs.

## O que este documento é

Um guia passo a passo para produzir o primeiro personagem real do jogo: o guerreiro Heroic segurando o Martelo. O objetivo é substituir os placeholders de primitivas Unity por um personagem com modelo 3D real, rig humanoid, toon shader e animações funcionando na câmera do jogo.

Este documento foi criado para ser seguido em múltiplas sessões. O rastreador abaixo é a fonte de verdade do progresso. Atualize-o ao terminar cada estágio.

---

## Como retomar uma sessão

Se você está voltando ao tutorial depois de uma pausa e quer ajuda do Claude, use o helper único:

> "Leia `docs/agents/agent-claude-helper.md` e depois `docs/guides/art-tutorial-heroic.md`. Quero continuar o tutorial de arte do Heroic."

O helper vai ler o rastreador de progresso abaixo, entender onde você parou, e continuar desse ponto.

---

## Rastreador de Progresso

Atualize esta tabela ao finalizar cada estágio. Anote também a data e qualquer observação relevante.

| Estágio | Título | Status | Data | Notas |
| --- | --- | --- | --- | --- |
| 1 | Gerar modelo no Meshy | ✅ Completo | 2026-04-15 | Gerado no Tripo3D (alternativa ao Meshy). Corpo + Martelo em FBX. |
| 2 | Limpeza no Blender | ✅ Completo | 2026-04-16 | Corpo: escala 2m, pivot na base dos pés, rotação aplicada, normais recalculadas. Martelo: escala 0.6, pivot no cabo, orientação correta (cabeça para cima). |
| 3 | Rig e animações no Mixamo | ✅ Completo | 2026-04-16 | Rig humanoid gerado, personagem em T-pose baixado com skin. 9 animações baixadas sem skin em FBX for Unity. |
| 4 | Importação e integração no Unity | ✅ Completo | 2026-04-16 | FBXs importados sem erros. Avatar humanoid verde. 9 animações configuradas. Toon shader aplicado (cores canônicas). Rotation X=90 corrigido no Unity. Personagem posicionado Y=1 na Arena_AForja. Prefab salvo como Character_Heroic_Real. |
| 5 | Validação e substituição do placeholder | ⬜ Não iniciado | — | — |

**Legenda:** ⬜ Não iniciado · 🔄 Em andamento · ✅ Completo · ⚠️ Completo com ressalvas

---

## O que vamos produzir

Ao final dos 5 estágios, o projeto terá:

- `Character_Heroic.prefab` substituído por um personagem com modelo real
- `Martelo.prefab` — a arma como objeto separado preso ao bone da mão
- Toon shader com as cores do Heroic (dourados/âmbares) aplicado
- Animações funcionando: Idle, Walk, Run, BasicAttack 1/2/3, Dash, Death, HitReaction
- Personagem validado na câmera isométrica real do jogo

**Nível alvo:** placeholder funcional. Reconhecível como um guerreiro com martelo, sem erros visuais graves, pronto para testes de gameplay. Não é arte final.

---

## Pré-requisitos gerais

Antes de começar, você precisa de contas nestas ferramentas gratuitas:

| Ferramenta | Para que serve | Onde criar conta |
| --- | --- | --- |
| **Meshy** | Gerar o modelo 3D com IA | [meshy.ai](https://www.meshy.ai) — gratuito, 3 créditos/mês |
| **Mixamo** | Rig automático + biblioteca de animações | [mixamo.com](https://www.mixamo.com) — gratuito com conta Adobe |
| **Blender** | Limpeza e ajuste do modelo | ✅ Já instalado |

---

## Estágio 1 — Gerar o Modelo no Meshy

### Objetivo

Gerar dois modelos 3D separados com IA: o corpo do guerreiro Heroic e o Martelo. Os arquivos serão baixados e usados no Estágio 2.

### Por que dois objetos separados?

O personagem e a arma são objetos distintos no jogo. O corpo vai ser rigado pelo Mixamo. O Martelo vai ser importado separado e preso ao bone da mão no Unity. Isso segue o pipeline correto e permite trocar a arma no futuro sem mexer no personagem.

### Passos — Corpo do Guerreiro

1. Acesse [meshy.ai](https://www.meshy.ai) e faça login.

2. Escolha o modo **Text to 3D** (ou "Text to Model").

3. Use este prompt exato como ponto de partida:

   ```
   Low-poly stylized dark fantasy warrior, heavy armor, humanoid, T-pose, 
   game-ready character, no weapons, dark gold and purple color scheme, 
   stone-gray accent, fantasy RPG style
   ```

4. Configure as opções:
   - **Style:** Stylized (não Realistic)
   - **Topology:** Low Poly se disponível
   - Gere **4 variações** e escolha a que tiver a silhueta mais limpa: corpo claramente humanoid, sem partes fundidas, postura próxima de T-pose ou A-pose.

5. **Critérios de escolha** — escolha a variação que tiver:
   - Cabeça, tronco, braços e pernas claramente separados visualmente
   - Braços afastados do corpo (não grudados nas laterais)
   - Proporções legíveis em visão isométrica (não muito fino, não muito detalhado)
   - Evite modelos com capa ou manto longo — dificultam o rig

6. Após escolher, clique em **Refine** (se disponível) para melhorar a qualidade da textura. Aguarde o processamento.

7. **Baixe o arquivo** no formato **FBX** ou **OBJ** (FBX é preferível). Salve em uma pasta local chamada `Arte/Heroic/Body/`.

### Passos — Martelo

1. Abra uma nova geração no Meshy.

2. Use este prompt:

   ```
   Low-poly stylized fantasy war hammer, ancient stone head, magical runes, 
   dark gold and stone gray, game-ready prop, no character, fantasy RPG style
   ```

3. Gere variações e escolha o modelo com:
   - Cabo (handle) e cabeça (head) claramente distintos
   - Proporções que leriam bem em câmera isométrica — a cabeça do martelo deve ser grande e visível
   - Silhueta simples e reconhecível

4. **Baixe o arquivo** em FBX ou OBJ. Salve em `Arte/Heroic/Hammer/`.

### Validação do Estágio 1

Antes de marcar como completo, confirme:

- [ ] Arquivo do corpo baixado em `Arte/Heroic/Body/`
- [ ] Arquivo do martelo baixado em `Arte/Heroic/Hammer/`
- [ ] O modelo do corpo tem silhueta humanoid legível
- [ ] O martelo tem cabeça e cabo distintos

### Ao terminar

Atualize o rastreador de progresso no topo deste documento:
- Mude o status do Estágio 1 para ✅ Completo (ou ⚠️ com ressalvas se tiver dúvidas)
- Anote a data
- Anote qualquer observação: qual variação você escolheu, o que gostou ou não no modelo

---

## Estágio 2 — Limpeza no Blender

### Objetivo

Preparar os dois modelos para as próximas etapas. O corpo precisa estar em T-pose com escala correta para o Mixamo funcionar. O Martelo precisa ter o pivot no lugar certo para se encaixar na mão.

### O que você NÃO vai fazer neste estágio

Não precisa modelar, recriar geometria ou fazer arte. O trabalho é técnico e corretivo. Se algo não estiver perfeito, está bem — estamos produzindo um placeholder.

---

### Parte A — Preparar o Corpo

#### 1. Importar o modelo

1. Abra o Blender.
2. Vá em **File → Import → FBX** (ou OBJ, dependendo do formato baixado).
3. Navegue até `Arte/Heroic/Body/` e abra o arquivo.

**Se o modelo aparecer gigante ou minúsculo:**
- Selecione o objeto (clique com botão esquerdo)
- No painel lateral (tecla **N** para abrir), veja a aba **Item**
- Ajuste a escala manualmente no campo Scale, ou use **S** para escalar interativamente

#### 2. Verificar e corrigir a escala

O personagem deve ter aproximadamente **2 metros de altura** no Blender (2 unidades no eixo Z).

1. Selecione o objeto
2. Olhe o painel **N → Item → Dimensions**
3. O valor Z (altura) deve ser próximo de **2.0**
4. Se não estiver: pressione **S**, depois **Z**, depois digite o número de escala necessário
5. Após ajustar a escala visual, aplique a escala definitivamente: **Ctrl+A → Scale**. Isso é obrigatório antes de exportar.

#### 3. Verificar o pivot

O ponto de origem (pivot) do personagem deve estar no chão, entre os pés.

1. No modo **Object Mode**, selecione o personagem
2. Pressione **Shift+S → Cursor to Selected** para ver onde está o pivot
3. Se o pivot estiver no centro da mesh ou fora do lugar:
   - Vá em **Object → Set Origin → Origin to Geometry** como ponto de partida
   - Depois ajuste manualmente: mova o **3D Cursor** para o ponto entre os pés com **Shift+clique direito** e aplique **Object → Set Origin → Origin to 3D Cursor**

#### 4. Verificar e corrigir a pose

O Mixamo funciona melhor com o personagem em **A-pose** (braços levemente abertos, 45°) ou **T-pose** (braços completamente horizontais).

- Se o modelo vier com os braços colados ao corpo: você vai precisar entrar no **Edit Mode** (Tab) e rotar manualmente os vértices dos braços para afastá-los. Selecione os vértices de um braço, use **R** para rotar.
- Se os braços já estiverem razoavelmente afastados (A-pose ou T-pose aproximada): está bom o suficiente para o Mixamo.

**Dica:** O Mixamo é tolerante. Uma pose próxima de A-pose funciona. Não precisa ser perfeita.

#### 5. Verificar normais

Normais invertidas fazem partes do modelo aparecerem pretas ou transparentes.

1. Entre no **Edit Mode** (Tab)
2. Vá em **Overlay** (botão no canto superior direito da viewport) e ative **Face Orientation**
3. Faces azuis = normais corretas. Faces vermelhas = invertidas.
4. Se houver faces vermelhas: selecione tudo (**A**), depois **Mesh → Normals → Recalculate Outside** (ou **Alt+N → Recalculate Outside**)

#### 6. Exportar o corpo

1. **File → Export → FBX**
2. Nas opções de export (painel à direita):
   - **Scale:** 1.0
   - **Apply Unit:** ativado
   - **Apply Transform:** ativado
   - **Mesh:** ativado
   - **Armature:** desativado (ainda não tem rig)
3. Salve como `Arte/Heroic/Body/heroic_body_clean.fbx`

---

### Parte B — Preparar o Martelo

O martelo não precisa de rig, então o processo é mais simples.

#### 1. Importar e verificar escala

1. **File → Import → FBX** (ou OBJ) — arquivo do martelo
2. O martelo deve ter uma escala que faça sentido relativo ao personagem. Abra as duas cenas ao mesmo tempo se quiser comparar.
3. Uma boa referência: a cabeça do martelo deve ter aproximadamente **0.5 a 0.8 unidades** de largura.
4. Aplique a escala: **Ctrl+A → Scale**

#### 2. Corrigir o pivot

O pivot do martelo deve estar no **ponto onde a mão segura o cabo** — aproximadamente no meio do cabo, levemente para a parte de cima.

1. No **Edit Mode**, identifique visualmente onde a mão seguraria
2. No **Object Mode**, mova o **3D Cursor** para esse ponto com **Shift+clique direito**
3. **Object → Set Origin → Origin to 3D Cursor**

Isso é importante: quando o Unity prender o martelo ao bone da mão, o pivot será o ponto de encaixe.

#### 3. Orientação

O martelo deve estar orientado para que, quando preso ao bone da mão no Unity:
- O cabo aponte para baixo
- A cabeça aponte para cima

Se precisar rotar: **R** para rotar, **X/Y/Z** para restringir ao eixo. Aplique a rotação depois: **Ctrl+A → Rotation**.

#### 4. Exportar o martelo

1. **File → Export → FBX**
2. Mesmas opções do corpo (Scale 1.0, Apply Unit e Transform ativos, sem Armature)
3. Salve como `Arte/Heroic/Hammer/martelo_clean.fbx`

---

### Validação do Estágio 2

- [ ] `heroic_body_clean.fbx` exportado — altura ~2 unidades, pivot no chão entre os pés
- [ ] Braços razoavelmente afastados do corpo (A-pose ou T-pose)
- [ ] Normais sem faces vermelhas
- [ ] `martelo_clean.fbx` exportado — pivot no ponto de empunhadura
- [ ] Escala do martelo plausível em relação ao corpo

### Ao terminar

Atualize o rastreador de progresso. Se algo não ficou perfeito mas está funcional, marque com ⚠️ e anote o que ficou faltando — pode ser corrigido depois sem travar o processo.

---

## Estágio 3 — Rig e Animações no Mixamo

### Objetivo

Usar o Mixamo para criar um rig humanoid automático no corpo do Heroic, e baixar o conjunto de animações que o personagem precisa.

### Por que o Mixamo?

O Mixamo faz o rig humanoid automaticamente, e o rig que ele gera é compatível com o sistema Humanoid do Unity — o mesmo usado pelos Animator Controllers já existentes no projeto. Isso significa que as animações baixadas no Mixamo podem ser retargetadas para qualquer personagem com rig humanoid.

---

### Parte A — Rig do Personagem

1. Acesse [mixamo.com](https://www.mixamo.com) e faça login com sua conta Adobe.

2. Clique em **Upload Character** (botão no topo da interface).

3. Selecione o arquivo `heroic_body_clean.fbx`.

4. O Mixamo vai exibir a interface de colocação de marcadores. Você precisa posicionar **5 pontos** no modelo:

   | Marcador | Onde colocar |
   | --- | --- |
   | **Chin** (queixo) | Na ponta inferior do rosto/cabeça |
   | **Left Wrist** (pulso esquerdo) | No final do braço esquerdo |
   | **Right Wrist** (pulso direito) | No final do braço direito |
   | **Left Elbow** (cotovelo esquerdo) | No meio do braço esquerdo |
   | **Right Elbow** (cotovelo direito) | No meio do braço direito |
   | **Groin** (virilha) | Entre as pernas, na junção do tronco |

   **Dica:** Use a visão frontal para posicionar. Arraste cada marcador com o mouse até o ponto correto.

5. Ative a opção **Use Symmetry** se o modelo for simétrico (geralmente é).

6. Clique em **Next** e aguarde o processamento. O Mixamo vai gerar o rig e mostrar uma prévia com a animação padrão.

7. **Verifique a prévia:**
   - O personagem deve se mover de forma razoável na animação padrão
   - Os braços não devem atravessar o corpo
   - As pernas devem dobrar nos joelhos corretamente
   - Se algo estiver muito errado (braços no lugar errado, modelo deformado), clique em **Back** e reajuste os marcadores

8. Se a prévia estiver aceitável, clique em **Next** para confirmar.

---

### Parte B — Baixar o Personagem Rigado

Antes de baixar animações, baixe o personagem com o rig aplicado. Esse arquivo será usado como base no Unity.

1. Com a animação padrão tocando, clique em **Download** (canto superior direito).

2. Configurações de download:
   - **Format:** FBX for Unity
   - **Pose:** T-pose
   - **Frames per Second:** 30
   - **Skin:** With Skin ✅ (importante — inclui o mesh com o rig)

3. Salve como `Arte/Heroic/Body/heroic_body_rigged.fbx`

---

### Parte C — Baixar as Animações

Agora você vai baixar cada animação separadamente. Para cada uma, **não precisa fazer upload de novo** — o Mixamo mantém o personagem da sessão.

A lista abaixo indica o nome no Mixamo e como o arquivo deve ser salvo.

**Como baixar cada animação:**
1. No painel esquerdo, pesquise pelo nome sugerido
2. Clique na animação para ver a prévia no seu personagem
3. Ajuste a velocidade se necessário (slider "Speed")
4. Clique em **Download**
5. Configurações: **Format:** FBX for Unity · **FPS:** 30 · **Skin:** Without Skin (animações não precisam do mesh)

| Animação no jogo | Buscar no Mixamo por | Arquivo a salvar |
| --- | --- | --- |
| Idle | "Breathing Idle" ou "Idle" | `Anim_Idle.fbx` |
| Walk | "Walking" (sem corrida) | `Anim_Walk.fbx` |
| Run | "Running" | `Anim_Run.fbx` |
| BasicAttack 1 | "Two Hand Melee Attack 1" ou "Slash" | `Anim_BasicAttack1.fbx` |
| BasicAttack 2 | "Two Hand Melee Attack 2" ou "Spin Attack" | `Anim_BasicAttack2.fbx` |
| BasicAttack 3 | "Two Hand Melee Attack 3" ou "Overhead Attack" | `Anim_BasicAttack3.fbx` |
| Dash | "Dash Forward" ou "Dodge Roll" | `Anim_Dash.fbx` |
| Death | "Dying" ou "Death" | `Anim_Death.fbx` |
| HitReaction | "Hit Reaction" ou "Getting Hit" | `Anim_HitReaction.fbx` |

**Dicas de seleção:**
- Para os BasicAttacks, escolha animações que usem os dois braços (two-handed) — o Martelo é uma arma de duas mãos
- Para o Dash, prefira algo rápido e lateral, não uma rolada no chão
- Para o Death, uma queda para frente ou para o lado funciona bem

Salve todos os arquivos em `Arte/Heroic/Animations/`.

---

### Validação do Estágio 3

- [ ] `heroic_body_rigged.fbx` baixado — personagem com rig, em T-pose
- [ ] 9 animações baixadas em `Arte/Heroic/Animations/`
- [ ] Cada animação foi previamente visualizada no Mixamo no personagem Heroic
- [ ] As animações de BasicAttack usam os dois braços

### Ao terminar

Atualize o rastreador. Anote quais animações do Mixamo você escolheu para cada slot — isso facilita substituir no futuro se quiser buscar uma alternativa.

---

## Estágio 4 — Importação e Integração no Unity

### Objetivo

Importar o personagem e as animações no Unity, aplicar o toon shader com as cores do Heroic, configurar o Animator Controller e criar o prefab final com o Martelo preso na mão.

---

### Parte A — Importar os Arquivos no Unity

1. Abra o projeto no Unity Editor.

2. No **Project window**, navegue até:
   `Assets/Game/Content/Phase3/Characters/Generated/`

3. Crie uma subpasta chamada `Meshes` dentro de `Generated/`.

4. Arraste os seguintes arquivos do Windows Explorer para essa pasta no Unity:
   - `heroic_body_rigged.fbx`
   - `martelo_clean.fbx`
   - Todos os 9 arquivos `.fbx` de `Arte/Heroic/Animations/`

5. Aguarde o Unity processar os imports.

---

### Parte B — Configurar o Avatar Humanoid (Personagem)

Este passo é crítico. O Unity precisa reconhecer o rig do Mixamo como Humanoid para poder usar as animações.

1. No Project window, clique no arquivo `heroic_body_rigged.fbx`.

2. No Inspector, clique na aba **Rig**.

3. Mude **Animation Type** de "Generic" para **Humanoid**.

4. Clique em **Configure...** — o Unity vai abrir a tela de configuração do Avatar.

5. Verifique se os ossos estão mapeados corretamente. O Mixamo gera nomes padrão que o Unity normalmente reconhece automaticamente. Os campos devem estar verdes.
   - Se algum campo estiver vermelho: clique nele e selecione o bone correspondente na lista

6. Clique em **Apply** para confirmar o Avatar.

7. Ainda no Inspector do FBX, vá na aba **Materials** e clique em **Extract Materials** → escolha a pasta `Assets/Game/Content/Phase3/Characters/Generated/Materials/` para extrair os materiais gerados pelo Mixamo.

---

### Parte C — Configurar as Animações

Para cada arquivo de animação importado:

1. Clique no arquivo de animação no Project window (ex: `Anim_Idle.fbx`)
2. No Inspector → aba **Rig**: mude para **Humanoid** e em **Avatar Definition** selecione **Copy From Other Avatar** → aponte para o Avatar criado no passo anterior (`heroic_body_riggedAvatar`)
3. Clique na aba **Animation**
4. Marque **Loop Time** para as animações cíclicas: Idle, Walk, Run
5. Para BasicAttack 1/2/3, Dash, Death, HitReaction: **Loop Time** desativado
6. Clique em **Apply**

---

### Parte D — Aplicar o Toon Shader

1. No Project window, selecione o material extraído do personagem (dentro de `Generated/Materials/`)

2. No Inspector, mude o **Shader** para:
   `Game/ToonRimCharacter` (o shader customizado já existente no projeto)

3. Configure as cores conforme o vocabulário visual do Heroic:

   | Propriedade | Valor |
   | --- | --- |
   | Base Color | `#D6941F` (âmbar dourado) |
   | Shadow Color | `#381F1F` (marrom escuro) |
   | Rim Color | `#FFD770` (amarelo-ouro brilhante) |
   | Rim Intensity | 1.0 |
   | Rim Power | 3.4 |

   **Nota:** Esses valores já estão no `CharacterProfile_Heroic.asset` existente — são os valores canônicos.

4. Para o Martelo, crie um novo material:
   - Clique com botão direito em `Generated/Materials/` → **Create → Material**
   - Nome: `Mat_MartEloCleaned`
   - Shader: `Game/ToonRimCharacter`
   - Base Color: `#8B7355` (pedra acinzentada com tom quente)
   - Rim Color: `#FFD770` (mesmo rim do personagem — coerência visual)

---

### Parte E — Montar o Prefab

1. No **Hierarchy** (cena aberta — use a Arena_AForja ou crie uma cena temporária), arraste o `heroic_body_rigged` do Project window para a cena.

2. Encontre o bone da mão direita na hierarquia do personagem. Será algo como `mixamorig:RightHand` ou similar.

3. Arraste o `martelo_clean` da pasta Meshes para dentro do bone da mão na hierarquia — ele deve virar filho do bone.

4. Ajuste **Position** e **Rotation** do Martelo no Inspector até ele parecer segurado naturalmente. Lembre-se de verificar na câmera isométrica:
   - Position Y: eleve levemente para a mão ficar no meio do cabo
   - Rotation: ajuste até a cabeça do martelo apontar para cima

5. Selecione o objeto raiz do personagem na hierarquia.

6. No Inspector, clique em **Add Component** → pesquise e adicione o **Animator**.

7. No campo **Controller** do Animator, arraste o `AC_Heroic` (já existente em `Generated/Controllers/`).

8. Com o personagem configurado na cena, no Project window clique com botão direito → **Create → Prefab** e arraste o personagem da cena para essa área — ou arraste o personagem da hierarquia para a pasta `Generated/Prefabs/` para criar o prefab.

9. Nomeie o prefab `Character_Heroic_Real` por enquanto (não sobrescreva o placeholder ainda — faremos isso no Estágio 5 após validação).

---

### Validação do Estágio 4

- [ ] FBXs importados sem erros no console do Unity
- [ ] Avatar humanoid configurado e verde (sem ossos vermelhos)
- [ ] Animações configuradas com o Avatar do personagem
- [ ] Toon shader aplicado com as cores do Heroic
- [ ] Martelo visível e preso ao bone da mão direita
- [ ] Prefab `Character_Heroic_Real` criado em `Generated/Prefabs/`

### Ao terminar

Anote no rastreador qualquer ajuste de posição/rotação que você fez no Martelo — esses valores podem precisar ser referenciados se o prefab precisar ser recriado.

---

## Estágio 5 — Validação e Substituição do Placeholder

### Objetivo

Verificar o personagem na câmera isométrica real do jogo, corrigir os problemas visuais mais óbvios, e substituir o placeholder de primitivas pelo novo prefab.

### Regra fundamental de validação

**Nunca valide em viewport livre.** O jogo usa câmera isométrica fixa. Um personagem que parece ótimo na viewport pode ser ilegível no ângulo real. Toda validação deve ser feita com a câmera do jogo ativa.

---

### Parte A — Testar na Câmera do Jogo

1. Abra a cena `Arena_AForja`.

2. Encontre o `CharacterProfile_Heroic` em `Assets/Game/Content/Phase3/Characters/Profiles/`.

3. No Inspector do profile, altere temporariamente o campo `characterPrefab` para apontar para `Character_Heroic_Real` (o novo prefab).

4. Entre em **Play Mode** (botão ▶) e observe o personagem na câmera isométrica.

**Checklist de validação visual:**

| O que verificar | O que deve acontecer |
| --- | --- |
| Silhueta | Corpo humanoid reconhecível no ângulo isométrico |
| Martelo | Visível na mão, não atravessando o corpo |
| Idle | Personagem "respira" ou permanece parado naturalmente |
| Walk / Run | Movimento fluido, pés não atravessam o chão |
| BasicAttack | Movimento de ataque visível e com swing do martelo |
| HitReaction | Reação clara ao receber dano |
| Death | Queda reconhecível |
| Toon shader | Cores douradas visíveis, rim light presente |

**Problemas comuns e como resolver:**

| Problema | Causa provável | Solução |
| --- | --- | --- |
| Personagem aparece pequeno demais | Escala incorreta | Ajuste a escala do prefab (localScale no profile) |
| Martelo atravessa o corpo durante ataque | Pivot ou posição errada | Ajuste Transform do Martelo no prefab |
| Animações não tocam | Avatar não configurado corretamente | Revise a configuração do Avatar (Estágio 4, Parte B) |
| Personagem aparece sem cor (rosa/branco) | Shader não aplicado | Verifique o material no prefab |
| Partes do modelo aparecem pretas | Normais invertidas | Corrija no Blender e reimporte |

---

### Parte B — Substituir o Placeholder

Após a validação, com o personagem funcionando aceitavelmente:

1. **Backup:** Renomeie o prefab original: `Character_Heroic` → `Character_Heroic_Primitives` (mantenha-o como backup por enquanto).

2. Renomeie o novo prefab `Character_Heroic_Real` → `Character_Heroic`.

3. Verifique se o `CharacterProfile_Heroic` está apontando para o prefab correto.

4. Faça um teste completo: entre no modo de jogo pelo menu, selecione o Heroic no loadout, entre em uma partida (Arena ou Survival), e confirme que o personagem aparece e se comporta corretamente.

---

### Validação do Estágio 5

- [ ] Personagem validado na câmera isométrica real — silhueta legível
- [ ] Martelo visível e sem erros visuais graves durante os ataques
- [ ] Animações todas funcionando (verificadas manualmente em Play Mode)
- [ ] `Character_Heroic.prefab` substituído pelo novo personagem
- [ ] Placeholder de primitivas renomeado e mantido como backup
- [ ] Partida completa testada do menu até o jogo

---

## Próximos Passos após Completar o Tutorial

Ao concluir os 5 estágios:

1. **Atualizar este tutorial** — mudar o rastreador no topo para refletir que `Character_Heroic` deixou de ser placeholder e anotar quaisquer ressalvas visuais ou técnicas

2. **Repetir o processo para o Human/Rifle** — o segundo personagem segue o mesmo pipeline, com as diferenças de vocabulário visual (militar, tons de verde/cinza/preto)

3. **Próxima prioridade de arte** — com dois personagens reais no projeto, o próximo gap crítico é o Boss Troll e os VFX de combate (Category 1)

---

## Referências Rápidas

**Cores do Heroic (toon shader):**
- Base: `#D6941F` · Shadow: `#381F1F` · Rim: `#FFD770` · Rim Power: 3.4

**Localização dos arquivos no projeto:**
- Prefabs: `Assets/Game/Content/Phase3/Characters/Generated/Prefabs/`
- Animações: `Assets/Game/Content/Phase3/Characters/Generated/Animations/`
- Controllers: `Assets/Game/Content/Phase3/Characters/Generated/Controllers/`
- Materials: `Assets/Game/Content/Phase3/Characters/Generated/Materials/`
- Profile: `Assets/Game/Content/Phase3/Characters/Profiles/`
- Shader: `Assets/Game/Content/Phase3/Characters/Shaders/ToonRimCharacter.shader`

**Ferramenta de referência de arte:** `docs/guides/art-pipeline.md` — leia as Seções 4 (animações), 9 (vocabulário visual do Heroic), e 11 (padrões de qualidade para placeholder)
