# Track 00 - Implementation Prompts

- Ultima atualizacao: `2026-05-19`
- Uso: um prompt por execucao de agente

## Regras Para Todos Os Prompts

Os caminhos listados em `Arquivos permitidos` sao relativos a raiz do projeto `Projetos/draxos-mobile/`, salvo quando comecarem com `../../../`.

- Voce nao esta sozinho no repositorio; nao reverta alteracoes de outros agentes.
- Leia `../../../AGENTS.md`, `../../current-status.md`, `scope.md`, `mvp-technical-definition.md`, `../../../docs/design-pending.md` e contratos relevantes antes de editar.
- Se faltar decisao de design, registre em `../../../docs/design-pending.md` e pare antes de inventar regra.
- Toda mudanca de contrato deve atualizar `../../../docs/contracts/`.
- Toda etapa concluida deve atualizar `../../current-status.md`.

## T00-P00 - Preparacao Documental

Objetivo: preparar documentos de escopo, contratos, pendencias e prompts sem iniciar implementacao.

Arquivos permitidos:

- `AGENTS.md`
- `README.md`
- `docs/**`
- `implementation/**`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`

Validacao:

- Links relativos resolvem.
- Worktree nao contem codigo Godot/Supabase novo.

## T00-P01 - Inicializacao Godot

Objetivo: criar projeto Godot 4.6.2 minimo.

Saida esperada:

- `project.godot`
- cena boot minima
- `tools/validate.gd`
- GUT configurado
- pastas reais preservadas

Validacao:

- Godot headless abre o projeto.
- `tools/validate.gd` executa e reporta sucesso minimo.

## T00-P02 - Supabase Base

Objetivo: criar base Supabase local-first.

Saida esperada:

- `server/schema/` com migrations minimas do MVP.
- `server/functions/healthcheck/`.
- README de setup local/cloud.
- Arquivo de exemplo de env sem secrets reais.

Validacao:

- Migration aplica em banco limpo.
- Healthcheck responde localmente.

## T00-P03 - Conta Guest MVP

Objetivo: implementar convite e conta guest MVP.

Saida esperada:

- Edge Function de conta guest.
- Estado inicial de player/resources/build fixture.
- Cliente Godot salvando e validando sessao minima.

Validacao:

- Convite valido cria conta.
- Convite invalido falha.
- Estado inicial e recuperado apos reabrir.

## T00-P04 - Battle Request MVP

Objetivo: implementar batalha fixture server-authoritative.

Saida esperada:

- `battle/request` com seed deterministica.
- Bot `mvp_training_bot`.
- Log `battle_log_v1`.
- Resultado gravado e recompensa `MVP_ONLY` idempotente.

Validacao:

- Mesmo seed gera mesmo log.
- Cliente nao envia resultado.
- Repetir consulta nao duplica recompensa.

## T00-P05 - Cliente MVP

Objetivo: fechar loop tecnico no cliente Godot.

Saida esperada:

- Tela minima com guest, solicitar batalha, ver resultado.
- HTTPRequest para endpoints MVP.
- Timeline placeholder ordenada por `t`.

Validacao:

- Fluxo completo funciona em ambiente local.
- Falhas de rede/auth exibem erro controlado.

## T00-P06 - Conteudo Real Do Primeiro Slice

Objetivo: transformar fixtures em definicoes de conteudo versionadas.

Saida esperada:

- JSONs para spells, pets, passivas, estruturas, bots e faixas de poder.
- Validadores de schema.
- Contratos atualizados.

Validacao:

- Conteudo carrega sem erro.
- IDs estaveis e unicos.

## T00-P07 - Simulador Completo

Objetivo: implementar regras completas do autobattler server-side.

Saida esperada:

- Simulador deterministico com varinha, spells, DoTs, resistencias, barreiras, status, pets, passivas, summons e anti-stall.
- Testes server cobrindo regras principais.

Validacao:

- Replay por seed.
- Limite de duracao respeitado.
- Eventos gerados conforme contrato.

## T00-P08 - Cliente De Batalha Completo

Objetivo: animar o log completo sem calcular gameplay.

Saida esperada:

- Visualizador de batalha com replay, skip e velocidade.
- Tratamento de eventos desconhecidos por versao.

Validacao:

- Resultado exibido bate com servidor.
- Cliente nao altera recursos.

## T00-P09 - Base Manager E Economia

Objetivo: implementar base e economia servidor-side.

Saida esperada:

- Estruturas, upgrades, coleta offline, armazenamento, cotas e recompensas.
- Validacoes de cap universal e custos.

Validacao:

- Mutacoes sao idempotentes.
- Coleta offline respeita armazenamento.

## T00-P10 - Social, Matchmaking, Bots E Ranking

Objetivo: completar sistemas sociais e competicao.

Saida esperada:

- Amigos, guilda, ajudas, chat por polling.
- Matchmaking real/bot.
- Ranking de season.

Validacao:

- RLS impede acesso indevido.
- Bots nao entram no ranking.

## T00-P11 - Monetizacao Funcional E Alpha

Objetivo: fechar sistemas de alpha e monetizacao funcional.

Saida esperada:

- Battle Pass Free/Premium.
- Diamante e usos aprovados.
- Recompensas diarias/semanais.
- Smokes de export PC, Android e PC browser.

Validacao:

- Fluxos free e premium testados.
- Exports geram build smoke.
- `../../current-status.md` marca pronto para playtest alpha.
