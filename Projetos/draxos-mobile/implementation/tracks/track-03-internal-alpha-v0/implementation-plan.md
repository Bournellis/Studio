# Track 03 - Implementation Plan

## Ordem De Execucao

### T03-P00 - Preparacao De Workspace

Status inicial desta fase.

- Limpar outputs gerados/untracked que sujam a worktree.
- Ignorar novos `.uid`, `.translation` e `build/` gerados.
- Criar documentos da Track 03 e atualizar registros vivos.
- Commitar preparacao separada antes de codigo funcional.

### T03-P01 - Design Lock Da Build Interna

- Resolver ou confirmar as pendencias `DMOB-D048` a `DMOB-D055`.
- Fechar lista de predios, menus, labels e acoes da Base v0 para alpha.
- Fechar produtos/redeems alpha fixos.
- Fechar o que aparece na leaderboard e como bots entram.
- Fechar limites sociais do alpha: amigo, guilda, chat, bloqueios e moderacao minima.
- Fechar politica de update: recomendado vs obrigatorio.

Saida esperada:

- `docs/game-design-document.md`, `docs/architecture.md`, `docs/contracts/` e `docs/design-pending.md` atualizados.

### T03-P02 - Supabase Remoto E Configuracao Segura

Status repo-side: `COMPLETE - remote bootstrap green`.
Status de execucao: `REMOTE_BOOTSTRAP_COMPLETE`.

- Criar/configurar projeto Supabase remoto Free.
- Desativar email confirmation no alpha interno.
- Configurar URL e anon key por ambiente local, sem commitar secrets.
- Criar ambiente `internal_alpha_v0` no cliente Godot.
- Validar Edge Functions em remoto com healthcheck.
- Documentar reset controlado do banco alpha.
- Confirmar os contratos anti-lock-in: cliente Godot fala com endpoints logicos e Supabase fica como implementacao atual.
- Preparar nota de plano de saida para Backend Proprio + Postgres antes de expandir auth/saves.

Saida esperada:

- Runbook operacional com passos manuais executaveis.
- Smoke remoto minimo: auth, healthcheck e account state.
- `BackendConfig` no cliente Godot para `local`, `internal_alpha_v0` e `custom`.
- `.env` reais ignorados e `.env.internal-alpha.example` versionado.
- Decisao backend registrada: Supabase para alpha; Backend Proprio + Postgres como plano de saida; Nakama como alternativa futura condicional.

### Ordem Local-First Aprovada - 2026-05-26

Fabio vai trabalhar somente no Godot/local ate o jogo estar implementado o bastante para compartilhar com o segundo testador. Portanto, a ordem correta desta fase e:

1. Implementar e validar localmente no Godot e Supabase local.
2. Fechar fluxo de conta/save/lab/base/social/competicao/loja/batalha no editor.
3. Fazer QA local e ajustar UX/tooltips/legibilidade.
4. Somente depois criar/configurar Supabase remoto.
5. Somente depois exportar Android, PC e Web.
6. Somente depois publicar artefatos e manifest de update.

Durante a fase local-first, `T03-P02` permaneceu repo-ready: a configuracao segura existe e agora volta a ser a proxima trilha de release.

Atualizacao de 2026-05-27: o projeto Supabase remoto (`armxgipvnbbshzqawklw`, `https://armxgipvnbbshzqawklw.supabase.co`) foi linkado pela CLI, recebeu migrations/functions e passou no smoke minimo de healthcheck. Auth email/senha e alpha gate seguem em `T03-P14`.

### T03-P03 - Conta Email/Senha E Dois Saves

Status local-first: `IN_PROGRESS - T03-P11_LOCAL_QA_COMPLETE`.

- Implementar fluxo email/senha.
- Manter guest/local como fallback de desenvolvimento, se ainda util.
- Criar/ajustar schema para dois saves por conta: `normal` e `progression_lab`.
- Adicionar reset separado por save.
- Garantir que endpoints server-authoritative recebem/resolvem save correto.
- Garantir que `progression_lab` nao escreve ranking/social normal.

Saida esperada:

- Teste de cross-platform save por token remoto.
- Smokes de reset separado e isolamento.

Subetapas locais:

- `T03-P03A`: completo; cliente Godot entende save ativo (`normal`/`progression_lab`), persiste no cache, mostra no HUD e bloqueia acoes perigosas do Lab quando o cache e local-only.
- `T03-P03B`: completo; Supabase local/schema/runtime resolve `save_type` server-side para todos os endpoints alpha.
- `T03-P03C`: completo; reset separado por save no runtime local.
- `T03-P03D`: pendente remoto; email/senha sera ativado em `T03-P14` depois do bootstrap Supabase remoto.

### T03-P04 - Progression Lab Exportado Interno

Status: `COMPLETE`.

- Gatear Progression Lab por flag internal alpha.
- Permitir aplicar perfis/milestones ao save `progression_lab`.
- Mostrar claramente quando o usuario esta no save lab.
- Bloquear ou isolar ranking/social/loja normal quando estiver no lab, conforme design lock.

Saida esperada:

- Um testador consegue alternar entre normal e lab sem corromper progressao.

Implementado:

- `POST /progression-lab/apply` com catalogo server-side de healthy saves.
- RPC `apply_progression_lab_save` transacional, idempotente e restrita ao save `progression_lab`.
- Botao `Aplicar no Save Lab` na tela Progression Lab Dev.
- `SessionStore` preserva metadados do Lab server-backed e limpa snapshots antigos ao aplicar novo perfil.
- Seeder local atualizado para `save_type = progression_lab` e sem ranking.
- Smoke `progression_lab_apply_smoke.ts` cobrindo preservacao do save normal, idempotencia, ranking bloqueado e batalha jogavel.

### T03-P05 - Base Manager Jogavel

Status: `COMPLETE`.

- Transformar predios da Base em tela navegavel de alpha.
- Cada predio precisa ter estado, upgrade, custo, tempo, producao/beneficio e feedback.
- Menus devem ser rolaveis em Android/PC/Web.
- Coleta, upgrade e conclusao de job continuam server-authoritative.
- Erros precisam ser objetivos: recurso insuficiente, fila cheia, estrutura em upgrade, offline.

Saida esperada:

- Fluxo de base completo para o save normal e snapshot/isolamento para lab.

Implementado:

- `GET /base/state` retorna descricao, beneficio, custo, duracao, status, motivo de bloqueio, job ativo e remaining time por predio.
- A aba Base do Hub mostra mapa de predios clicaveis, painel de detalhes, tooltips e upgrade por predio.
- `POST /base/upgrade` segue server-authoritative e agora prioriza erro de estrutura ja em upgrade antes de fila cheia.
- Atalho alpha "Comprar Energia" usa produto existente `alpha_energy_pack_small` para destravar o primeiro loop de upgrade.
- Smoke `base_manager_smoke.ts` cobre payload jogavel, compra de Energia, upgrade do Nucleo e bloqueio de segunda construcao.

### T03-P06 - Social Basico Funcional

Status: `COMPLETE`.

- Amigos por username.
- Guilda: criar/entrar/ver membros.
- Chat de guilda por polling.
- Feedback de rate limit, sem guilda, usuario nao encontrado, offline.
- Dados de social vinculados ao save/conta conforme decisao de design.

Saida esperada:

- Dois testadores conseguem se encontrar e trocar mensagem em guilda.

Implementado:

- `GET /social/state` retorna identidade social de conta, save ativo, marcador `lab`, amigos, membros e mensagens enriquecidos com username.
- `POST /social/friends/add` adiciona amigo por username.
- `POST /social/guild/create` cria guilda, owner, estruturas e canal.
- `POST /social/guild/join` entra em guilda por nome.
- `POST /social/chat/send` envia mensagem por polling com limite de tamanho, guilda obrigatoria e rate limit alpha.
- A aba Social do Hub tem inputs de username/guilda/chat, botões de atualizar/adicionar/criar/entrar/enviar, tooltips e painéis de identidade, amigos, guilda, membros, estruturas e chat.

### T03-P07 - Competicao E Leaderboards

Status: `COMPLETE`.

- Ranking basico da season alpha.
- Pontos de arena atualizados por batalha server-authoritative.
- Bots entram ou nao entram conforme design lock.
- UI mostra posicao do jogador, top lista e contexto de season.
- Matchmaking preview continua legivel.

Saida esperada:

- Batalhas alteram pontos e leaderboard atualiza sem mutacao client-side.

Implementado:

- `battle/request` `FIRST_SLICE_SIM` aplica `alpha_v0_power_adjusted` no save `normal`, preserva idempotencia por `request_id` e retorna resumo competitivo da ultima batalha.
- `progression_lab` permanece fora do ranking com `PROGRESSION_LAB_DOES_NOT_RANK`.
- `competition/ranking/current` retorna top 10, `self.rank`, total ranqueado, `self_in_top`, season e modelo de pontuacao.
- `competition/matchmaking/preview` explicita quantidade de bots candidatos e que bots nao entram na leaderboard.
- A aba Competicao do Hub mostra preview, ultima batalha competitiva, top 10, posicao do jogador e tooltips objetivos.
- Smokes de battle/social cobrem pontos de arena, top 10, posicao do jogador e exclusao de bots.

### T03-P08 - Loja Proof-Of-Concept

- Redeems alpha fixos para testar premium em varios niveis.
- Produtos: Diamante, premium pass, energia/recurso e reset/boost se aprovado no design lock.
- Claims free/premium do Battle Pass permanecem idempotentes.
- Nenhum gateway real de pagamento.
- UI deixa claro que e alpha internal.

Saida esperada:

- Testador free consegue simular estados premium por redeem e observar impacto no save correto.

Implementado:

- Catalogo alpha com quatro redeems diarios de Diamante (`pequeno`, `medio`, `grande`, `premium`), reset por save em `America/Sao_Paulo`.
- Produtos comprados com Diamante: Battle Pass premium, fila dupla de construcao, pacote de Energia e pacote medio de recursos.
- `monetization/state` retorna `shop_summary`, `alpha_products` com custo/ganho/efeito/status e historico de compras.
- `monetization/alpha-purchase` mantem ledger/idempotencia, bloqueia duplicacao diaria por produto e evita cobrar produto unico ja ativo.
- `base/state` e `base/upgrade` respeitam `alpha_double_construction_queue` e passam de 1 para 2 slots quando comprado.
- A aba Loja do Hub exibe botoes, tooltips, resumo, catalogo, recompensas e desabilita produtos ja resgatados/ativos quando o estado esta carregado.
- Smokes de monetizacao/base cobrem redeems, compra premium, fila dupla e isolamento por save.

### T03-P09 - Batalha Visual Polish Pequeno

Status: `COMPLETE`.

- Preservar mockup visual atual como baseline.
- Ajustar apenas clareza de HUD, mensagens, replay, cooldown e tooltips se surgirem no playtest.
- Nao adicionar assets externos nesta track.

Saida esperada:

- Batalha continua boa o suficiente para validar o jogo real enquanto arte final nao existe.

Implementado:

- `BattleStage2D` ganhou readout compacto no palco com progresso do replay, tempo atual, HP percentual, status, cooldowns e aliados visiveis por lado.
- Labels dos combatentes agora mostram HP absoluto e percentual.
- Tooltips de evento humanizam fonte/alvo e incluem leitura rapida do feedback visual.
- Regressao GUT cobre o readout e a tooltip de evento sem depender de assets externos.

### T03-P10 - Releases E Updates

Status de execucao: `RELEASE_PREP - T03-P12_PORTAL_BASE_COMPLETE`.

- Criar schema de manifest remoto em Supabase Storage.
- Cliente consulta manifest no boot e mostra status de update.
- Definir `minimum_supported_version`, `latest_version`, links de Android/PC/Web e notas.
- Exportar Android, PC e Web com mesmo version code/name.
- Publicar artefatos em local definido.

Saida esperada:

- As tres plataformas sabem quando existe update e onde buscar.

Implementado em `T03-P12`:

- Plano de release e ordem correta de `T03-P12` a `T03-P18` documentados em `docs/internal-alpha-release-plan.md`.
- Base do portal estatico criada em `portal/internal-alpha/` com links placeholders para Web, APK, PC zip e manifest.
- Manifest de update exemplo criado em `portal/internal-alpha/manifest.example.json`.
- Tutorial operacional de Supabase remoto criado em `docs/supabase-remote-tutorial.md`.

### T03-P11 - QA, Smokes E Playtest Fechado

Status local-first: `LOCAL_AUTOMATED_QA_COMPLETE`.

- Rodar validate/GUT.
- Rodar smokes remotos.
- Rodar checklist interno com duas contas.
- Registrar bugs e lacunas.
- Criar relatorio curto de build `internal_alpha_v0`.

Saida esperada:

- Build fechada testavel por Fabio + 1 amigo.

Implementado em modo local-first:

- Ambiente local resetado: cache Godot, scratch Progression Lab e Supabase local.
- Checks/lints Deno de `supabase/functions` e `server/functions` passaram.
- Smokes server-authoritative locais cobriram batalha, dois saves, reset separado, Progression Lab apply, Base, Social, Competicao, Loja e Telemetria.
- Godot validate/GUT, smoke de exports, shell, replay, alpha loop e labs dev passaram.
- Relatorio curto criado em `docs/internal-alpha-v0-qa-report.md`.

Lacunas intencionais:

- Smoke remoto real, email/senha, builds exportadas e manifest de updates seguem encaminhados para `T03-P13` a `T03-P18`.

### T03-P12 - Release Plan, Portal Base E Tutorial Remoto

Status: `COMPLETE`.

- Registrar as proximas etapas de release sem voltar a misturar implementacao local, remoto, builds e portal.
- Criar uma base de portal simples e unlisted para concentrar Web build, APK, PC zip, notas e aviso de update.
- Documentar o ponto de partida Supabase mostrado no dashboard do usuario.
- Criar tutorial detalhado do que Fabio precisa configurar e quais valores enviar para continuar.
- Manter o portal como "feito por enquanto"; detalhes visuais e conteudo final ficam fora do bloqueio ate depois de `T03-P18`.

Saida entregue:

- `docs/internal-alpha-release-plan.md`.
- `docs/supabase-remote-tutorial.md`.
- `portal/internal-alpha/README.md`.
- `portal/internal-alpha/index.html`.
- `portal/internal-alpha/manifest.example.json`.

### T03-P13 - Supabase Remote Bootstrap

Status: `COMPLETE`.

- Fabio confirma `Project URL`, `Project Ref` e public/publishable key.
- Fabio cria `.env.internal-alpha.local` local e ignorado.
- Linkar Supabase CLI ao projeto remoto.
- Aplicar migrations em remoto.
- Deployar Edge Functions.
- Rodar healthcheck e smoke remoto minimo sem service role no cliente.

Saida esperada:

- Remoto com schema/functions da build atual.
- Smoke remoto verde contra `https://armxgipvnbbshzqawklw.supabase.co`.
- Documentacao atualizada com resultado real.

Implementado em 2026-05-27:

- Supabase CLI logado e linkado ao projeto `armxgipvnbbshzqawklw`.
- `supabase db push` aplicou as 10 migrations da alpha no remoto.
- Edge Functions `healthcheck`, `account`, `battle`, `base`, `social`, `competition`, `monetization`, `telemetry` e `progression-lab` publicadas.
- Smoke remoto minimo passou com `healthcheck: true`.
- `supabase migration list` confirmou migrations locais/remotas alinhadas.

### T03-P14 - Auth Email/Senha E Alpha Gate

Status: `NEXT`.

- Ativar fluxo email/senha no Godot.
- Manter guest apenas como fallback dev/local.
- Garantir que conta cria/carrega os dois saves.
- Definir alpha gate simples para Fabio + 1 amigo.
- Validar login/logout/reentrada em PC/Web/Android.

### T03-P15 - Update Manifest E Version Gate

Status: `PENDING_T03_P13`.

- Publicar manifest remoto real.
- Conectar boot do Godot ao manifest.
- Mostrar update recomendado e bloquear online quando `minimum_supported_version` exigir.
- Registrar politica de reset destrutivo por release quando necessario.

### T03-P16 - Export Android, PC E Web

Status: `PENDING_T03_P14_T03_P15`.

- Exportar APK Android direto por link.
- Exportar PC Windows em zip direto por link.
- Exportar Web para acesso unlisted via portal.
- Usar mesma versao/canal nos tres artefatos.
- Guardar keystore Android e qualquer credencial fora do repo.

### T03-P17 - Remote QA Fechado

Status: `PENDING_T03_P16`.

- Publicar portal/Web/APK/PC em links unlisted.
- Rodar smoke remoto automatizado.
- Rodar checklist manual com duas contas reais.
- Validar save comum entre plataformas.
- Validar loop normal: entrar, coletar, batalhar, receber recompensa, evoluir, loja/social/competicao.
- Validar save `progression_lab` isolado e fora da competicao.

### T03-P18 - Handoff Da Internal Alpha v0

Status: `PENDING_T03_P17`.

- Atualizar portal com links reais finais.
- Atualizar release notes e manifest.
- Registrar bugs conhecidos e instrucoes de update.
- Fechar pacote de teste Fabio + 1 amigo.
- Depois de `T03-P18`, Fabio pode melhorar o portal sem bloquear a build.

## Design Sessions Obrigatorias Antes De Codigo Funcional

As decisoes abaixo estao registradas em `docs/design-pending.md` e precisam ser resolvidas ou explicitamente aceitas como alpha-only:

- `DMOB-D048`: Base v0 final para alpha interno.
- `DMOB-D049`: ownership e UX dos dois saves.
- `DMOB-D050`: pacotes/redeems fixos da loja.
- `DMOB-D051`: leaderboard e pontos da competicao.
- `DMOB-D052`: limites sociais e moderacao minima.
- `DMOB-D053`: politica de releases/updates.
- `DMOB-D054`: fluxo de conta, convite e recuperacao no alpha.
- `DMOB-D055`: regras de isolamento do Progression Lab.

## Trabalho Manual Do Fabio

Necessario agora para `T03-P13`:

- Confirmar se o projeto remoto usado sera `Bournellis's Project` / `armxgipvnbbshzqawklw`.
- Desativar email confirmation no projeto alpha.
- Guardar `SUPABASE_SERVICE_ROLE_KEY` fora do Git.
- Criar `.env.internal-alpha.local` local e ignorado conforme `docs/supabase-remote-tutorial.md`.
- Informar `SUPABASE_PROJECT_REF`, `SUPABASE_URL` e public/publishable key do projeto remoto.
- Confirmar se Supabase CLI login/link foi feito localmente.
- Criar email/senha dos testadores ou permitir cadastro com convite.
- Criar keystore Android internal alpha e guardar senha fora do Git.
- Escolher onde hospedar a Web build unlisted, APK e zip PC.
- Aprovar quais redeems premium entram na loja alpha.
- Aprovar se bots aparecem na leaderboard nesta build.

## Validacao Esperada

Godot:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
```

Server/local:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno test tools/battle_lab tools/progression_lab server/tests/first_slice_simulator_test.ts
npx -y supabase db reset
```

Remote alpha:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

O smoke remoto exige `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` de um projeto remoto real e rejeita URLs locais.

## Regra De Commit

- T03-P00 deve ficar em commit separado de preparacao.
- Cada pacote funcional deve ter commit proprio quando possivel.
- Nao misturar artefatos gerados de laboratorio com mudancas de contrato/codigo.
- Worktree deve terminar limpa a cada etapa entregue.
