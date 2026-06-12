# Tarefa: JogoDaCopa - Track 05 Web Publication V1 (Cloudflare Pages)

## Metadata

- id: `2026-06-12_jogodacopa-track05-web-publication-v1`
- owner: `Codex`
- status: `Review`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track05-web-publication-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track05-web-publication-v1`

## Goal

Publicar `Copa Arena Futebol` como build web publica no Cloudflare Pages (projeto `copa-arena-futebol`, sem Access), com URL estavel compartilhavel, smoke remoto na URL publicada e historico de release iniciado. Autorizacao de publicacao remota: `Decisoes/2026-06-12_jogodacopa_publicacao-web-cloudflare.md`.

## Start Registration

- Started at: `2026-06-12`
- Agent/worktree: `Codex` / `D:\Estudio-worktrees\JogoDaCopa--codex--track05-web-publication-v1`
- Branch: `codex/jogodacopa/track05-web-publication-v1`
- Base docs read: `Prioridades_Estudio.md`, `Estado_Atual.md`, `Projetos/README.md`, workspace `AGENTS.md`, local `Projetos/JogoDaCopa/AGENTS.md`, local `implementation/current-status.md`, this card, publication decision, `docs/publication-readiness.md`
- Intended files: Web export preset/build metadata, `tools/publish_web.ps1`, `tools/track04f_chrome_probe.mjs`, Track 05 docs/evidence, release history, publication readiness, project/studio status snapshots, Kanban/handoff records
- Validation plan: Godot import cache, `tools/validate.gd` full PASS, Web release export, local/package hash checks, Wrangler Pages publication with `-ConfirmRemoteMutation`, remote Chrome smoke JSON+screenshot, doc drift check
- Next handoff point: Claude review before merge

## Technical Scope (em ordem)

- `05A Release Export`: export Web em RELEASE (nao debug) com identidade aplicada (nome `Copa Arena Futebol`, icone, splash, titulo da pagina HTML); registrar tamanhos e SHA256 de `index.pck`/`index.wasm`/zip.
- `05B Publish Script`: `tools/publish_web.ps1` no padrao de `draxos-mobile/tools/publish_internal_alpha.ps1`: `Mode Plan` (default), `Mode Package` (local, exige `-ReleaseRoot` versionado fresco `web/v1-<slug>-YYYYMMDD-<shortsha>`), `Mode FullPublish` (wrangler pages deploy; exige `-ConfirmRemoteMutation`). Sem secrets em codigo/docs; wrangler usa a CLI autenticada do Fabio - se pedir login, PARAR e avisar.
- `05C Publicacao + Smoke Remoto`: primeira publicacao real (autorizada pela decisao acima); adaptar `tools/track04f_chrome_probe.mjs` para rodar contra a URL publicada: jogo carrega em primeira visita, release root confere, zero erros de runtime, timing de overlay registrado; screenshot de evidencia.
- `05D Fechamento`: criar `docs/release-history.md` do JogoDaCopa (padrao do estudo: tabela data/release/URL/hashes/notas, incluindo a limitacao conhecida do hitch de primeiro uso de VFX/audio); atualizar `docs/publication-readiness.md` (esta defasado: diz "no Web"); track doc + handoff de review para Claude; apos aprovacao, merge local, card em Done, `Estado_Atual`/`current-status` atualizados e `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Out Of Scope

- Track 04F.3 (residual VFX/audio - adiada por decisao), multiplayer/backend/placar online, dominio proprio, itch.io, analytics, monetizacao, export Windows assinado.
- Logos oficiais FIFA/Copa/federacoes (manter kits genericos inspirados).
- Qualquer `git push/fetch/pull` (rede git e do Fabio).

## Expected Files

- `Projetos/JogoDaCopa/tools/publish_web.ps1` (novo)
- `Projetos/JogoDaCopa/export_presets.cfg` (identidade/release do preset Web)
- `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs` (modo URL remota)
- `Projetos/JogoDaCopa/docs/release-history.md` (novo)
- `Projetos/JogoDaCopa/docs/publication-readiness.md` (atualizado)
- `Projetos/JogoDaCopa/implementation/tracks/track-05-web-publication/current-status.md` (novo)
- `Projetos/JogoDaCopa/implementation/current-status.md`, `Estado_Atual.md` (fechamento)

## Acceptance Criteria

- [x] Export Web release com identidade correta; hashes registrados.
- [x] `publish_web.ps1` safe-by-default (`Plan`/`Package` sem rede; `FullPublish` so com `-ConfirmRemoteMutation`).
- [x] URL publica do Cloudflare Pages carregando o jogo em primeira visita sem erros de runtime (smoke remoto com evidencia JSON+screenshot).
- [x] Sem Cloudflare Access na URL publica; nenhum secret em repo/logs/docs.
- [x] `docs/release-history.md` criado com o release v1 e a limitacao conhecida documentada.
- [x] `tools/validate.gd` full PASS; zero regressao GUT; nenhuma mudanca de gameplay/feel.
- [x] Handoff de review para Claude ANTES do merge; commits por estagio logico (05A-05D); verificacao pos-commit `git diff --name-status HEAD~1..HEAD` em cada um.
- [ ] Fechamento declara `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Handoff Needed

`Yes` - review Claude (gate de merge) + teste humano do Fabio na URL publica (primeiro acesso real, mobile browser dele incluido se quiser - sem suporte oficial, apenas observacao).

## Review State

- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Published preview URL: `https://7a19a00f.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260612-31e23ea3`.
- Remote smoke: `docs/playtest-reports/track-05-data/05c-remote-menu-smoke.json` + `.png`, PASS, page errors `0`, runtime console errors `0`.
- Validation: `tools/validate.gd` PASS, 86 tests, 1264 asserts.
- Merge status: pending Claude review; not moved to Done yet.

## Notes

- Referencias de pipeline: `draxos-mobile/tools/publish_internal_alpha.ps1` e `draxos-mobile/tools/build_cloudflare_pages_package.ps1` (adaptar, nao importar logica de release safety do mobile alem do necessario).
- O export e single-threaded por decisao da 04E - nenhum header COOP/COEP especial e necessario no Pages.
- Primeira visita: overlay `<= 5s` local ja garantido pela 04F.2; registrar o numero remoto como baseline, sem gate rigido (rede varia).
