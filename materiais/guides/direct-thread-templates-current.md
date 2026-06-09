# Direct Thread Templates - Current

Copy one of these into a new thread when starting focused work.

## Estudio Portfolio Docs

```text
Projeto: estudio
Tipo: DocsOnly
Objetivo: sincronizar docs de portfolio/coordenacao com o estado operacional atual.
Base obrigatoria:
- D:\Estudio\08_Coordenacao_Agentes\Prioridades_Estudio.md
- D:\Estudio\AGENTS.md
- D:\Estudio\Projetos\README.md
- D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md
Escopo:
- D:\Estudio\README.md
- D:\Estudio\08_Coordenacao_Agentes\
- D:\Estudio\Projetos\README.md
Validacao:
- git diff --check
- rg drift checks contra status antigo e proximo passo antigo
```

## Draxos Roguelike Content Lab

```text
Projeto: draxos-roguelike-cardgame
Tipo: Implementation
Objetivo: criar ou validar proposal packs do Design Lab.
Escopo:
- Projetos/draxos-roguelike-cardgame/data/lab/design/
- Projetos/draxos-roguelike-cardgame/docs/design-lab.md
Validacao:
- tools/validate.gd
- focused Design Lab / Card Impact / Run Lab gates conforme risco
```

## DraxosMobile Scoped Work

```text
Projeto: draxos-mobile
Tipo: Client | Backend | Docs | Validation | Release
Objetivo: <resultado delimitado>
Base obrigatoria:
- Projetos/draxos-mobile/AGENTS.md
- Projetos/draxos-mobile/docs/agent-operating-manual.md
- Projetos/draxos-mobile/docs/documentation-index.md
- Projetos/draxos-mobile/implementation/current-status.md
Escopo:
- <paths>
Fora do escopo:
- tuning amplo
- PVP
- economia ampla
- mutacao remota/publicacao sem pedido explicito
Validacao:
- git diff --check
- tools/validate_foundation.ps1 -Profile <profile>
```

## Paused Project Historical Query

```text
Projeto: rpg-isometrico | rpg-turnos
Tipo: Historical
Objetivo: consultar contexto historico especifico.
Regra:
- leitura apenas
- nao implementar
- nao selecionar track/gate
- nao promover mecanica para projeto ativo sem documento local
```
