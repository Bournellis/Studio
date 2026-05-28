# Track 11 - Product Foundation Consolidation - Scope

- Data: `2026-05-28`
- Status: `INTEGRATED_CONSOLIDATION_READY`
- Branch: `codex/draxos-mobile/track-11-consolidation`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-11-consolidation`

## Objetivo

Consolidar DraxosMobile depois do crescimento acelerado de Track 00 a Track 10, antes de abrir a proxima etapa longa de produto. A trilha deve alinhar documentacao viva, release ops, Kanban, validacao e uma primeira extracao segura do monolito do app shell.

## Dentro Do Escopo

- Auditar coerencia do projeto como produto, implementacao, documentacao, release e coordenacao.
- Criar Track 11 oficial com escopo, plano, status, auditoria e registro dos pacotes paralelos.
- Atualizar README, AGENTS local, current-status, portfolio, painel e docs de release para refletir Track 10 publicada + Track 11.
- Arquivar cards antigos de DraxosMobile em `Kanban/Done`.
- Sincronizar manifest default/exemplo com os hashes publicados em 2026-05-28.
- Adaptar smoke remoto de artefatos para o cenario real de Cloudflare Access quando explicitamente permitido.
- Criar readiness check local que verifique drift de docs/release/mirrors/Kanban.
- Extrair um contrato pequeno e testavel de `boot.gd` sem alterar comportamento jogavel.

## Fora Do Escopo

- Feature jogavel nova.
- Tuning numerico de economia/progressao.
- Migration `account_profiles` + `game_saves`.
- Publicacao remota, upload, redeploy ou mudanca de secrets.
- Keystore release, pagamento real, assets finais, iOS ou mobile browser.

## Definition Of Done

- Docs vivos apontam para Track 11 e para a release publicada correta.
- `Doing/` nao fica carregado com cards antigos de DraxosMobile.
- Release defaults e `portal/internal-alpha/manifest.example.json` usam hashes atuais.
- `tools/check_track11_readiness.ps1` passa.
- Godot validate/GUT e Deno checks relevantes passam.
- Worktree fica limpa apos commit.
