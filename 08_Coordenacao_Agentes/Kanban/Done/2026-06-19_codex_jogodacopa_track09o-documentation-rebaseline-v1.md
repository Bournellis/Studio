# JogoDaCopa - Track 09O Documentation Rebaseline V1

Data: 2026-06-19
Agente: Codex
Branch/worktree: `codex/jogodacopa/track09o-documentation-rebaseline-v1` em `D:\Estudio-worktrees\JogoDaCopa--codex--track09o-documentation-rebaseline-v1`

## Objetivo

Reorganizar a documentacao viva do `JogoDaCopa` depois da publicacao aprovada da Track 09N, separando estado atual, contratos, historico e evidencias brutas.

## Resultado

- `work-plan.md` agora trata a 09N como baseline publica aprovada e aponta a proxima reducao local do `FootballRoot`.
- Planos antigos das series 02, 03, 04 e 06 foram marcados como historicos.
- `implementation/current-status.md` foi compactado para snapshot vivo, sem listas repetitivas gigantes.
- `docs/documentation-index.md` foi reorganizado em estado vivo, publicacao atual, arquitetura/contratos, evidencias e historico.
- `bot-contract.md` foi atualizado com boost, SUPER, dificuldade, kickoff defensivo e separacao do FPS.
- `tuning-guide.md` agora trata Track 01B/01C como baseline historica e define a postura pos-09N.
- A card de publicacao 09N recebeu nota posterior apontando o reteste humano aprovado.
- Nenhuma evidencia bruta JSON/PNG foi movida.

## Arquivos Atualizados

- `08_Coordenacao_Agentes/Kanban/Done/2026-06-19_codex_jogodacopa_track09n-publication-v1.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`
- `Projetos/JogoDaCopa/docs/bot-contract.md`
- `Projetos/JogoDaCopa/docs/tuning-guide.md`
- `Projetos/JogoDaCopa/docs/release-plan.md`
- `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`
- `Projetos/JogoDaCopa/docs/arcade-upgrade-plan.md`
- `Projetos/JogoDaCopa/docs/next-series-options.md`
- `Projetos/JogoDaCopa/docs/series-06-broadcast-polish-plan.md`

## Validacao

- `tools/check_doc_drift.ps1`: PASS.
- `git diff --check`: PASS.
- Busca direcionada por estados defasados da 09N: sem pendencia da 09N; os unicos hits de "aguardando" pertencem ao estado vivo de outros projetos.
- Cobertura do indice sobre Markdown de topo: PASS.

## Fora Do Escopo

- Nenhum codigo alterado.
- Nenhuma cena, asset, export, pacote Web ou publicacao alterada.
- Nenhuma mudanca de gameplay, tuning, bot, fisica, scoring, HUD ou render.

## Handoff

Baseline publica aprovada continua: Track 09N / `Super Campeao v1.2.1+5c6520ba`.

Proximo trabalho recomendado: planejar a proxima reducao local do `FootballRoot` a partir da 09N aprovada.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
