# Code Review - JogoDaCopa Track 06E - Release v1.1.0 (pre-merge)

- Data: `2026-06-13`
- Revisor: Claude (review pre-merge do release)
- Branch: `codex/jogodacopa/track06e-release-v1-1-0` (commit `20525d19`)
- Base: `main` com 06A-06D mergeadas
- Veredito: `APROVADO no pre-merge`. Bump consistente, changelog correto, gates locais verdes e nada publicado ainda. Pronto para FASE 5 (merge) -> FASE 6 (publicacao) -> FASE 7 (gates remotos) -> FASE 9 (retest humano), apos OK do Fabio.

## Escopo (OK)

Apenas versao/changelog/evidencia. `test_bootstrap.gd` e `export_presets.cfg` foram tocados, mas de forma legitima para um release (assertion de versao do rodape e metadata de versao do .exe); nao ha mudanca de gameplay.

## Consistencia de versao `v1.1.0` (OK - conferida em todas as fontes)

- `modes/menu/main_menu_root.gd`: `VISIBLE_VERSION` `v1.0.1` -> `v1.1.0`.
- `tools/publish_web.ps1`: `$VisibleVersion = "v1.1.0"` (e mensagem de deploy do release).
- `export_presets.cfg`: `application/file_version` e `application/product_version` `0.2.0.0` -> `1.1.0.0`.
- `tests/unit/test_bootstrap.gd`: assertion do rodape `Copa Arena Futebol v1.0.1+` -> `v1.1.0+` (atualizacao necessaria do teste que fixa a versao visivel).
- `docs/release-history.md`: entrada `v1.1.0` com baseline anterior `v1.0.3+ef9c5baa` e resumo da Serie 06.
- Evidencia visual: rodape do menu exibe `COPA ARENA FUTEBOL V1.1.0+LOCAL | SEM LOGOS OFICIAIS` (`+local` vira `+hash` apos publicar).

## Changelog (OK)

Entrada resume corretamente 06A (match start), 06B (ESC menu + settings), 06C (menu broadcast), 06D (HUD broadcast), 06E (release). Marca a publicacao remota como PENDENTE - honesto, sem alegar release publicado.

## Gates locais (handoff)

- `validate.gd` PASS `101` testes / `1735` asserts (confirma 06C + 06D ambos presentes na `main`).
- Export Web release PASS (single-threaded); Export Windows debug PASS; revalidacao pos-export PASS; Web gzip `30.43 MiB / 50.00 MiB`.
- Boot Web local Chrome PASS, rodape `v1.1.0+local`, `pageErrors=0`, `consoleErrorCount=0`.
- Primeiro minuto local PASS (`0` hitches). Luminancia noturna local PASS (`luma 10.3 < 90`).
- `git diff --check` PASS.

## Disciplina (OK)

`STOP_PRE_MERGE_REVIEW`: sem merge, sem publicacao, sem push/fetch/pull, sem `git clean`, sem mudanca de gameplay. Aguardando aprovacao antes da FASE 5/6.

## Proximo passo (sequencial - liberar so com OK do Fabio)

1. Fabio aprova o bump/changelog.
2. FASE 5: Codex mergeia a 06E em `main` (marker MERGED) + `validate` pos-merge.
3. FASE 6: publicacao remota UNICA via `tools/publish_web.ps1 ... -FullPublish -ConfirmRemoteMutation`, conforme a Decisao 2026-06-12. Registrar novo release root `web/v1-copa-arena-futebol-<data>-<hash>` e o hash.
4. FASE 7: gates remotos longos contra `https://copa-arena-futebol.pages.dev/` (primeiro minuto + estabilidade 5 min + luminancia, `0` erros, release root confere). SE FALHAR: rollback pela Decisao (republicar `ef9c5baa`), nao deixar release quebrado. **Vou re-verificar os resultados desses gates remotos antes de considerar o release validado.**
5. FASE 8: release-history + `current-status`/`Estado_Atual` com a nova baseline `v1.1.0`.
6. FASE 9: retest humano (Fabio + tester externo) na URL publica - gate final da serie.
