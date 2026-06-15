# DraxosMobile - Design Pending

- Ultima atualizacao: `2026-06-15`
- Status: registro vivo de pendencias de design abertas, calibraveis e adiadas
- Escopo: DraxosMobile, pendencias de design vivas, Arena PVE inicial,
  Bosque/Openworld como slice Internal Alpha, Foundation Hardening V2 como
  baseline anterior de hardening/live-doc gates, tuning futuro e evolucoes
  futuras. Estado operacional atual e linhagem de pacotes vivem em
  `../implementation/current-status.md` e `release-history.md`.

Este documento e o unico lugar para registrar pendencias de design do projeto ativo. Ele nao resolve design; ele nomeia o que ainda precisa ser decidido, classifica o bloqueio e aponta para o documento que deve receber a resposta quando a decisao existir.

Pendencias resolvidas ficam preservadas em `docs/design-resolved-archive.md`; este arquivo deve permanecer enxuto e acionavel.

## Como Usar

Campos obrigatorios:

| Campo | Uso |
|---|---|
| ID | Identificador estavel da pendencia |
| Sistema | Area afetada |
| Bloqueia | `FOUNDATION_AUDIT`, `MVP_TECNICO`, `PRIMEIRO_SLICE`, `PLAYTEST_ALPHA`, `CALIBRAVEL_ALPHA`, `OPERACIONAL` ou `POS_SLICE` |
| Pergunta | Decisao de design ainda em aberto |
| Impacto | Risco se a decisao nao existir |
| Documento destino | Documento que deve ser atualizado quando resolver |
| Status | `ABERTO`, `RESOLVIDO`, `CALIBRAR`, `ADIADO` |
| Resolvido em | Data ou `-` |

Categorias:

- `FOUNDATION_AUDIT`: bloqueia a leitura atual do projeto, a auditoria do loop interno ou a escolha segura do proximo pacote.
- `MVP_TECNICO`: bloqueia a prova tecnica minima da Track 00.
- `PRIMEIRO_SLICE`: bloqueia completar o primeiro slice funcional.
- `PLAYTEST_ALPHA`: pode ser implementado com placeholder, mas precisa existir antes de playtest real.
- `CALIBRAVEL_ALPHA`: pode nascer com valor inicial e ser ajustado com dados.
- `OPERACIONAL`: nao altera game design, mas bloqueia validacao, ambiente, seguranca ou execucao tecnica confiavel.
- `POS_SLICE`: fora da Track 00 completa.

## Etapa Atual

A etapa operacional atual, pacote remoto, release root, evidencia, URLs, versoes
e proximo gate vivem em `../implementation/current-status.md`. Historico de
pacotes vive em `release-history.md`.

O pacote publicado atual mantem o Bosque integrado aos overlays existentes e
precisa do playtest humano focado descrito em
`../implementation/current-status.md`. Bugs futuros voltam ao fluxo normal se
aparecerem.

A direcao viva de produto continua Arena PVE first, registrada em `docs/pve-arena-initial-direction.md`. Bosque/Openworld e slice integrado de Internal Alpha para validar movimento, coleta, cache, persistencia e fronteira controlada com Arena/Basebuilder; nao e expansao de mundo continuo aprovada nem autorizacao para abrir tuning amplo, PVP, economia, conteudo, novas armas/spells, visual final ou mutacoes remotas.

Foco atual:

`status operacional publicado -> candidato Arena UX/readability/recovery -> validacao automatica -> prova humana -> nova decisao explicita`

Foundation Loop UX Pass 01 foi aceito como baseline historico do app-shell, nao
como loop de produto atual. Foundation Closeout, Labs atualizados, Foundation
Final Polish, Hardening Platform V1 e Foundation Hardening V2 ficam preservados
como baselines historicas/tecnicas. A linhagem de pacotes Arena/Bosque vive em
`release-history.md`. Track 21 Arena Loop Unlock/Friction permanece como
contexto Arena/Autobattler para unlock, loadout travado, buffs temporarios, HP
resetado por duelo, claim summary e fluxo de retorno da Arena; Track 23 adiciona
recovery de tentativa ativa; PVP entra depois como modo competitivo/fallback.

Revisao manual do build publicado identificou regressao de responsividade: Labs Dev sumiram do menu inicial interno e Refugio/Batalha puderam sair dos limites em Web/Android. A partir de agora, mudancas visuais em Entry, Refugio ou Batalha precisam respeitar `docs/foundation-responsive-layout-contract.md` e passar em `tools/smoke_responsive_layout.gd` antes de nova publicacao.

Armas, spells, nomes, tema, imagens, economia, Battle Pass, apresentacao de batalha e visual final existem como substancia/mock. Eles so devem ser ajustados agora quando forem necessarios para o pacote pequeno de Arena PVE inicial: tutorial de 1 luta, primeiras arenas de 3 lutas, dificuldade escalavel, loadout travado, buffs temporarios de stat, vida resetada por duelo e sem cooldown de combate.

`docs/pve-arena-v1.md` fecha o contrato data-driven inicial para tamanho maximo, primeira lista de inimigos, buffs e perfis de recompensa. Os valores de recompensa continuam calibraveis ate Battle Lab, Progression Lab e rodada humana.

## Estado Do MVP Tecnico

Nao ha pendencia de game design bloqueando a fundacao client e as fixtures tecnicas enquanto elas usarem conteudo marcado como `MVP_ONLY`.

T00-P03 e T00-P04 foram implementados sem resolver balanceamento final: autoloads, pipeline de conteudo e `mvp_training_battle` existem apenas para validar arquitetura.

O MVP tecnico ja implementou conta guest server-authoritative, cliente de sessao, `battle/request`, `battle/latest`, replay placeholder ate T00-P08 e replay rico `FIRST_SLICE_SIM` em T00-P10. As decisoes operacionais de runtime Supabase, guest auth e escrita service-role-only ja estao tomadas.

## Pendencias Ativas

| ID | Sistema | Bloqueia | Pergunta | Impacto | Documento destino | Status | Resolvido em |
|---|---|---|---|---|---|---|---|
| DMOB-D066 | Recompensas Arena PVE | CALIBRAVEL_ALPHA | Formula inicial contratada em `arena_rewards.json`: primeira clear, conclusao, recorde, repeticao reduzida, bonus diario/semanal e caps. Valores numericos continuam calibraveis. | Sem validacao dos labs e rodada humana, ainda ha risco de grind infinito ou progressao lenta demais. | `pve-arena-v1.md` | CALIBRAR | - |
| DMOB-D067 | Labs Arena PVE | CALIBRAVEL_ALPHA | Contrato v1 exige que Progression Lab e Battle Lab representem listas de duelos, buffs temporarios, vida resetada, loadout travado e comportamento ajustavel. Labs ja existem no Web export e no runner remoto, mas a modelagem fina da Arena PVE nos labs ainda precisa revisao/calibracao humana. | Sem modelagem dos labs, tuning integrado de leveling/upgrades/recompensas/poder fica opinativo demais. | `docs/progression-lab/README.md` | CALIBRAR | - |
| DMOB-D069 | Towerdefense | POS_SLICE | Qual contrato de gameplay, build, recompensas e UX do modo Towerdefense? | Sem contrato, o modo permanece planned/disabled no registry tecnico e oculto ao player; decision pack v1 lista perguntas e bloqueios sem aprovar gameplay. | `docs/minigames/towerdefense-decision-pack.md` | ABERTO | - |
| DMOB-D070 | Cardgame | POS_SLICE | Qual contrato proprio do Cardgame mobile sem herdar mecanicas do projeto Steam? | Sem contrato, o modo permanece planned/disabled no registry tecnico e oculto ao player; decision pack v1 fixa a regra de nao-heranca mecanica. | `docs/minigames/cardgame-decision-pack.md` | ABERTO | - |
| DMOB-D071 | Openworld continuo | POS_SLICE | Como o Openworld evolui de Bosque para mundo continuo, incluindo mapa, risco, combate e fronteira com Basebuilder? | Playtest aprovou o slice Bosque como modo ativo Internal Alpha; expansao de mundo continuo continua bloqueada sem novo decision pack. | `docs/minigames/openworld-decision-pack.md` | ABERTO | - |
| DMOB-D073 | Openworld conflito minimo | POS_SLICE | Existe evidencia suficiente para testar um pacote minimo com monstros, NPCs e quests dentro do Openworld sem virar campanha, MMO, economia paralela ou substituto da Arena PVE? | Sem decisao, combate/quests podem contaminar o Bosque relaxante, quebrar fronteiras com Arena/Basebuilder ou criar expectativas de Openworld completo. | `docs/minigames/openworld-decision-pack.md` | ABERTO | - |
| DMOB-D082 | Prova Arena PVE | OPERACIONAL | Fabio registrou resultado combinado: `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN`. A proxima rodada precisa executar UX/readability/recovery e nova prova humana antes de escolher outro veredito. | Sem manter este gate aberto, agentes podem interpretar a prova como autorizacao para calibrar numeros ou expandir produto antes de resolver clareza/UX/recovery da Arena. | `docs/arena-pve-product-proof.md` | ABERTO | - |
| DMOB-D006 | XP Livre | PLAYTEST_ALPHA | Quais sao os valores de XP por tipo/level de construcao e por quest? | Baseline calibravel criado no simulador economico; valores finais dependem de iteracao com dados. | `docs/economy/README.md` | CALIBRAR | - |
| DMOB-D007 | Energia | PLAYTEST_ALPHA | Qual curva de Energia e esperada para jogador free, battle pass e gasto com Diamante? | Baseline calibravel criado no simulador economico; valores finais dependem de iteracao com dados. | `docs/economy/README.md` | CALIBRAR | - |
| DMOB-D029 | Poder | CALIBRAVEL_ALPHA | Quais pesos finais da formula de poder apos incluir summons e todos os upgrades? | Source Identity Balance v2 usa pesos alpha `level=42`, `instrument=28`, `spell=40`, `familiar=34`, `doutrina=22`, `quality=30`; aliases tecnicos antigos `weapon/pet/passive` podem existir no simulador. Manter calibravel ate playtest manual confirmar matchmaking. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D030 | Balanceamento | CALIBRAVEL_ALPHA | Quais valores finais de dano, cooldown, mana, DoT, Familiar, Doutrina e anti-stall? | Run oficial `2026-05-25_source_identity_balance_v02` e Track 16 Lab Alignment continuam evidencia historica/tecnica. A proxima rodada precisa simular Arena PVE com listas de duelos, vida resetada, buffs temporarios e comportamento entre lutas antes de promover tuning. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D031 | Guilda | CALIBRAVEL_ALPHA | Os bonus de guilda estao leves o suficiente para nao serem obrigatorios? | Tuning social/economico precisa dados reais. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D032 | Diamante | CALIBRAVEL_ALPHA | A economia de Diamante cobre o gap esperado sem substituir gameplay? | Requer observacao de progressao free vs paga. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D044 | Progression Lab | CALIBRAVEL_ALPHA | Quais estados saudaveis representam 2h, 5h, 10h, 15h e 20h para cada perfil de jogador? | Rodada tecnica 2026-05-27 registrada em `docs/progression-lab/2026-05-27-t04-progression-economia.md`: 25 estados/75 bots, sem divida de recurso e `REVIEW` concentrado em free/freemium 20h. Ainda precisa validacao manual no Godot/Supabase local. | `docs/progression-lab/README.md` | CALIBRAR | - |
| DMOB-D045 | Poder | CALIBRAVEL_ALPHA | Quais pesos de poder devem sair dos dados de Progression Lab + Battle Lab para pareamento inicial? | Pesos alpha v2 seguem `PASS` na rodada tecnica 2026-05-27; recomendacao atual e manter pesos ate rodada humana confirmar bots/poder e nova comparacao Battle Lab justificar mudanca. | `docs/progression-lab/README.md` | CALIBRAR | - |
| DMOB-D046 | Premium | CALIBRAVEL_ALPHA | Qual gap aceitavel entre free, freemium, gastador leve e max_spender sem vender poder exclusivo acima do cap? | `premium_gap.csv` segue em `REVIEW` sem `CRITICAL`; alertas atuais sao `spender_light` 10h, `max_spender` 10h e `max_spender` 20h. Nao alterar economia antes de decisao explicita. | `docs/progression-lab/README.md` | CALIBRAR | - |
| DMOB-D034 | Cardgame Roguelike | POS_SLICE | Qual formato competitivo e progressao propria do PVP Cardgame Roguelike? | Fora da Track 00. | `game-design-document.md` | ADIADO | - |
| DMOB-D035 | Hero Defense | POS_SLICE | Como funciona o Hero Defense e quais beneficios recebe da conta/base? | Fora da Track 00. | `game-design-document.md` | ADIADO | - |
| DMOB-D036 | Open World | POS_SLICE | O que preservar para nao bloquear Open World futuro? | Fora da Track 00. | `game-design-document.md` | ADIADO | - |
| DMOB-D037 | Lore | POS_SLICE | Quais nomes e postos da hierarquia Draxos? | Fora do primeiro slice, mas afeta narrativa futura. | `product-brief.md` | ADIADO | - |
| DMOB-D038 | Plataforma | POS_SLICE | Quando iOS ou mobile browser entram no roadmap? | Fora da Track 00. | `product-brief.md` | ADIADO | - |
| DMOB-D039 | Chat Global | POS_SLICE | Quando reconsiderar chat global interno em vez de Discord externo? | Fora da Track 00. | `product-brief.md` | ADIADO | - |

## Regras De Atualizacao

- Ao resolver uma pendencia, atualizar este arquivo e o documento destino no mesmo commit.
- Depois de registrada a decisao, mover a linha resolvida para `docs/design-resolved-archive.md` para manter este documento vivo focado em decisoes abertas, calibraveis ou adiadas.
- Se uma implementacao precisar de uma decisao nao listada aqui, adicionar nova linha antes de implementar.
- Nao mover pendencias para o GDD historico em `../../_conceitos/mobile-universe/`; a fonte viva do projeto ativo fica em `Projetos/draxos-mobile/`.
