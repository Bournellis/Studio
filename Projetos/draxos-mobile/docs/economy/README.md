# DraxosMobile - Economia E Simulador De Seasons

- Ultima atualizacao: `2026-05-31`
- Status: baseline calibravel; proxima revisao deve ser Arena PVE inicial
- Fonte de verdade numerica: `../../tools/economy_simulator/economy_model.v1.json`
- Gerador: `../../tools/economy_simulator/generate.ts`
- Saidas geradas: `generated/`

Este documento organiza como a economia do DraxosMobile deve ser trabalhada daqui em diante. Ele nao fecha balanceamento final; ele define a estrutura de raciocinio, os recursos, os perfis e o simulador que permitem calibrar a Season 1 e preparar seasons futuras.

---

## Direcao Arena PVE Inicial

A economia do early game deve partir da Arena PVE, nao de PVP-first. Nao existe cooldown de combate para controlar a Arena PVE inicial. O controle economico deve vir de:

- primeira conclusao por arena/dificuldade;
- recompensa de conclusao da lista;
- recordes e progresso de dificuldade;
- missoes diarias/semanais;
- repeticao com recompensa reduzida;
- limites diarios/semanais de bonus;
- caps de season e sinks de upgrade.

O simulador deve medir leveling, upgrades, recursos, poder e base em conjunto com arenas de 1 duelo tutorial, 3 duelos iniciais e arenas maiores futuras. PVP posterior deve ser calibrado contra essa base, nao o contrario.

---

## Regras De Season

- Season 1 dura 120 dias.
- Cada season tem 2 Battle Passes de 60 dias.
- Season 1 usa cap 40 por padrao.
- O simulador permite testar cap inicial 40, 50 ou 60.
- Caps futuros sao editaveis por season; nao ha regra fixa de crescimento ainda.
- Todos os sistemas compartilham o cap atual: level global, Instrumento Ritual, spells, Familiar, Doutrina e construcoes.
- Nenhum level reseta entre seasons.
- Resetam por season: Battle Pass, ranking/eventos de arena, missoes sazonais e ofertas temporarias.
- Catch-up futuro usa multiplicador suave de XP/recursos para jogadores abaixo do cap anterior.

### Bonus De Guilda Por Season

Bonus de guilda e parte do plano economico de longo prazo. Na Season 1, uma guilda maximizada deve chegar a **ate 5%** de bonus nas construcoes de guilda. Seasons futuras podem aumentar esse teto sem tornar guilda obrigatoria para competir.

Teto inicial por season:

| Season | Teto de bonus de guilda |
|---|---:|
| S1 | 5% |
| S2 | 7,5% |
| S3 | 10% |

Esses tetos vivem tambem em `../../tools/economy_simulator/economy_model.v1.json` como `guild_bonus_caps`. O tuning social/economico continua `CALIBRAVEL_ALPHA`.

## Matriz De Recursos

| Recurso | Funcao | Entradas | Saidas | Persistencia |
|---|---|---|---|---|
| XP | Level global, unlocks e ritmo da season | Batalhas, missoes, Battle Pass, catch-up | Nao e gasto | Permanente |
| Almas | Upgrade de Instrumento Ritual e spells | Batalhas, base, missoes, Battle Pass, pacotes limitados | Instrumento Ritual, spells e unlocks magicos | Permanente |
| Energia | Gargalo da base | Nucleo, batalhas, missoes, Battle Pass, Diamante | Construcoes, fila e aceleracao | Permanente |
| Sangue | Progressao de Familiar | Pocos, batalhas, missoes, Battle Pass | Familiares | Permanente |
| Cristais | Progressao de Doutrina | Minas, missoes, Battle Pass | Doutrinas | Permanente |
| Ossos | Materia-prima geral de crafting e qualidade do Instrumento Ritual | Ossario, batalha, quests, Battle Pass | Qualidade do Instrumento Ritual, trituracao para consumiveis | Permanente |
| Po de Osso | Crafting de consumiveis | Triturar Ossos | Pocoes e consumiveis | Permanente |
| Diamante | Premium, tempo e conforto | Compra, passe premium, recompensas raras | Aceleracao, fila, pacotes limitados | Permanente |
| Tempo/Fila | Controle de ritmo | Espera, fila gratis, segunda fila | Construcoes e aceleracao | Permanente |
| Poder | Matchmaking e leitura de forca | Derivado de level/build/upgrades | Nao e gasto | Recalculado |
| Arena | Ranking competitivo | PvP sazonal | Perdas/decay se existir | Sazonal |
| Arena PVE | Early game, primeira conclusao, recorde e dificuldade | Duelos PVE, missoes, conclusoes, records | Recompensas limitadas/reduzidas e upgrades de build/base | Misto: progresso permanente + records sazonais se adotados |
| Maestria | Progressao permanente por uso | Dano causado | Nao e gasto | Permanente |

Regra de ownership: cada recurso deve ter um papel claro. XP libera, Almas fortalecem magia e Instrumento Ritual, Energia move a base, Sangue move Familiar, Cristais movem Doutrinas, Ossos movem qualidade/crafting, Po de Osso move consumiveis e Diamante compra tempo/conforto.

## Perfis Do Simulador

| Perfil | Objetivo de leitura |
|---|---|
| Free casual | Mede progresso de rotina leve, sem obrigar cap |
| Free ativo | Referencia principal: 20 batalhas/dia, 1 check-in obrigatorio/dia, cap perto do dia 105 |
| Compra eficiente | Free ativo + segunda fila + Battle Pass Premium |
| Premium completo | Compra passes e pacotes eficientes limitados |
| Whale/acelerador | Testa aceleracao extrema sem ultrapassar o cap |
| Catch-up newcomer | Testa jogador que entra atrasado com multiplicador suave |

O simulador mede atividade por acoes por dia e estima minutos a partir dessas acoes. A meta e manter o free ativo em torno de 30-45 minutos/dia.

## Monetizacao

Monetizacao deve vender tempo, conforto, amplitude e previsibilidade. Nao deve vender spell, pet, passiva ou poder exclusivo.

Permitido para modelagem inicial:

- segunda fila de construcao;
- Battle Pass Premium;
- aceleracao de filas;
- pacotes limitados de recursos;
- recompensas raras de Diamante;
- conveniencias e cosmeticos.

Nao permitido como baseline:

- conteudo de combate exclusivo de pagamento;
- poder acima do cap;
- bypass permanente de matchmaking;
- recurso infinito sem limite de season/cap.

### Monetizacao E Recompensas v0

O primeiro slice usa monetizacao funcional de alpha: compras reais podem ser substituidas por fluxo de teste, mas os precos, limites e contratos ja seguem a direcao final. Premium acelera e amplia conforto, mas nao libera conteudo de combate exclusivo nem ultrapassa o cap.

Battle Pass v0:

- Cada passe dura 60 dias.
- Cada season tem 2 passes.
- Cada passe tem 30 tiers.
- Trilha Free e Trilha Premium usam os mesmos tiers.
- Premium adiciona recursos, cosmeticos e conforto; nao vende spell, Familiar, Doutrina, Instrumento exclusivo ou poder acima do cap.

Total por passe de 60 dias:

| Trilha | XP | Almas | Energia | Sangue | Cristais | Ossos | Diamante | Extras |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| Free | 4800 | 480 | 480 | 180 | 120 | 6000 | 15 | titulos simples e badges |
| Premium adicional | 9000 | 900 | 900 | 420 | 240 | 12000 | 30 | cosmeticos premium e conveniencia |

Recompensas diarias v0 (reinterpretar como Arena PVE ate PVP virar modo ativo):

| Missao | XP | Almas | Energia | Sangue | Cristais | Ossos |
|---|---:|---:|---:|---:|---:|---:|
| Primeira vitoria de Arena PVE | 120 | 8 | 4 | 2 | 0 | 100 |
| Segunda vitoria de Arena PVE | 100 | 7 | 4 | 2 | 1 | 100 |
| Terceira vitoria de Arena PVE | 80 | 5 | 4 | 2 | 1 | 100 |
| Coletar base | 25 | 2 | 4 | 1 | 1 | 0 |
| Construir ou evoluir | 25 | 3 | 4 | 1 | 1 | 0 |
| **Total diario cheio** | **350** | **25** | **20** | **8** | **4** | **300** |

Recompensas semanais v0:

| Missao | XP | Almas | Energia | Sangue | Cristais | Ossos |
|---|---:|---:|---:|---:|---:|---:|
| Participacao de arena | 420 | 36 | 36 | 12 | 6 | 300 |
| Dominio de arena | 360 | 36 | 24 | 8 | 4 | 200 |
| Rotina do refugio | 200 | 12 | 24 | 8 | 4 | 200 |
| **Total semanal cheio** | **980** | **84** | **84** | **28** | **14** | **700** |

Diamante v0:

| Uso | Preco |
|---|---:|
| Segundo slot de construcao | 500 Diamantes |
| Aceleracao de construcao | 1 Diamante por 10 min restantes |
| Pacote pequeno de Energia | 80 Diamantes |
| Pacote pequeno de recursos mistos | 120 Diamantes |
| Cosmetico simples | 150-300 Diamantes |
| Cosmetico premium | 500-800 Diamantes |

Rewarded ads v0:

- Alpha nao usa anuncios reais.
- Contrato fica preparado para beta com rewarded ads opcionais.
- Sem anuncio forcado.
- Limite futuro: 3 rewarded ads por dia.
- Recompensas futuras permitidas por ad: Energia leve, bau leve de recurso comum ou pequena aceleracao.
- Nao existe pacote de remover anuncios no alpha, pois nao ha anuncio obrigatorio.

Cosmeticos v0:

- Moldura de perfil.
- Titulo.
- Banner do Refugio.
- Skin visual da Varinha.
- Badge de chat.

Conquistas v0:

- Conquistas sao marcos unicos e permanentes.
- Recompensas podem incluir titulo, moldura, pequenos Diamantes e recursos leves.
- Marcos iniciais: primeira batalha, primeira vitoria, 10/50/100 vitorias, levels 3/7/10/15/25/40, primeira construcao, primeira estrutura level 10, entrar em guilda e enviar primeira ajuda.

## Como Ler O Simulador

1. Ajuste cap e duracao em `Season Inputs`.
2. Compare perfis no `Dashboard`.
3. Use `Resource Matrix` para entender ownership de recursos.
4. Use `Sources` e `Sinks` para ver entradas e custos.
5. Use `Daily Simulation` para acompanhar nivel, XP e recursos por dia.
6. Use `Premium Stress` para avaliar o impacto de pagamento forte.
7. Use `Catch-up` para verificar se jogadores novos aproximam sem pular a jornada.
8. Use `Checks` antes de promover qualquer numero para contrato de implementacao.

## Criterios Iniciais

- Free ativo deve chegar ao cap perto do dia 105.
- Free ativo nao deve precisar de mais de 1 check-in obrigatorio por dia.
- Free casual nao precisa chegar ao cap.
- Compra eficiente deve melhorar conforto e velocidade, mas nao liberar poder exclusivo.
- Whale/acelerador nao pode ultrapassar cap.
- Catch-up newcomer deve aproximar do cap antigo sem receber level diretamente.

## Arquivos Gerados

O gerador produz:

- `generated/season_economy_summary.json`
- `generated/season_economy_daily.csv`
- `generated/season_economy_profiles.csv`
- `generated/season_economy_checks.csv`
- `generated/draxos_mobile_economy_simulator.xlsx`

As saidas sao artefatos de leitura. A fonte de verdade editavel fica no JSON versionado em `tools/economy_simulator/`.
