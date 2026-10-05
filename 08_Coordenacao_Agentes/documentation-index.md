# Documentation Index - Estudio

## Metadata

- status: active
- authority: router
- last_verified: 2026-10-05
- review_when: authority map or official project registry changes
- supersedes: documentation-index.md before Governance v2
- superseded_by: none

Mapa de consulta. Prioridade, estado técnico e história mantêm suas autoridades.

## Orientação e estado

- [AGENTS](../AGENTS.md): contrato operacional.
- [Prioridades](Prioridades_Estudio.md): foco e trabalho permitido.
- [Projetos](../Projetos/README.md): entradas locais.
- [Estado atual](Estado_Atual.md): projeção global.
- [Fila de sincronização](PortfolioSync_QUEUE.md): atos de atualização.
- [Painel Fabio](FABIO_DASHBOARD.html): consulta humana derivada.
- Estados locais: Projetos/<projeto>/implementation/current-status.md.

## Recuperação e referência condicional

- História técnica: implementation/history.md e history-ledger/ locais.
- Decisoes/: decisões por assunto; consulta não retoma trabalho.
- History/: registros compactos preservados.
- Receipts/DocumentationLite/: fonte literal, baseline, blob e SHA-256.
- [Preservação 2026-10-05](History/preservation-20261005/README.md): fontes e destinos.
- [Lifecycle documental](Runbooks/DOCUMENTATION_LITE_LIFECYCLE.md):
  recuperação e aprovação de futuras exclusões históricas.
- Registers/: classificações e manifestos; presença não autoriza remoção.
- Templates/ e Runbooks/: consulta somente para a operação escolhida.
- [Git seguro](Runbooks/GIT_SAFE_PUSH.md): sincronização delegada.
- Projetos/_conceitos/, canon/shared-lore/ e guias históricos:
  referências preservadas; use caminho explícito quando necessário.

## Lore e contratos locais

- [Studio Core](../STUDIO_CORE.md): autoridades temáticas e registro de vínculos.
- Cada STUDIO_CORE.md local declara os domínios adotados.
- [Fronteiras](../canon/studio-conventions/project-boundaries.md): adoção local.
- Canon de produto isométrico: Projetos/rpg-isometrico/docs/canon/.
- Demais contratos de produto, arquitetura e QA: projeto escolhido.
- Tooling: [tools/README.md](../tools/README.md).

Recuperação começa pela autoridade retida e pelo receipt. Fontes anteriormente
removidas são inspecionadas no Git, sem recriar stubs.
