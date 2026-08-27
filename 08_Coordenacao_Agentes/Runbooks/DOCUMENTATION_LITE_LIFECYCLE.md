# Documentation Lite v2 — lifecycle recuperável

## Metadata

- status: `active`
- authority: `runbook`
- last_verified: `2026-08-27`
- review_when: `o formato de card, ledger, receipt, recuperação ou autoridade documental mudar`
- supersedes: `lições dispersas de drift, snapshots, worktrees e escritor único`
- superseded_by: `none`

Este é o lifecycle obrigatório para história compacta e limpeza documental recuperável. O índice v2 está em `strict`; toda remoção histórica futura exige novo manifesto e nova aprovação exata.

## Cutover v2 concluído

- Índice aprovado: `d678bcfdb80174d5cdc80772241823861405d5893db593eee3cd73a123c597a9`.
- Baseline: `52f52f7cd33d1711579f9cccbe4c848ab45a02e4`.
- Tag local: `recovery/estudio-documentation-lite/v2/2026-07-17-pre-cutover`.
- Resultado: 19 batches, 915 fontes e 19 receipts; verificação global repetida sem reincidência.

## Autoridades e superfície normal

- `Prioridades_Estudio.md` decide foco, prioridade, status de portfólio e trabalho permitido.
- `Estado_Atual.md` é somente a projeção curta atualizada por `portfolio_sync`.
- Cada `implementation/current-status.md` é a única autoridade técnica local.
- Contratos vivos guardam comportamento vigente; `history.md` e ledgers guardam resultados antigos.
- Routers apontam para autoridades. Eles não carregam status, pacote, URL, próxima track ou narrativa histórica.

## Ciclo de uma tarefa

1. Abrir card local em `Backlog` ou `Doing` e registrar branch, worktree, escopo, validação e gates v3.
2. Trabalhar em worktree externa; nunca editar worktree de outro agente.
3. Manter decisão humana, resultado técnico e publicação como estados independentes.
4. Fazer commits lógicos, validar antes/depois do merge local e registrar o receipt de limpeza da worktree.
5. Usar `Review` somente enquanto uma decisão humana real estiver pendente.
6. Ao resolver uma tarefa sem gate pendente, absorver o resultado em autoridade viva ou ledger e retirar a narrativa operacional pelo protocolo Documentation Lite.

`Done` e handoff fechado são estados transitórios de fechamento, não arquivos históricos permanentes. Um handoff só existe quando há transferência real de responsabilidade.

## Cutover recuperável

- Cada caminho removível é literal, pertence a exatamente um record e aponta para retained authorities existentes.
- O manifesto registra blob Git, SHA-256, bytes, linhas, classificação, gate e fonte recuperável.
- Fabio aprova o SHA-256 exato do índice; qualquer alteração invalida a aprovação.
- `Execute` aceita um único batch, exige árvore limpa, tag no commit-base e ausência de overlap.
- A remoção e o receipt entram em commit próprio; `Verify` roda duas vezes.
- O Git é a recuperação integral; o ledger é a superfície histórica compacta. Nenhum dos dois redefine o estado atual.

## Recuperação local

Inspecionar sem restaurar:

```powershell
git show <baseline_commit>:<literal/path>
git cat-file -p <source_blob>
```

Restaurar é uma nova tarefa explícita: conferir receipt e SHA-256, recuperar somente o caminho literal, validar e commitar separadamente. Nunca usar checkout/reset amplo para isso.

## Drift, snapshots e links

- Status vivo responde apenas verdade atual, gate, risco, validação recente e próxima leitura.
- Toda referência histórica retirada do `HEAD` usa `baseline_commit:path`, blob ou receipt; link Markdown quebrado não é aceito.
- Procure drift por `latest`, pacote, URL, `próximo passo`, track ativa e vocabulário de projeto antigo.
- `DocsOnly` e `StudioDoctor Core` verificam metadata, links, pointers, estado, receipts e reincidência.

## Worktrees e escritor único

- Antes de tocar globais: `git status --short`, `git worktree list` e leitura das autoridades.
- Um escritor por worktree e por índice Git. IDE/GitHub Desktop não faz stage, discard ou commit enquanto o agente escreve naquela árvore.
- Commit usa paths explícitos e diff auditado. Mudança inesperada interrompe o lote.
- O helper de fechamento permanece local. Depois dele, somente o coordenador global executa a sincronização Git segura delegada em `GIT_SAFE_PUSH.md`; `pull`, login/token, refs extras e publicação de produto permanecem fora do fluxo.

## Incidentes preservados

Em 2026-06-10/11 houve `index.lock` órfão, índice/config corrompidos e bytes NUL por escritores concorrentes e reescrita incompleta. Sinais: `bad signature`, `bad config`, NUL no final ou arquivo visto apenas como prefixo do blob.

O reparo começa com diagnóstico read-only. Lock só pode ser removido depois de confirmar ausência de processo Git; índice pode ser reconstruído de `HEAD` sem tocar arquivos de trabalho.

Em filesystem suspeito, confirme blob, tamanho, diff e integridade antes de stage. Nunca commite um índice obsoleto ou um falso dirty.

## Hard stops

Pare o batch em conflito semântico, autoridade ausente, hash/blob divergente, `Review` selecionado, segredo, binário/cena ambígua, diff de gerador inesperado, remoto/publicação, mudança de produto/prioridade ou decisão humana necessária.
