# DraxosMobile - Decisoes Pre-Implementacao

- Ultima atualizacao: `2026-05-19`
- Referencia: analise de design realizada antes da Track 00
- Status: decision log historico. Pendencias vivas agora ficam em `design-pending.md`.

---

## Papel Deste Documento

Este arquivo registra decisoes ja tomadas antes da implementacao. Ele nao e mais o registro principal de pendencias.

Use:

- `design-pending.md` para saber o que ainda precisa ser definido.
- `game-design-document.md` para o design autoritativo.
- `contracts/` para contratos tecnicos.
- `../implementation/tracks/track-00-first-slice-foundation/` para escopo e execucao da Track 00.

---

## Bloco 1 - Bloqueadores Do Simulador De Batalha `RESOLVIDO`

Todas as decisoes necessarias para o simulador inicial foram registradas.

| Decisao | Definido |
|---|---|
| Targeting da varinha (basico e especial) | Direto |
| Targeting do pet | Direto (tipos especificos no futuro) |
| Targeting dos summons | Direto (tipos especificos no futuro) |
| HP base dos summons (nivel 1) | Esqueleto 60, Morto-Vivo 40, Demonio 50 |
| Duracao dos summons | Aproximadamente 8s, menor que recast de 10s |
| Custo de Mana - Invocar Demonio | 20 |
| Custo de Mana - Animar Morto | 20 |
| Recast - Invocar Demonio | Sempre substitui ao disparar |
| Recast - Animar Morto | Prioriza slot vazio; substitui so se ambos ocupados |
| Anti-stall targeting | AoE total - mago + todos os summons simultaneamente |

---

## Bloco 2 - Arquitetura De Progressao `RESOLVIDO`

| Decisao | Definido |
|---|---|
| Levels das estruturas da base entre seasons | Permanentes - a base nunca reseta |
| Levels de passivas entre seasons | Permanentes - igual ao Level Global e Maestria |
| Levels de arma, spells e pet entre seasons | Permanentes - todos os sistemas sobem junto com o cap atual |
| Reset sazonal | Battle Pass, ranking/eventos, missoes sazonais e ofertas temporarias |
| Catch-up | Multiplicador suave de XP/recursos para jogadores abaixo do cap anterior |
| Logica de desbloqueio de spells e slots | Ordem de unlock por level minimo; sem restricao de slot apos desbloqueado |
| Local e custo de unlock de spells e slots | Altar das Almas, custo em Almas |
| Upgrades de cada construcao | Cada construcao abriga upgrades que consomem seu proprio recurso |
| Papel do Nucleo de Energia | Apenas producao; sem menu adicional alem do self-upgrade |

Detalhes preservados:

- Estruturas da base sao permanentes entre seasons.
- Passivas sao permanentes.
- Arma, spells e pet sao permanentes e nao resetam por season.
- O cap de todos os sistemas e compartilhado por season; Season 1 usa cap 40 e caps futuros ficam editaveis no simulador economico.
- Spells desbloqueadas podem ser equipadas em qualquer slot disponivel.
- Construcoes abrigam upgrades especificos: Altar das Almas, Pocos de Sangue, Minas de Cristal, Ossario, Nucleo de Energia e Estrutura de Stats.

---

## Bloco 3 - Mecanicas Com Comportamento Indefinido `RESOLVIDO`

### Congelar Com Targeting Area

Contadores de Lento sao independentes por alvo.

| Regra | Comportamento |
|---|---|
| Stacking | 1 stack por cast em cada alvo atingido |
| Contador | Cada alvo tem seu proprio contador |
| Burst | Dispara individualmente ao chegar a 3 stacks |
| Alvo do burst | Apenas o alvo que atingiu 3 stacks |

### Ossos No Primeiro Slice

| Item | Decisao |
|---|---|
| Fonte de Ossos | Drops de batalha + producao do Ossario + quests iniciais |
| Crafting da varinha | Apenas upgrade de dano por enquanto |
| Ossario no primeiro slice | Incluido |

---

## Bloco 4 - Valores Necessarios Para Alpha `MOVIDO`

As pendencias de valores numericos foram movidas para `design-pending.md`.

Principais IDs:

- `DMOB-D006` - XP por construcao e quest.
- `DMOB-D007` - curva de Energia por perfil.
- `DMOB-D008` - recompensas diarias e semanais.

---

## Bloco 5 - Calibravel No Alpha `MOVIDO`

Itens calibraveis estao em `design-pending.md` com bloqueio `CALIBRAVEL_ALPHA`.

Principais IDs:

- `DMOB-D029` - pesos de poder.
- `DMOB-D030` - balanceamento de combate.
- `DMOB-D031` - bonus de guilda.
- `DMOB-D032` - economia de Diamante.

---

## Bloco 6 - Design Incompleto `MOVIDO`

As lacunas de design do primeiro slice agora vivem em `design-pending.md`.

Nao resolver design diretamente neste arquivo. Quando uma pendencia for decidida, atualizar o documento destino e marcar a linha correspondente em `design-pending.md`.
