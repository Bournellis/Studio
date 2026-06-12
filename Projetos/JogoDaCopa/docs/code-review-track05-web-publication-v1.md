# Code Review PRE-MERGE - Track 05 Web Publication V1

- Date: `2026-06-12`
- Reviewer: Claude (Fable 5)
- Branch: `codex/jogodacopa/track05-web-publication-v1`
- Veredito: **APROVADA PARA MERGE**

## Fato central

`Copa Arena Futebol` esta PUBLICO em `https://copa-arena-futebol.pages.dev/` (deploy `7a19a00f`, release root `web/v1-copa-arena-futebol-20260612-31e23ea3`), conforme autorizacao explicita da decisao `2026-06-12_jogodacopa_publicacao-web-cloudflare.md`.

## Auditoria do pipeline (`tools/publish_web.ps1`, 483 linhas)

- Modos `Plan` (default) / `Package` (local) / `FullPublish`, com `FullPublish` exigindo `-ConfirmRemoteMutation` - padrao do estudio respeitado; a decisao autorizou a mutacao remota desta track.
- ZERO secrets no script/repo (varrido: token/key/password/bearer/account) - wrangler via `npx` com credencial do ambiente do sistema.
- Solucao para o limite de 25 MiB/arquivo do Pages: `index.pck`/`index.wasm` pre-comprimidos Brotli q11 sob os nomes originais com `Content-Encoding: br` - VALIDADA pelo smoke remoto real.
- Artefatos de cada fase versionados como JSON (release/package/publication report).

## Evidencia remota verificada

- Smoke oficial na URL publicada: `noPageErrors=true`, `noConsoleErrors=true`, menu interativo renderizado (screenshot conferido: personagem uniformizado, gol neon, painel completo).
- Perf probe remoto registrado (30s de coleta com `?jdc_perf=1`).

## Itens menores (follow-ups pos-publicacao, nao bloqueiam)

- M1: NAO ha versao visivel (vX.Y.Z) no menu publicado - para suporte/hotfix durante a Copa, exibir `v1.0.0`+hash curto no rodape do menu. Follow-up rapido recomendado como primeiro item pos-merge.
- M2: rodape do menu publicado ainda diz `PC Windows editor-first` - anacronico num build web publico; trocar por creditos/versao no mesmo follow-up.
- M3: smoke HUMANO de Fabio na URL estavel (primeira visita real, jogar uma partida) - pendencia aberta no handoff; o gate de maquina passou, falta o juiz.
- M4: fundo do hero do menu remoto aparece azul-marinho (Compatibility) vs preto do desktop - dentro da divergencia de perfil ja aceita; observar na decisao de paridade se incomodar.

## Pos-merge

Merge local em main + card Done + snapshots como atualizados pela branch + `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`. Proximas candidatas ja registradas: follow-up M1/M2 (versao/rodape), Track 04F.3 (VFX/audio first-use warmup, adiada por decisao), segundo canal itch.io (decisao registrada como possivel).
