# Estudio Status Slimming Plan

- Data: `2026-06-29`
- Tipo: plano documental; nao aplica mudancas de status.
- Origem: transferencia dos aprendizados de organizacao do `D:\Minigame Studio` para `D:\Estudio`.

## Objetivo

Reduzir a friccao de entrada dos agentes e do Fabio mantendo os snapshots vivos curtos, decision-oriented e separados do historico de tracks/publicacoes.

Este plano nao deve apagar historico. A regra e mover detalhe para o lugar certo, nao descartar informacao.

## Principios adotados

1. `Prioridades_Estudio.md` responde: foco, status, trabalho permitido e proximo passo de portfolio.
2. `Estado_Atual.md` responde: snapshot curto por projeto.
3. `Projetos/<Projeto>/implementation/current-status.md` responde: verdade local atual, gate atual, leitura seguinte e validacao principal.
4. Historico longo vai para `implementation/tracks/`, `docs/release-history.md`, Kanban Done ou Handoffs.
5. `FABIO_DASHBOARD.md/html` responde: decisao humana rapida; nao e fonte tecnica.

## Tamanho observado em 2026-06-29

| Arquivo | Linhas | Observacao |
|---|---:|---|
| `Projetos/JogoDaCopa/implementation/current-status.md` | 183 | Snapshot local acumulou bastante historico de tracks, publicacoes e fallbacks. |
| `Projetos/draxos-mobile/implementation/current-status.md` | 106 | Ainda aceitavel para complexidade operacional, mas mistura pacote atual, lineage e decisoes abertas. |
| `Projetos/FpsPlayground/implementation/current-status.md` | 101 | Bom como status tecnico, mas Track History pode migrar para historico se crescer. |
| `Projetos/draxos-roguelike-cardgame/implementation/current-status.md` | 51 | Melhor exemplo atual de snapshot compacto com historico externo preservado. |
| `08_Coordenacao_Agentes/Estado_Atual.md` | 78 | Ainda passa drift check; manter compacto. |
| `08_Coordenacao_Agentes/Prioridades_Estudio.md` | 45 | Bom como tabela de portfolio. |

## Proposta por projeto

### JogoDaCopa

Problema: o `current-status.md` e util, mas esta carregando historico operacional detalhado de 09N ate 10D, incluindo tentativas bloqueadas, metricas remotas e fallback baselines.

Proposta futura:

- Manter no snapshot:
  - baseline atual aprovada;
  - fallback aprovado principal;
  - escopo atual;
  - gate atual resumido;
  - validacao principal;
  - proxima decisao.
- Mover para historico/release:
  - detalhes de Track 10B/10C/10D;
  - metricas remotas longas;
  - pacote/preview/release roots antigos;
  - sequencia 09N/09P/09Q/09S.
- Destinos provaveis:
  - `docs/release-history.md` para publicacoes/fallbacks;
  - `implementation/tracks/` para tracks individuais;
  - Kanban Done/Handoffs para evidencia operacional.

Nao aplicar sem uma revisao dedicada, porque esse arquivo preserva bastante contexto de publicacao Web.

### DraxosMobile

Problema: o status local ainda precisa ser detalhado por causa de Internal Alpha, Cloudflare, runtime_config, APK/PC/Web e hard stops. Ainda assim, parte da lineage de pacote pode viver apenas em `docs/release-history.md`.

Proposta futura:

- Manter no snapshot:
  - pacote tecnico atual;
  - diferenca entre hotfix Web e app/runtime package;
  - resultado humano atual;
  - hard stops de produto;
  - proxima prova humana.
- Mover/garantir que fique fora do snapshot:
  - artifact hashes extensos, se ja estiverem em release-history;
  - lista longa de evidencias de pacote;
  - remoto SQL/functions detalhado, salvo se for gate vivo.

Nao reduzir agressivamente: DraxosMobile tem risco operacional real.

### FpsPlayground

Problema: o `Track History` esta bom hoje, mas pode crescer indefinidamente.

Proposta futura:

- Manter no snapshot:
  - baseline atual;
  - latest track;
  - next sequence;
  - validation command;
  - read-next.
- Se passar de ~120 linhas, mover track history para:
  - `implementation/tracks/status-history-*.md` ou doc de roadmap/historico local.

### Draxos Roguelike Cardgame

Estado recomendado: manter como referencia de formato compacto.

Ele ja:
- preserva historico longo em arquivo separado;
- comunica active goal/gate;
- lista validacao em bullets;
- aponta read-next.

## Ordem recomendada para aplicar futuramente

1. Fazer uma auditoria dedicada de `JogoDaCopa/current-status.md`.
2. Criar/atualizar destino historico antes de remover texto do snapshot.
3. Aplicar reducao em commit separado, com diff facil de revisar.
4. Rodar `git diff --check` e `tools/check_doc_drift.ps1`.
5. Abrir o dashboard e confirmar que ele ainda resume a decisao humana correta.
6. Repetir para DraxosMobile apenas com cautela e se Fabio quiser reduzir friccao de leitura.

## Fora de escopo desta wave

- Reescrever `current-status.md` agora.
- Apagar historico.
- Alterar foco/status de portfolio.
- Mover cards Kanban.
- Deletar branch/worktree.
