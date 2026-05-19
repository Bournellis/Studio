# Track 00 - Implementation Plan

- Ultima atualizacao: `2026-05-19`
- Status: pronto para iniciar implementacao apos preparacao documental

## Sequencia

### T00-P00 - Preparacao Documental

Criar escopo, MVP tecnico, contratos, pendencias de design e prompts atomicos. Nao cria codigo de jogo.

Aceite: `../../../docs/design-pending.md`, `../../../docs/contracts/`, `scope.md`, `mvp-technical-definition.md`, `implementation-plan.md` e `implementation-prompts.md` existem e estao linkados pelo status.

### T00-P01 - Inicializacao Godot

Inicializar Godot 4.6.2 no projeto, configurar pastas reais, cena boot minima, autoloads basicos e GUT.

Aceite: projeto abre headless e `tools/validate.gd` executa check minimo.

### T00-P02 - Supabase Base

Configurar Supabase local-first com migrations minimas, Edge Function healthcheck e instrucoes de ambiente.

Aceite: migrations aplicam em ambiente limpo e healthcheck responde.

### T00-P03 - Conta Guest MVP

Implementar convite, conta guest, estado inicial de player, resources e build fixture.

Aceite: convite valido cria conta; convite invalido falha sem criar player.

### T00-P04 - Battle Request MVP

Implementar `battle/request` com bot fixture, seed deterministica, log `battle_log_v1`, gravacao de resultado e recompensa `MVP_ONLY`.

Aceite: teste server cobre sucesso, auth ausente e idempotencia de resultado.

### T00-P05 - Cliente MVP

Conectar Godot ao Supabase, criar tela minima e exibir log placeholder.

Aceite: fluxo guest -> battle/request -> resultado funciona no cliente.

### T00-P06 - Conteudo Real Do Primeiro Slice

Expandir JSONs e contratos para spells, pets, passivas, estruturas, bots e faixas de poder.

Aceite: validacao de schema de conteudo passa.

### T00-P07 - Simulador Completo

Implementar combate server-authoritative com varinha, spells, DoTs, barreiras, status, pets, passivas, summons e anti-stall.

Aceite: testes server cobrem regras centrais e replay deterministico.

### T00-P08 - Cliente De Batalha Completo

Animar log completo, replay, skip e velocidade visual.

Aceite: cliente nao calcula resultado e tolera eventos desconhecidos versionados.

### T00-P09 - Base Manager E Economia

Implementar estruturas, upgrades, coleta offline, recursos, armazenamento, cotas e recompensas.

Aceite: servidor valida cap por level, custos e idempotencia de mutacoes.

### T00-P10 - Social, Matchmaking, Bots E Ranking

Implementar amigos, guilda, ajudas, chat por polling, matchmaking real/bot e ranking de season.

Aceite: usuarios nao acessam dados alheios; bots nao aparecem em ranking.

### T00-P11 - Monetizacao Funcional E Alpha

Implementar Battle Pass, Diamante, recompensas diarias/semanais, fluxos alpha e smoke de export.

Aceite: exports PC, Android e PC browser passam smoke; status muda para pronto para playtest alpha.

## Regra De Avanco

Cada passo deve:

- Atualizar `../../current-status.md`.
- Atualizar docs afetados quando contratos mudarem.
- Adicionar ou atualizar testes antes de marcar completo.
- Nao resolver design ad hoc; registrar em `../../../docs/design-pending.md` se faltar decisao.
