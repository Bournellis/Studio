# Track 04 - Post-Handoff Hardening And Hub Modularization

- Status: `PLANNED_AFTER_CLOSED_PLAYTEST`
- Projeto: `draxos-mobile`
- Dependencia inicial: rodada fechada Fabio + tester da Internal Alpha v0.
- Objetivo: transformar feedback real do handoff em correcoes pequenas, melhorar UX Android/onboarding e reduzir a divida tecnica do Hub sem mudar comportamento nem misturar refatoracao com backend/schema.

## Problema

`T03-P18` entregou uma build fechada jogavel, publicada e validada. O Hub Godot ficou grande porque precisou compor login, update gate, batalha, base, social, competicao, loja, labs e estados de save em uma mesma superficie.

Antes de expandir sistemas, o projeto precisa:

- observar a build em uso real por Fabio + tester;
- corrigir bugs bloqueantes antes de qualquer refatoracao;
- melhorar ergonomia Android e onboarding se o playtest confirmar atrito;
- modularizar o Hub em etapas pequenas, preservando comportamento;
- decidir com evidencia se o schema `players.save_type` precisa virar `account_profiles` + `game_saves`.

## Ordem De Prioridade

1. Rodada fechada Fabio + tester.
2. Triagem de bugs bloqueantes e regressões do alpha.
3. UX Android/onboarding do fluxo real.
4. Modularizacao do Hub Godot por superficies.
5. Rodada humana do Progression Lab.
6. Decisao sobre schema `account_profiles` + `game_saves`.

## Entregas

- Backlog pos-playtest classificado por bloqueante, UX, tuning, divida tecnica e futuro.
- Passada de UX Android/onboarding quando houver feedback real.
- Plano incremental para separar `modes/boot/boot.gd` por superficie.
- Primeira extracao de presenters/telas sem mudanca de comportamento.
- GUT/smoke preservados apos cada extracao.
- Relatorio humano do Progression Lab para 2h, 5h, 10h, 15h e 20h.
- Decisao registrada sobre manter `players.save_type` ou planejar `account_profiles` + `game_saves`.

## Modularizacao Do Hub

Superficies alvo:

- shell/login/update;
- batalha;
- base;
- social;
- competicao;
- loja;
- labs dev-only, se forem tocados depois das telas principais.

Regras:

- Primeira etapa extrai somente presenters/telas sem alterar comportamento.
- `boot.gd` deve permanecer como composicao fina por enquanto.
- Nao refatorar backend, schema ou contratos no mesmo pacote da extracao de UI.
- Cada tela extraida precisa preservar o smoke/GUT atual antes de seguir para a proxima.
- Mudancas de UX devem ser commits separados de movimentacao estrutural.

## Conta/Save

Gate futuro: migrar de `players.save_type` para modelo explicito:

- `account_profiles` para identidade e dados da conta;
- `game_saves` para saves por tipo/modo;
- tabelas de gameplay apontando para save quando fizer sentido.

Nao executar essa migracao antes do playtest Fabio + tester, salvo bug real de isolamento, seguranca ou corrupcao de save.

## Progression Lab Humano

Apos o playtest inicial, rodar rodada humana cobrindo:

- milestones: 2h, 5h, 10h, 15h e 20h;
- perfis: free, freemium, light e max;
- observacoes: premium gap, janelas 15h/20h, poder, bots, ritmo de recursos, clareza de objetivo e cansaco de rotina.

Resultados devem alimentar ajustes de premium gap, janelas 15h/20h, poder e bots.

## Fora Do Escopo

- Pagamento real.
- iOS.
- Mobile browser.
- Expansao de modos.
- Rework visual completo.
- Migracao de schema sem evidencia do playtest.
- Refatoracao simultanea de backend e Hub.
- Mudanca de contratos de combate/economia durante extracao de UI.

## Criterios De Aceite

- Feedback da rodada Fabio + tester registrado antes de iniciar refatoracao grande.
- Bugs bloqueantes tratados antes de melhorias esteticas.
- UX Android/onboarding ajustados apenas quando houver problema observado ou risco claro.
- `boot.gd` fica menor por extracao progressiva de telas/presenters, sem regressao funcional.
- Validacao Godot relevante passa apos cada extracao.
- Account/save schema tem decisao documentada antes de qualquer migration.
- Progression Lab humano gera recomendacoes concretas para premium gap, janelas 15h/20h, poder e bots.
