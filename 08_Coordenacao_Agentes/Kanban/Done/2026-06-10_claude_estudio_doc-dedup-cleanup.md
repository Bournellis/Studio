# Tarefa: Estudio - Avaliacao Externa + Dedup De Estado Documental

## Metadata

- id: `2026-06-10_claude_estudio_doc-dedup-cleanup`
- owner: `Claude`
- status: `Done`
- projeto: `estudio`
- prioridade_portfolio: `-`
- branch: `main` (trabalho direto autorizado explicitamente por Fabio nesta sessao)
- worktree: `D:\Estudio`

## Goal

Executar as recomendacoes P0/P1 documentais da avaliacao externa `Avaliacao_Estudio_2026-06-10.md`: fonte unica de estado, compactacao de snapshots, consolidacao dos docs de agente do DraxosMobile, roteamento enxuto, script anti-drift, decisoes retroativas e limpeza de residuos.

## Delivered

- `Avaliacao_Estudio_2026-06-10.md` na raiz (avaliacao completa do estudio).
- README raiz, `CLAUDE.md`, `canon/canon-brief.md` e `AGENTS.md` raiz viraram docs-ponteiro sem estado; roteamento por keywords substituido por roteamento por dominio.
- `Estado_Atual.md` e `Prioridades_Estudio.md` compactados (max ~12 linhas por projeto); `Projetos/README.md` virou registry estavel.
- `Projetos/draxos-mobile/docs/release-history.md` criado como unico historico de pacotes (28 pacotes, URLs, version codes); AGENTS local, manual e current-status do mobile compactados para apontar para ele.
- `tools/check_doc_drift.ps1` criado: falha se docs-ponteiro tiverem markers/URLs/versions ou se snapshots tiverem linhas > 700 chars.
- 11 registros em `Decisoes/` (1 nova politica + 10 retroativos).
- Residuo `Projetos/FpsShooter/` (casca pos-split, 0 arquivos rastreados) removido.
- Pendencias de Track 02 planning commitadas separadamente antes do trabalho.

## Incidente Registrado

Durante a sessao, o `.git/index` foi corrompido por um lock orfao das 20:31 e o filesystem montado entregou rewrites com tamanho antigo (conteudo completo + padding de NUL, ou truncado quando o arquivo cresceu). Tres commits intermediarios (`e19b730`, `6e751d3`, `c8802a4`) contem blobs NUL-padded; `c4e3d3f` repara todos. Verificacao final: 0 NULs em todos os blobs do HEAD. Historia nao foi reescrita por seguranca.

## Validation

- `git diff --check`: PASS
- Simulacao do drift check (grep dos padroes proibidos nos docs-ponteiro): PASS, zero violacoes
- Checagem de NUL em todos os blobs alterados no HEAD: PASS (0 NULs)
- Godot/build/deploy: NOT RUN (escopo docs-only, precedente do ops doc hardening de 2026-06-09)
- `tools/check_doc_drift.ps1`: escrito mas NAO executado nesta sessao (sandbox Linux sem PowerShell); rodar uma vez no Windows para confirmar

## Follow-ups Recomendados

1. Rodar `tools/check_doc_drift.ps1` no Windows e corrigir qualquer falso positivo.
2. Criar git remote privado e fazer push (comandos preparados na conversa; checagem de secrets feita: apenas placeholders rastreados).
3. Em sessao com Godot: renomear `fps_*` em JogoDaCopa, quebrar testes monoliticos do mobile, atualizar referencias do painel HTML.
4. Investigar o processo que segurava `.git/index.lock` as 20:31 (IDE/cliente git aberto em `D:\Estudio`).
