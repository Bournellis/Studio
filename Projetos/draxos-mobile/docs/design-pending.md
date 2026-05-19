# DraxosMobile - Design Pending

- Ultima atualizacao: `2026-05-19`
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

O MVP tecnico ja implementou conta guest server-authoritative e `account/state` em T00-P05. Ainda faltam o cliente de sessao em T00-P06 e o battle request em T00-P07. As decisoes operacionais de runtime Supabase, guest auth e escrita service-role-only ja estao tomadas.

## Pendencias Ativas

| ID | Sistema | Bloqueia | Pergunta | Impacto | Documento destino | Status | Resolvido em |
|---|---|---|---|---|---|---|---|
| DMOB-D001 | Escopo | PRIMEIRO_SLICE | O primeiro slice completo usa cap de level 10, 40 ou outro recorte dentro da Season 1? | Afeta unlocks, economia, conteudo jogavel e criterio de aceite. | `../implementation/tracks/track-00-first-slice-foundation/scope.md` | ABERTO | - |
| DMOB-D002 | Progressao | PRIMEIRO_SLICE | Quais sao os gatilhos exatos de unlock de slots de spell, passiva e pet? | Bloqueia onboarding, schema de build e menus da base. | `game-design-document.md` | ABERTO | - |
| DMOB-D003 | Base Manager | PRIMEIRO_SLICE | Quais stats a Estrutura de Stats altera, quanto por level e com qual custo/recurso? | Predio existe no slice, mas nao tem mecanica implementavel. | `game-design-document.md` | ABERTO | - |
| DMOB-D004 | Ossario | PRIMEIRO_SLICE | Qual e a taxa de producao de Ossos por level e o limite de armazenamento do Ossario? | Bloqueia crafting da varinha e economia de Ossos. | `game-design-document.md` | ABERTO | - |
| DMOB-D005 | Construcoes | PRIMEIRO_SLICE | Qual e o preco do segundo slot de construcao e quais regras mudam apos a compra unica? | Bloqueia loja, monetizacao e UX de fila. | `game-design-document.md` | ABERTO | - |
| DMOB-D006 | XP Livre | PLAYTEST_ALPHA | Quais sao os valores de XP por tipo/level de construcao e por quest? | Sem isso, progressao de conta nao pode ser testada. | `game-design-document.md` | ABERTO | - |
| DMOB-D007 | Energia | PLAYTEST_ALPHA | Qual curva de Energia e esperada para jogador free, battle pass e gasto com Diamante? | Bloqueia metas de playtest e validacao da economia. | `game-design-document.md` | ABERTO | - |
| DMOB-D008 | Recompensas | PLAYTEST_ALPHA | Quais sao as recompensas diarias e semanais exatas, limites e relacao com rewarded ads? | Bloqueia rotina diaria e economia inicial. | `game-design-document.md` | ABERTO | - |
| DMOB-D009 | Missoes | PRIMEIRO_SLICE | O sistema sera missoes diarias variadas ou apenas bonus das 3 primeiras vitorias? | Afeta UX, dados, recompensas e texto do produto. | `game-design-document.md` | ABERTO | - |
| DMOB-D010 | Onboarding | PRIMEIRO_SLICE | Quais quests iniciais existem, quais telas desbloqueiam e quais recompensas entregam? | Bloqueia primeira sessao e curva de entrada. | `game-design-document.md` | ABERTO | - |
| DMOB-D011 | Battle Pass | PRIMEIRO_SLICE | Qual conteudo existe em cada tier Free/Premium e em cada passe bimestral? | Bloqueia monetizacao funcional e recompensas de season. | `game-design-document.md` | ABERTO | - |
| DMOB-D012 | Diamante | PRIMEIRO_SLICE | Quais usos e precos absolutos do Diamante entram no primeiro slice? | Bloqueia loja, compras de tempo/recursos e tuning de pay progression. | `game-design-document.md` | ABERTO | - |
| DMOB-D013 | Guilda | PRIMEIRO_SLICE | Quais recursos entram nas contribuicoes de guilda, custos por level e bonus por construcao? | Bloqueia guilda funcional e impacto social na economia. | `game-design-document.md` | ABERTO | - |
| DMOB-D014 | Ajudas | PRIMEIRO_SLICE | Qual e o limite diario de ajudas que um jogador pode dar e receber? | Evita que redes grandes quebrem tempos de construcao. | `game-design-document.md` | ABERTO | - |
| DMOB-D015 | Ranking | PRIMEIRO_SLICE | Qual formula de ganho/perda de pontos de arena sera usada no primeiro slice? | Bloqueia ranking funcional e snapshots de season. | `game-design-document.md` | ABERTO | - |
| DMOB-D016 | Matchmaking | PRIMEIRO_SLICE | Qual faixa de poder inicial e fallback para matchmaking real/bot? | Bloqueia o fluxo PVP com poucos jogadores. | `game-design-document.md` | ABERTO | - |
| DMOB-D017 | Bots | PRIMEIRO_SLICE | Como gerar builds simuladas por faixa de poder e quais combinacoes precisam cobrir? | Bloqueia alpha com 2-20 jogadores. | `contracts/content-definitions.md` | ABERTO | - |
| DMOB-D018 | Summons | PRIMEIRO_SLICE | Qual escala de HP e dano dos summons por level de spell? | Bloqueia simulador completo com Invocar Demonio e Animar Morto. | `game-design-document.md` | ABERTO | - |
| DMOB-D019 | Maestria | PRIMEIRO_SLICE | Dano de summons conta para maestria da spell invocadora? | Afeta progressao permanente e telemetria de combate. | `game-design-document.md` | ABERTO | - |
| DMOB-D020 | Stats | PRIMEIRO_SLICE | Qual e a curva de Regen Vida e Regen Mana por level e fontes externas? | Bloqueia simulacao completa e duracao de batalha. | `game-design-document.md` | ABERTO | - |
| DMOB-D021 | Varinha | PRIMEIRO_SLICE | Quais qualidades de varinha existem no primeiro slice e quais custos de Ossos? | Bloqueia crafting e progressao de arma. | `game-design-document.md` | ABERTO | - |
| DMOB-D022 | Cosmeticos | PRIMEIRO_SLICE | Quais cosmeticos entram no primeiro slice e quais ficam apenas como categoria futura? | Bloqueia loja/recompensas se cosmeticos forem usados no Battle Pass. | `game-design-document.md` | ABERTO | - |
| DMOB-D023 | Chat | PRIMEIRO_SLICE | Qual politica de retencao, delecao, bloqueio e moderacao para mensagens de guilda/direct? | Bloqueia chat seguro para alpha e prepara LGPD/GDPR. | `architecture.md` | ABERTO | - |
| DMOB-D024 | Telemetria | PRIMEIRO_SLICE | Qual telemetria minima precisa existir no primeiro slice? | Sem eventos minimos, alpha nao informa balanceamento. | `architecture.md` | ABERTO | - |
| DMOB-D025 | Visual/UX | PRIMEIRO_SLICE | Qual estilo visual e layout base do Santuario, batalha, social e loja? | Bloqueia UI final e comunicacao do tema cartoon gore. | `product-brief.md` | ABERTO | - |
| DMOB-D026 | Build/Schema | PRIMEIRO_SLICE | Como representar spells desbloqueadas vs equipadas e slots no schema vivo? | Afeta performance, migracoes e menus de build. | `contracts/database-schema.md` | ABERTO | - |
| DMOB-D027 | Anuncios | PRIMEIRO_SLICE | Quais recompensas usam rewarded ads e qual pacote remove anuncios? | Bloqueia recompensas diarias/semanais e monetizacao. | `game-design-document.md` | ABERTO | - |
| DMOB-D028 | Conquistas | PRIMEIRO_SLICE | Quais conquistas entram no primeiro slice e quais recompensas entregam? | Bloqueia recompensas unicas e objetivos de longo prazo. | `game-design-document.md` | ABERTO | - |
| DMOB-D029 | Poder | CALIBRAVEL_ALPHA | Quais pesos finais da formula de poder apos incluir summons e todos os upgrades? | Pode iniciar com pesos atuais, mas precisa calibrar com dados. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D030 | Balanceamento | CALIBRAVEL_ALPHA | Quais valores finais de dano, cooldown, mana, DoT, pet, passiva e anti-stall? | Pode nascer com valores iniciais, mas precisa tuning no alpha. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D031 | Guilda | CALIBRAVEL_ALPHA | Os bonus de guilda estao leves o suficiente para nao serem obrigatorios? | Tuning social/economico precisa dados reais. | `game-design-document.md` | CALIBRAR | - |
| DMOB-D032 | Diamante | CALIBRAVEL_ALPHA | A economia de Diamante cobre o gap esperado sem substituir gameplay? | Requer observacao de progressao free vs paga. | `game-design-document.md` | CALIBRAR | - |
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
