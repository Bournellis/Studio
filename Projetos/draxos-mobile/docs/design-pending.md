# DraxosMobile - Design Pending

- Ultima atualizacao: `2026-05-26`
- Status: registro vivo de pendencias de design
- Escopo: DraxosMobile, Track 00 e evolucoes futuras

Este documento e o unico lugar para registrar pendencias de design do projeto ativo. Ele nao resolve design; ele nomeia o que ainda precisa ser decidido, classifica o bloqueio e aponta para o documento que deve receber a resposta quando a decisao existir.

## Como Usar

Campos obrigatorios:

| Campo | Uso |
|---|---|
| ID | Identificador estavel da pendencia |
| Sistema | Area afetada |
| Bloqueia | `MVP_TECNICO`, `PRIMEIRO_SLICE`, `PLAYTEST_ALPHA`, `CALIBRAVEL_ALPHA`, `OPERACIONAL` ou `POS_SLICE` |
| Pergunta | Decisao de design ainda em aberto |
| Impacto | Risco se a decisao nao existir |
| Documento destino | Documento que deve ser atualizado quando resolver |
| Status | `ABERTO`, `RESOLVIDO`, `CALIBRAR`, `ADIADO` |
| Resolvido em | Data ou `-` |

Categorias:

- `MVP_TECNICO`: bloqueia a prova tecnica minima da Track 00.
- `PRIMEIRO_SLICE`: bloqueia completar o primeiro slice funcional.
- `PLAYTEST_ALPHA`: pode ser implementado com placeholder, mas precisa existir antes de playtest real.
- `CALIBRAVEL_ALPHA`: pode nascer com valor inicial e ser ajustado com dados.
- `OPERACIONAL`: nao altera game design, mas bloqueia validacao, ambiente, seguranca ou execucao tecnica confiavel.
- `POS_SLICE`: fora da Track 00 completa.

## Estado Do MVP Tecnico

Nao ha pendencia de game design bloqueando a fundacao client e as fixtures tecnicas enquanto elas usarem conteudo marcado como `MVP_ONLY`.

T00-P03 e T00-P04 foram implementados sem resolver balanceamento final: autoloads, pipeline de conteudo e `mvp_training_battle` existem apenas para validar arquitetura.

O MVP tecnico ja implementou conta guest server-authoritative, cliente de sessao, `battle/request`, `battle/latest`, replay placeholder ate T00-P08 e replay rico `FIRST_SLICE_SIM` em T00-P10. As decisoes operacionais de runtime Supabase, guest auth e escrita service-role-only ja estao tomadas.

## Pendencias Ativas

| ID | Sistema | Bloqueia | Pergunta | Impacto | Documento destino | Status | Resolvido em |
|---|---|---|---|---|---|---|---|
| DMOB-D001 | Escopo | PRIMEIRO_SLICE | O primeiro slice completo usa cap de level 10, 40 ou outro recorte dentro da Season 1? | Resolvido: Season 1 usa cap 40 por padrao, todos os levels sao permanentes e o simulador permite calibrar cap inicial 40/50/60. | `../implementation/tracks/track-00-first-slice-foundation/scope.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D002 | Progressao | PRIMEIRO_SLICE | Quais sao os gatilhos exatos de unlock de slots de spell, passiva e pet? | Resolvido: 0 slots no inicio; spell slots nos levels 3, 7 e 25; passiva no level 10; pet no level 15. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D003 | Base Manager | PRIMEIRO_SLICE | Quais stats a Estrutura de Stats altera, quanto por level e com qual custo/recurso? | Resolvido: pacote unico permanente por level com Vida +0.8%, Ataque/dano base +0.5%, Defesa +0.4%, Mana/regen +0.3%, custando Energia + tempo como as demais estruturas. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D004 | Ossario | PRIMEIRO_SLICE | Qual e a taxa de producao de Ossos por level e o limite de armazenamento do Ossario? | Resolvido: Ossario produz ate 2 Ossos/dia no level 40, com curva linear por level e storage `max(8, ceil(producao_diaria_atual * 2))`. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D005 | Construcoes | PRIMEIRO_SLICE | Qual e o preco do segundo slot de construcao e quais regras mudam apos a compra unica? | Resolvido: segundo slot custa 500 Diamantes, e permanente, pode ser liberado por test flag no alpha, permite dois jobs simultaneos mas nao dois jobs da mesma estrutura. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D006 | XP Livre | PLAYTEST_ALPHA | Quais sao os valores de XP por tipo/level de construcao e por quest? | Baseline calibravel criado no simulador economico; valores finais dependem de iteracao com dados. | `docs/economy/README.md` | CALIBRAR | - |
| DMOB-D007 | Energia | PLAYTEST_ALPHA | Qual curva de Energia e esperada para jogador free, battle pass e gasto com Diamante? | Baseline calibravel criado no simulador economico; valores finais dependem de iteracao com dados. | `docs/economy/README.md` | CALIBRAR | - |
| DMOB-D008 | Recompensas | PLAYTEST_ALPHA | Quais sao as recompensas diarias e semanais exatas, limites e relacao com rewarded ads? | Resolvido como v0 calibravel: diarias, semanais, Battle Pass e rewarded ads opcionais estao definidos em `docs/economy/README.md`; numeros continuam ajustaveis no alpha. | `docs/economy/README.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D009 | Missoes | PRIMEIRO_SLICE | O sistema sera missoes diarias variadas ou apenas bonus das 3 primeiras vitorias? | Resolvido: primeiro slice usa missoes fixas, bonus das 3 primeiras vitorias do dia, coleta de base, construcao/evolucao e semanais fixas; variacao/reroll fica pos-alpha. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D010 | Onboarding | PRIMEIRO_SLICE | Quais quests iniciais existem, quais telas desbloqueiam e quais recompensas entregam? | Resolvido: onboarding de primeira sessao guia guest -> Refugio -> coleta -> upgrade do Nucleo -> primeira batalha -> replay/recompensa -> Base/missoes; Social abre no level 5, Guilda/Chat no 10, Pet no 15 e avancado/summons no 25. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D011 | Battle Pass | PRIMEIRO_SLICE | Qual conteudo existe em cada tier Free/Premium e em cada passe bimestral? | Resolvido: cada passe tem 60 dias, 30 tiers, Free + Premium; totais v0 de recurso/cosmetico vivem em `docs/economy/README.md`. | `docs/economy/README.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D012 | Diamante | PRIMEIRO_SLICE | Quais usos e precos absolutos do Diamante entram no primeiro slice? | Resolvido: Diamante compra segunda fila, aceleracao, pacotes limitados e cosmeticos; nao compra poder exclusivo. Precos v0 vivem em `docs/economy/README.md`. | `docs/economy/README.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D013 | Guilda | PRIMEIRO_SLICE | Quais recursos entram nas contribuicoes de guilda, custos por level e bonus por construcao? | Resolvido: guilda v0 level 1-10, 10-50 membros, contribuicoes com recursos permanentes leves e 4 construcoes com teto de ate 5% na Season 1 maximizada; seasons futuras podem aumentar o teto. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D014 | Ajudas | PRIMEIRO_SLICE | Qual e o limite diario de ajudas que um jogador pode dar e receber? | Resolvido: jogador envia ate 30 ajudas/dia; cada construcao recebe ate 10 ajudas, 1,5% cada, max 15% de reducao. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D015 | Ranking | PRIMEIRO_SLICE | Qual formula de ganho/perda de pontos de arena sera usada no primeiro slice? | Resolvido: ranking v0 usa vitoria base +20, derrota base -10, ajuste por diferenca de poder, bots fora do ranking e snapshot por season. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D016 | Matchmaking | PRIMEIRO_SLICE | Qual faixa de poder inicial e fallback para matchmaking real/bot? | Resolvido: pareamento por poder com tolerancia progressiva de 10%, 20% e 35%, usando bot quando nao houver jogador compativel. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D017 | Bots | PRIMEIRO_SLICE | Como gerar builds simuladas por faixa de poder e quais combinacoes precisam cobrir? | Resolvido: gerar bots por bandas de poder e archetypes legais por level, fora do ranking. | `contracts/content-definitions.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D018 | Summons | PRIMEIRO_SLICE | Qual escala de HP e dano dos summons por level de spell? | Resolvido: summons escalam pelo level da spell invocadora com HP `base * (1 + 0.10 * level_delta)` e DPS `base * (1 + 0.08 * level_delta)`. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D019 | Maestria | PRIMEIRO_SLICE | Dano de summons conta para maestria da spell invocadora? | Resolvido: dano e kills de summon contam 100% para a maestria da spell invocadora, nao para Varinha ou pet. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D020 | Stats | PRIMEIRO_SLICE | Qual e a curva de Regen Vida e Regen Mana por level e fontes externas? | Resolvido: stats v0 usam curva linear por level global e bonus externos como multiplicadores apos a curva base. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D021 | Instrumento Ritual | PRIMEIRO_SLICE | Quais qualidades do Instrumento Ritual inicial existem no primeiro slice e quais custos de Ossos? | Resolvido: o Instrumento tem 5 qualidades permanentes sem RNG, custo acumulado 1200 Ossos no cap 40 e multiplicador maximo 1.45x. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D022 | Cosmeticos | PRIMEIRO_SLICE | Quais cosmeticos entram no primeiro slice e quais ficam apenas como categoria futura? | Resolvido: primeiro slice inclui moldura de perfil, titulo, banner do Refugio, skin visual da Varinha e badge de chat. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D023 | Chat | PRIMEIRO_SLICE | Qual politica de retencao, delecao, bloqueio e moderacao para mensagens de guilda/direct? | Resolvido: chat v0 usa guilda + direct, retencao 30 dias, soft delete, bloqueio de usuario, denuncia para moderacao manual, rate limit e polling no alpha. | `architecture.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D024 | Telemetria | PRIMEIRO_SLICE | Qual telemetria minima precisa existir no primeiro slice? | Resolvido: eventos minimos de batalha, matchmaking, recompensa, build snapshot e bot-vs-bot registrados em `telemetry_events`. | `architecture.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D025 | Visual/UX | PRIMEIRO_SLICE | Qual estilo visual e layout base do Refugio, batalha, social e loja? | Resolvido: UX alpha com Refugio como hub e telas Batalha, Base, Social e Loja/Passe. | `product-brief.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D026 | Build/Schema | PRIMEIRO_SLICE | Como representar spells desbloqueadas vs equipadas e slots no schema vivo? | Resolvido: `builds` como resumo, estados normalizados para spells/Doutrinas/Familiares e slots de spell separados. | `contracts/database-schema.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D027 | Anuncios | PRIMEIRO_SLICE | Quais recompensas usam rewarded ads e qual pacote remove anuncios? | Resolvido: alpha nao usa anuncios reais; beta pode ter rewarded ads opcionais, max 3/dia, sem anuncio forcado e sem pacote de remocao no alpha. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D028 | Conquistas | PRIMEIRO_SLICE | Quais conquistas entram no primeiro slice e quais recompensas entregam? | Resolvido: conquistas v0 cobrem primeira batalha/vitoria, vitorias acumuladas, milestones de level, construcao, guilda e ajuda; recompensas sao titulos, molduras, pequenos Diamantes e recursos leves. | `game-design-document.md` | RESOLVIDO | 2026-05-20 |
| DMOB-D029 | Poder | CALIBRAVEL_ALPHA | Quais pesos finais da formula de poder apos incluir summons e todos os upgrades? | Source Identity Balance v2 usa pesos alpha `level=42`, `weapon=28`, `spell=40`, `pet=34`, `passive=22`, `quality=30` e recalcula poder por loadout real no Battle Lab. Manter calibravel ate playtest manual confirmar matchmaking. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D030 | Balanceamento | CALIBRAVEL_ALPHA | Quais valores finais de dano, cooldown, mana, DoT, Familiar, Doutrina e anti-stall? | Run oficial `2026-05-25_source_identity_balance_v02`: Battle Lab `PASS`, `3132` batalhas, duracao media `24.08s`, anti-stall `4.95%`, dominancia em poder proximo maxima `63.46%` e checks de identidade de fonte em `PASS`. Continua calibravel por sensacao manual e Progression Lab. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D031 | Guilda | CALIBRAVEL_ALPHA | Os bonus de guilda estao leves o suficiente para nao serem obrigatorios? | Tuning social/economico precisa dados reais. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D032 | Diamante | CALIBRAVEL_ALPHA | A economia de Diamante cobre o gap esperado sem substituir gameplay? | Requer observacao de progressao free vs paga. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D044 | Progression Lab | CALIBRAVEL_ALPHA | Quais estados saudaveis representam 2h, 5h, 10h, 15h e 20h para cada perfil de jogador? | Tooling v1 gera 25 estados baseline; ainda precisa validacao manual no Godot e Supabase local para confirmar ritmo real. | `docs/progression-lab/README.md` | CALIBRAR | - |
| DMOB-D045 | Poder | CALIBRAVEL_ALPHA | Quais pesos de poder devem sair dos dados de Progression Lab + Battle Lab para pareamento inicial? | Pesos alpha v2 atualizados para `weapon=28`, `spell=40`, `pet=34`; Progression Lab segue `REVIEW` ate rodada manual confirmar bots/poder. | `docs/progression-lab/README.md` | CALIBRAR | - |
| DMOB-D046 | Premium | CALIBRAVEL_ALPHA | Qual gap aceitavel entre free, freemium, gastador leve e max_spender sem vender poder exclusivo acima do cap? | `premium_gap.csv` esta em `REVIEW` sem `CRITICAL` na escala v1; `spender_light` e `max_spender` 10h continuam pedindo playtest antes de ajuste economico. | `docs/progression-lab/README.md` | CALIBRAR | - |
| DMOB-D047 | Personagem | CALIBRAVEL_ALPHA | Qual taxonomia de instrumentos, spells, doutrinas, familiares, fontes de dano e familias de status substitui os placeholders de teste? | Resolvido: rework ocultista 2026-05-25 define Instrumentos Rituais, spells mentais/corporais/elementais/Morte, Doutrinas, Familiares, fontes Arcano/Fisico/Fogo/Agua/Gelo/Terra/Vento/Raio/Veneno/Sangue/Morte e mental como familia de status. Numeros seguem calibraveis no Battle Lab. | `character-systems-rework.md` | RESOLVIDO | 2026-05-25 |
| DMOB-D048 | Base | PLAYTEST_ALPHA | Qual e a lista final de menus, estados, beneficios e textos de predios da Base v0 para Internal Alpha v0? | Sem isso a base pode funcionar tecnicamente, mas nao parecer um sistema de jogo testavel. | `game-design-document.md` / `docs/internal-alpha-v0.md` | ABERTO | - |
| DMOB-D049 | Conta/Save | PLAYTEST_ALPHA | Como o usuario alterna, identifica e reseta os saves `normal` e `progression_lab` sem confundir progresso real com teste? | Risco de corromper percepcao do teste ou misturar dados do Lab com o save normal. | `architecture.md` / `docs/internal-alpha-v0.md` | ABERTO | - |
| DMOB-D050 | Loja | PLAYTEST_ALPHA | Quais redeems alpha fixos testam free, premium leve e premium alto sem parecer pagamento real? | A loja precisa provar fluxo premium, mas nao pode sugerir balance final ou monetizacao real. | `docs/economy/README.md` / `docs/internal-alpha-v0.md` | ABERTO | - |
| DMOB-D051 | Competicao | PLAYTEST_ALPHA | Bots aparecem na leaderboard da Internal Alpha v0 e qual formula de pontos sera exibida ao jogador? | Leaderboard com poucos usuarios pode parecer vazia; bots ajudam teste, mas podem distorcer leitura social. | `game-design-document.md` / `architecture.md` | ABERTO | - |
| DMOB-D052 | Social | PLAYTEST_ALPHA | Quais limites sociais entram no alpha fechado: amigos, guilda, chat, rate limit, bloqueio e moderacao minima? | Sem limites claros o teste pode criar comportamento inconsistente ou endpoint aberto demais. | `game-design-document.md` / `architecture.md` | ABERTO | - |
| DMOB-D053 | Releases | OPERACIONAL | Qual politica de update sera usada: quando update e recomendado, quando e obrigatorio, e quando um save pode ser destruido? | Bloqueia manifest remoto, mensagem de update e iteracao rapida sem confundir testadores. | `architecture.md` / `docs/internal-alpha-v0.md` | ABERTO | - |
| DMOB-D054 | Conta Alpha | OPERACIONAL | Qual fluxo manual de convite, criacao de conta, recuperacao de senha e bloqueio de acesso sera usado para dois testadores? | Web link publico/unlisted nao e controle de acesso; a barreira real precisa estar no Auth/servidor. | `contracts/api-endpoints.md` / `docs/internal-alpha-v0.md` | ABERTO | - |
| DMOB-D055 | Progression Lab | PLAYTEST_ALPHA | Quais acoes do jogo ficam permitidas, bloqueadas ou isoladas quando o save ativo e `progression_lab`? | O Lab precisa ser util para cenarios avancados sem contaminar ranking, social ou economia do save normal. | `docs/progression-lab/README.md` / `docs/internal-alpha-v0.md` | ABERTO | - |
| DMOB-D033 | PVE | POS_SLICE | Qual formato do Character Autobattler PVE? | Fora da Track 00, mas deve preservar compatibilidade futura. | `game-design-document.md` | ADIADO | - |
| DMOB-D034 | Cardgame Roguelike | POS_SLICE | Qual formato competitivo e progressao propria do PVP Cardgame Roguelike? | Fora da Track 00. | `game-design-document.md` | ADIADO | - |
| DMOB-D035 | Hero Defense | POS_SLICE | Como funciona o Hero Defense e quais beneficios recebe da conta/base? | Fora da Track 00. | `game-design-document.md` | ADIADO | - |
| DMOB-D036 | Open World | POS_SLICE | O que preservar para nao bloquear Open World futuro? | Fora da Track 00. | `game-design-document.md` | ADIADO | - |
| DMOB-D037 | Lore | POS_SLICE | Quais nomes e postos da hierarquia Draxos? | Fora do primeiro slice, mas afeta narrativa futura. | `product-brief.md` | ADIADO | - |
| DMOB-D038 | Plataforma | POS_SLICE | Quando iOS ou mobile browser entram no roadmap? | Fora da Track 00. | `product-brief.md` | ADIADO | - |
| DMOB-D039 | Chat Global | POS_SLICE | Quando reconsiderar chat global interno em vez de Discord externo? | Fora da Track 00. | `product-brief.md` | ADIADO | - |
| DMOB-D040 | Supabase | OPERACIONAL | Qual layout oficial sera usado para Supabase CLI: manter `server/schema` e `server/functions`, criar espelho em `supabase/`, ou usar scripts de sincronizacao? | Sem essa decisao, `supabase db reset` e `supabase functions serve` nao ficam automatizados. | `architecture.md` | RESOLVIDO | 2026-05-19 |
| DMOB-D041 | Ambiente Local | OPERACIONAL | Como o ambiente local deve prover Docker e Supabase CLI para validar migrations e Edge Functions no runtime Supabase? | P02 tem arquivos base e healthcheck validado via `npx deno`, mas nao consegue provar migration/healthcheck dentro do Supabase sem essas ferramentas. | `../implementation/tracks/track-00-first-slice-foundation/current-status.md` | RESOLVIDO | 2026-05-19 |
| DMOB-D042 | Conta Guest | MVP_TECNICO | A criacao de guest no MVP sera feita por Edge Function criando usuario Supabase Auth anonimo/manual, por Auth nativo anonimo, ou por fluxo custom temporario? | Bloqueia T00-P05 porque define ownership entre Auth, `players.auth_user_id` e codigo de convite. | `contracts/api-endpoints.md` | RESOLVIDO | 2026-05-19 |
| DMOB-D043 | Seguranca SQL | MVP_TECNICO | Quais policies de escrita ficam explicitamente ausentes por design e quais RPCs/Edge Functions usam service role para mutar dados no MVP? | Evita liberar insert/update direto pelo cliente durante a implementacao de conta e batalha. | `contracts/database-schema.md` | RESOLVIDO | 2026-05-19 |

## Regras De Atualizacao

- Ao resolver uma pendencia, atualizar este arquivo e o documento destino no mesmo commit.
- Nao apagar pendencias resolvidas; marcar `RESOLVIDO` e preencher `Resolvido em`.
- Se uma implementacao precisar de uma decisao nao listada aqui, adicionar nova linha antes de implementar.
- Nao mover pendencias para o GDD historico em `../../_conceitos/mobile-universe/`; a fonte viva do projeto ativo fica em `Projetos/draxos-mobile/`.
