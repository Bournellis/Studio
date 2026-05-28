# Track 13 - Manual Walkthrough Gate

Track 13 entrega este gate e template. A execucao manual real pode ocorrer depois e nao bloqueia a conclusao da Track 13.

## Platform Matrix

Android / Windows / Web preview / Web Access-protected

| Plataforma | Build/hash | Executor | Data | Resultado | Severidade | Screenshot opcional | Bloqueio | Follow-up |
|---|---|---|---|---|---|---|---|---|
| Android APK |  |  |  |  |  |  |  |  |
| Windows ZIP/exe |  |  |  |  |  |  |  |  |
| Web preview |  |  |  |  |  |  |  |  |
| Web Access-protected |  |  |  |  |  |  |  |  |

## Required Flows

| Fluxo | Android | Windows | Web preview | Web Access-protected | Resultado | Severidade | Screenshot opcional | Bloqueio | Follow-up |
|---|---|---|---|---|---|---|---|---|---|
| Entry |  |  |  |  |  |  |  |  |  |
| Login/signup |  |  |  |  |  |  |  |  |  |
| Save normal |  |  |  |  |  |  |  |  |  |
| Progression Lab |  |  |  |  |  |  |  |  |  |
| Refugio |  |  |  |  |  |  |  |  |  |
| Base |  |  |  |  |  |  |  |  |  |
| Batalha |  |  |  |  |  |  |  |  |  |
| Summary |  |  |  |  |  |  |  |  |  |
| Logs |  |  |  |  |  |  |  |  |  |
| Social |  |  |  |  |  |  |  |  |  |
| Competicao |  |  |  |  |  |  |  |  |  |
| Loja |  |  |  |  |  |  |  |  |  |
| Update gate |  |  |  |  |  |  |  |  |  |

## Scenario Template

Use uma entrada por plataforma e fluxo quando houver comportamento relevante.

| Campo | Valor |
|---|---|
| Build/hash |  |
| Plataforma |  |
| Executor |  |
| Data |  |
| Fluxo/cenario |  |
| Resultado | `PASS` / `FAIL` / `BLOCKED` / `NOTE` |
| Severidade | `S0` bloqueador, `S1` alto, `S2` medio, `S3` baixo |
| Screenshot opcional |  |
| Bloqueio |  |
| Follow-up |  |

## Acceptance

- Cada plataforma relevante tem build/hash identificado.
- Login/signup e recuperacao de save sao testados sem reset silencioso.
- Progression Lab fica isolado do save normal.
- Batalha continua server-authoritative: cliente apenas solicita, anima ou pula replay e mostra summary/logs.
- Base, Social, Competicao e Loja nao calculam recurso/recompensa local.
- Update gate mostra estado correto para app atual, recomendado e obrigatorio.
- Cloudflare Access-protected pode ser marcado como protegido esperado quando a sessao/preview apropriada nao estiver disponivel.

## Track 13 Boundary

Este documento e o artefato gate. A rodada manual real deve ser registrada em um relatorio futuro antes de novas features, tuning numerico ou migration de conta/save.
