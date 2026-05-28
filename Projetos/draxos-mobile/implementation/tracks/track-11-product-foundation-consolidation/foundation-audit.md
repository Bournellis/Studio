# Track 11 - Foundation Audit

- Data: `2026-05-28`
- Escopo: projeto inteiro de DraxosMobile apos Track 10 e republicacao de builds.

## Cresceu Bem

- O produto ja tem um eixo claro: Refugio/Base como home portrait, batalha server-authoritative com apresentacao fullscreen, social/competicao/loja alpha e Progression Lab isolado.
- A separacao de autoridade esta correta para o genero: cliente nao calcula batalha, recompensa ou mutacao de recursos.
- Supabase local/remoto, Edge Functions, migrations, mirrors `server/` e `supabase/`, Storage, manifest e Cloudflare Pages formam uma fundacao real de alpha fechado.
- A suite local cresceu com valor: validate, GUT, smokes Godot, Deno checks, smokes remotos e contratos de release.
- O projeto preservou guardrails importantes: sem service role no cliente, sem mobile browser/iOS fora de escopo, sem pagamento real e sem tuning numerico sem playtest humano.

## Nao Esta Bom

- Documentacao viva ficou defasada em varios pontos: README e AGENTS ainda falavam Track 03/04 enquanto o codigo estava em Track 10.
- `implementation/current-status.md` virou historico longo demais para orientar uma nova pessoa ou agente. O arquivo precisava voltar a ser snapshot de decisao.
- `Kanban/Doing` acumulou dezenas de cards concluidos, tornando dificil saber o que realmente estava ativo.
- `modes/boot/boot.gd` continua concentrando shell, rotas, auth, actions, erro, estado visual e fluxo de batalha. Isso aumenta risco de regressao a cada etapa visual.
- Release ops tinha drift: hashes default/exemplo ainda apontavam para artefatos antigos, e o smoke remoto nao explicava o cenario atual de Cloudflare Access no dominio estavel.
- O script de publicacao ainda e poderoso demais para ser chamado como validacao casual; ele mistura preparacao, upload, secret override e redeploy.
- A decisao de conta/save segue pragmatica para alpha (`players.save_type`), mas nao e base ideal para expansao social/live ops.

## Mudancas Reais Feitas Na Track 11

- Reorganizada a fonte de verdade do projeto: README, AGENTS e current-status agora comecam pela Track 11 e pela release publicada.
- Criado readiness check que bloqueia regressao documental/operacional antes da proxima etapa.
- Sincronizados hashes/manifest de release com o estado publicado em 2026-05-28.
- Adaptado smoke remoto para diferenciar falha real de artefato e protecao esperada do Cloudflare Access.
- Extraido o contrato de mensagens/normalizacao de erro para fora do `boot.gd`, abrindo um padrao seguro para proximas extracoes.

## Proximas Mudancas Grandes Recomendadas

1. **App Shell Decomposition**
   - Extrair actions, lifecycle de batalha e fluxo de conta do `boot.gd`.
   - Manter cada corte com teste de contrato antes de alterar UX.

2. **Account/Save Model**
   - Planejar migration `account_profiles` + `game_saves`.
   - Separar identidade, saves, lab, ranking e futuro multi-personagem antes de live ops.

3. **Release Pipeline Hardening**
   - Dividir `publish_internal_alpha.ps1` em plan/dry-run, upload e deploy.
   - Exigir relatorio imutavel de artefatos antes de qualquer manifest remoto.

4. **Human Walkthrough Gate**
   - Testar APK real, Windows e Web com Access/preview.
   - Transformar friccoes em backlog priorizado antes de feature nova.

5. **Progression Lab Human Pass**
   - Rodar save real no Godot, comparar janelas 2h-20h e so entao mexer em numeros.

## Decisao

O projeto cresceu bem para uma Internal Alpha, mas precisa de disciplina de fundacao antes de nova expansao. A proxima etapa longa deve partir de walkthrough humano + decomposicao do app shell, nao de sistemas novos.
