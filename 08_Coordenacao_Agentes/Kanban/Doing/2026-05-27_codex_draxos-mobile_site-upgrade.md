# DraxosMobile - Site Upgrade

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/site-protection`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--site-protection`
- Projeto: `Projetos/draxos-mobile/`
- Objetivo: transformar o portal protegido da Internal Alpha em hub alpha privado com abas e Grimorio dinamico privado.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`
- `Projetos/draxos-mobile/portal/internal-alpha/index.html`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/portal/internal-alpha/`
- `Projetos/draxos-mobile/tools/`
- `Projetos/draxos-mobile/supabase/functions/`
- `Projetos/draxos-mobile/server/functions/`
- `Projetos/draxos-mobile/server/tests/`
- Documentacao/status de Track 03 e coordenacao, se o estado observavel mudar.

## Validacao Planejada

- `npx -y deno task check` em `supabase/functions`
- `npx -y deno task check` em `server/functions`
- `npx -y deno run --allow-net --allow-env server/tests/grimoire_catalog_smoke.ts`
- Smokes de `release/manifest` e `release/download` quando aplicavel
- Geracao do pacote Cloudflare Pages
- Verificacao de placeholders e assets do portal

## Handoff

- Status: concluido e publicado.
- Entrega: endpoint privado `GET /content/grimoire`, modulo gerado `grimoire_catalog_v1`, portal alpha em abas com arte local e Grimorio filtravel, script de publicacao com copia recursiva de assets e pacote Cloudflare atualizado.
- Deploys: Supabase Edge Function `content` publicada no projeto `armxgipvnbbshzqawklw`; Cloudflare Pages publicado em `https://73887bc2.draxos-mobile-internal-alpha.pages.dev`; dominio estavel `https://draxos-mobile-internal-alpha.pages.dev` validado atras do Cloudflare Access.
- Validacao: `deno task check/lint` em `supabase/functions` e `server/functions`; `grimoire_catalog_smoke.ts` local/remoto; `release_manifest_smoke.ts` local/remoto; download sem JWT `401`; pacote Cloudflare sem placeholders; asset `portal/assets/draxos-arena.svg` copiado; screenshots desktop/mobile geradas em `Projetos/draxos-mobile/build/internal-alpha/`.
- Hotfix: area/botoes Web removidos do portal; `release/download` corrige URL assinada para `storage/v1/object/sign`; `release_download_smoke.ts` remoto passou com HEAD da URL assinada; export Web regenerado com `experimentalVK:true`; Cloudflare Pages redeployado em `https://be9b5724.draxos-mobile-internal-alpha.pages.dev`.
- Ajuste final: login/acesso de jogo removido da interface do site; Cloudflare Access por email fica como barreira do hub; downloads usam links diretos do pacote publicado; Grimorio carrega `portal/assets/grimoire-catalog.json`; fluxo Supabase do site fica escondido/preservado para futuro.
- Correcao de escopo: Web build recolocada como botao/aba/card visivel no hub; apenas o login/acesso Supabase do site continua removido. Cloudflare Pages redeployado em `https://4b709bb0.draxos-mobile-internal-alpha.pages.dev`.
- Hotfix Web: tela preta apos `Jogar Web` era asset inconsistente no Supabase Storage (`index.js` ausente e `index.pck` antigo). Reupload manual publicou `index.js` e `index.pck` corretos, `tools/publish_internal_alpha.ps1` agora valida tamanho exato de `index.js`/`index.pck`/`index.wasm` e a build Web renderizou no navegador local em `/web/` sem erros de console.
- Ponto de handoff: seguir para `T03-P18` sem ranking/jogadores nesta rodada.
