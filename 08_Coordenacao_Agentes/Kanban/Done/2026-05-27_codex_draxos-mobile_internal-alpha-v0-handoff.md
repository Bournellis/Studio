# Kanban - Done

- Data de conclusao: `2026-05-27`
- Agente: `codex`
- Projeto: `draxos-mobile`
- Slug: `internal-alpha-v0-handoff`

---

## Tarefa

Fechar o handoff documental da Internal Alpha v0 apos `T03-P18`, preservando os links reais de Portal/Web/downloads, estado publicado do manifest e proximo ciclo de teste fechado Fabio + tester.

## O Que Foi Feito

- `T03-P18` marcado como completo nos documentos vivos do DraxosMobile.
- `docs/internal-alpha-v0-handoff.md` criado como registro final de links, hashes, release notes, bugs conhecidos, validacao e instrucoes de update.
- Contratos de API/manifest/schema reconciliados com o estado publicado da Internal Alpha v0.
- Portal, manifest exemplo, defaults de `release/manifest` e scripts de publicacao alinhados aos links finais.
- Registros de portfolio atualizados para apontar o proximo ciclo: rodada fechada Fabio + tester e backlog de feedback pos-handoff.

## Validacao Registrada

- Godot validate/GUT: verde em 2026-05-27.
- Exports Android/PC/Web: verdes em 2026-05-27.
- Smokes remotos de release, auth, saves, batalha, base, social, competicao, monetizacao e telemetria: verdes em 2026-05-27.
- Cloudflare Pages e downloads Supabase Storage: validados com respostas `200`.
- `git diff --check`: esperado para este fechamento documental.

## Proximo Passo

Rodar a build fechada com Fabio + tester, registrar feedback real de Android/onboarding/loop principal e converter bugs ou lacunas em backlog antes de abrir refatoracoes maiores.
