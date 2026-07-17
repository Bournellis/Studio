# Direct Thread Templates - Current

## Metadata

- status: `active`
- authority: `runbook`
- last_verified: `2026-07-17`
- review_when: `routing, local-first or validation contracts change`
- supersedes: `direct-thread-templates-current.md before Documentation Lite`
- superseded_by: `none`

Copy one of these into a new task when starting focused work.

## Estudio Portfolio Or Governance

```text
Projeto: estudio
Tipo: portfolio_sync | global_governance | documentation_alignment
Objetivo: <resultado global delimitado>
Base obrigatoria:
- D:\Estudio\AGENTS.md
- D:\Estudio\08_Coordenacao_Agentes\Prioridades_Estudio.md
- D:\Estudio\Projetos\README.md
- D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md
Escopo: <shared paths explicitamente nomeados>
Validacao:
- .\tools\validate_estudio.ps1 -Profile DocsOnly -Project AllOfficial
- git diff --check
```

## Project-Local Work

```text
Projeto: <official project>
Tipo: Implementation | Documentation | Validation | Review
Objetivo: <resultado delimitado>
Base obrigatoria:
- AGENTS.md
- 08_Coordenacao_Agentes/Prioridades_Estudio.md
- Projetos/<project>/AGENTS.md
- Projetos/<project>/implementation/current-status.md
Escopo: Projetos/<project>/<paths>
Coordenacao: Projetos/<project>/08_Coordenacao/
Validacao: <smallest typed profile from qa/QA_INDEX.md>
```

## DraxosMobile Scoped Work

```text
Projeto: draxos-mobile
Tipo: Client | Backend | Docs | Validation | Release preparation
Objetivo: <resultado delimitado>
Base obrigatoria:
- Projetos/draxos-mobile/AGENTS.md
- Projetos/draxos-mobile/implementation/current-status.md
- Projetos/draxos-mobile/08_Coordenacao/TRIAGE.md
- Projetos/draxos-mobile/qa/QA_INDEX.md
Escopo: <paths>
Fora do escopo: tuning amplo, PVP, economia, remoto e publicacao sem decisao explicita
Validacao: <typed local profile>
```

## Paused Project Consultation Or Integrity

```text
Projeto: <paused project>
Tipo: Historical | Governance | Integrity
Objetivo: consultar ou reparar integridade explicitamente autorizada
Regra:
- confirmar permissao em Prioridades_Estudio.md
- nao retomar produto nem selecionar nova track
- nao promover mecanica para outro projeto sem adocao local
```
