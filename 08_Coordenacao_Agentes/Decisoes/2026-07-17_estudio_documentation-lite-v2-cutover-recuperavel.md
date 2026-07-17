# Decisao: Documentation Lite v2 - cutover recuperavel

## Metadata

- status: `active`
- authority: `operational_contract`
- last_verified: `2026-07-17`
- review_when: `the exact cleanup manifest changes or recovery validation fails`
- supersedes: `cleanup limitation in 2026-07-17_estudio_governanca-v21-integridade-producao.md`
- superseded_by: `none`
- data: `2026-07-17`
- decisor: `Fabio`
- projeto: `estudio`
- coordination_scope: `global_governance`
- prioridade_portfolio: `unchanged`

## Contexto

A Governanca v2.1 preparou a classificacao historica, mas manteve Done, handoffs encerrados e tracks no HEAD. Fabio autorizou executar o Documentation Lite no Estudio inteiro com curadoria semantica, commits separados, multiagentes e merge local final.

## Decision

O Estudio adotara um ciclo strict sem Done permanente: historia resolvida sera absorvida por autoridades vivas, ledgers mensais e receipts recuperaveis por commit-base, blob e SHA-256. Nenhum caminho sera removido sem manifesto literal, autoridade retida e aprovacao do hash exato por Fabio.

## Alternatives Considered

- Manter todo o acervo no HEAD e apenas exclui-lo da busca.
- Remover narrativas mecanicamente e depender somente do Git.

## Impact

O trabalho reduz a superficie documental normal sem alterar produto, prioridade, gate humano, release ou runtime. Projetos pausados recebem apenas governanca e integridade. `D:\Minigame Studio` permanece read-only e nenhuma operacao remota e autorizada.

## Review When

Revisar se um batch contiver historia unica sem destino, se o baseline mudar depois da aprovacao ou se o modelo strict impedir uma transferencia ativa real.

## Historical Compatibility

Claude/OpenClaw are `historico/deprecated` actors and may appear only in historical records or explicit compatibility wording.
