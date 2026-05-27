# DraxosMobile - Internal Alpha v0

- Ultima atualizacao: `2026-05-27`
- Fonte de execucao: `../implementation/tracks/track-03-internal-alpha-v0/`
- Design lock: `internal-alpha-v0-design-lock.md` (`LOCKED`)
- Setup remoto: `internal-alpha-remote-setup.md`
- Tutorial Supabase remoto: `supabase-remote-tutorial.md`
- Plano de release: `internal-alpha-release-plan.md`
- Relatorio de export: `internal-alpha-v0-export-report.md`
- Portal base: `../portal/internal-alpha/`
- Objetivo: fechar uma build interna profissional para Fabio + 1 amigo testarem um jogo real em Android, PC e Web, com servidor real, conta/save compartilhados, features principais funcionais e iteracao rapida.

## Resumo Da Build

Internal Alpha v0 e a primeira build fechada com intencao de jogo real. Ela nao precisa ter arte final, monetizacao real ou balance definitivo, mas precisa provar:

- conta real;
- save entre plataformas;
- batalha server-authoritative com apresentacao visual atual;
- base jogavel;
- social basico;
- leaderboard;
- loja proof-of-concept;
- Progression Lab como ferramenta interna isolada;
- updates coordenados entre Android, PC e Web.

## Ordem De Implementacao Local-First

Decisao operacional de 2026-05-26:

1. Trabalhar somente no Godot/local ate o jogo estar implementado o bastante para compartilhar.
2. Usar Supabase local quando um sistema precisar de fluxo server-authoritative.
3. Nao criar build Android/PC/Web enquanto o loop local ainda estiver mudando.
4. Nao subir Supabase remoto enquanto conta/save/base/social/competicao/loja ainda estiverem em implementacao principal.
5. Depois do gameplay local estar pronto, configurar Supabase remoto.
6. Depois do remoto validado, exportar as tres builds.
7. Depois das builds, publicar manifest/update e iniciar o teste fechado Fabio + 1 amigo.

Esta ordem nao remove a decisao de usar Supabase no alpha. Ela apenas adia remoto, build e distribuicao para reduzir friccao enquanto a implementacao ainda muda muito.

Atualizacao de 2026-05-27: `T03-P13` concluiu o bootstrap Supabase remoto, `T03-P14` concluiu auth email/senha + alpha gate, `T03-P15` concluiu manifest remoto + version gate no cliente, `T03-P16` exportou Android/PC/Web localmente e `T03-P17` publicou APK/PC ZIP em links unlisted com QA remoto automatizado verde. Portal/Web aguardam host estatico externo porque Supabase nao serve HTML como pagina. A proxima sequencia esta documentada em `internal-alpha-release-plan.md`: publicar Portal/Web, signoff manual Fabio + tester e `T03-P18` handoff.

## Modelo De Conta E Save

Autenticacao:

- Supabase Auth email/senha.
- Email confirmation desligado no alpha interno.
- Convite ou flag alpha obrigatoria para entrar no jogo.
- Guest continua permitido apenas como ferramenta local/dev enquanto for util.

Saves por conta:

| Save | Uso | Reset | Ranking/Social | Progression Lab |
|---|---|---|---|---|
| `normal` | jogo real do alpha interno | separado | participa | nao aplica |
| `progression_lab` | estados custom/teste avancado | separado | isolado ou bloqueado | aplica |

Regras:

- O usuario deve sempre saber qual save esta usando.
- Reset de `progression_lab` nao toca `normal`.
- Reset de `normal` nao toca `progression_lab`.
- Dados de ranking/social do save normal nao devem ser contaminados pelo lab.
- Toda mutacao continua server-authoritative.

Status atual (`T03-P14`):

- Godot possui fluxo real de conta alpha com email, senha, username e convite; guest fica em ferramentas dev.
- Godot persiste metodo de auth, email, username, save ativo e envia `x-draxos-save-type`.
- Supabase local/remoto resolve `normal` e `progression_lab` por `players.save_type`.
- `/account/bootstrap` cria saves para JWT registrado; `/account/guest` fica restrito a JWT anonimo dev.
- Uma mesma sessao Auth pode criar/carregar dois players/saves distintos.
- Batalha, Base, Social, Competicao, Loja e Telemetria usam o save ativo no servidor.
- `progression_lab` fica fora do ranking com motivo explicito `PROGRESSION_LAB_DOES_NOT_RANK`.
- O hub possui reset perigoso do save ativo; o servidor reconstrui apenas aquele save, preservando o outro.
- A tela Progression Lab Dev possui `Aplicar no Save Lab`; o servidor valida o perfil/milestone contra o catalogo versionado, aplica apenas no save `progression_lab` e preserva o save `normal`.
- A Base ja funciona como fluxo jogavel local: mapa de predios clicaveis, painel por predio, tooltips, custo/tempo/producao/status vindo do servidor, compra alpha de Energia e upgrade server-authoritative por estrutura.
- O Social ja funciona como fluxo basico local: amigos por username, criar/entrar em guilda, membros/estruturas visiveis, chat de guilda por polling, rate limit e marcadores `normal`/`lab`.
- A Competicao ja funciona como leaderboard alpha local: batalha normal pontua no servidor, ranking mostra top 10 + posicao do jogador, bots ficam fora da tabela e o Lab continua sem pontuacao.
- A Loja ja funciona como proof-of-concept local: quatro redeems diarios por save entregam apenas Diamante, compras usam Diamante, Battle Pass premium e fila dupla sao produtos unicos, a fila dupla altera a Base para 2 slots e a UI mostra catalogo/status/claims com tooltips.
- A Batalha possui polish visual pequeno para playtest: nomes mostram HP percentual, o palco exibe readout compacto de replay/tempo/HP/status/cooldowns/aliados e tooltips de evento humanizam fonte/alvo.
- QA local automatizado passou apos reset completo de cache Godot, scratch Progression Lab e Supabase local; detalhes em `internal-alpha-v0-qa-report.md`.

## Backend Remoto

Alvo inicial:

- Supabase Free.
- Projeto remoto observado no dashboard: `Bournellis's Project`, ref `armxgipvnbbshzqawklw`, URL `https://armxgipvnbbshzqawklw.supabase.co`, regiao `West US (Oregon)`, status `Healthy`.
- Status remoto atual: CLI linkado, 11 migrations aplicadas, Edge Functions publicadas, Auth email/senha sem confirmacao obrigatoria e smokes de healthcheck/Auth anonimo dev/email+saves verdes em 2026-05-27.
- Edge Functions para acoes autoritativas.
- Postgres com RLS.
- Edge Function publica para manifest de updates; artefatos de build podem ficar em Storage ou host externo conforme tamanho.
- Ambiente `internal_alpha_v0` configuravel por `BackendConfig` no Godot.
- URL e publishable key via env vars ou project settings publicos.

Direcao de longo prazo:

- Supabase e usado para acelerar a Internal Alpha v0.
- O plano de saida preferido e Backend Proprio + Postgres.
- Nakama fica como alternativa futura apenas se DraxosMobile passar a exigir realtime, lobbies, matchmaking ativo ou social competitivo pronto.

Motivo:

- partidas sao PvE/PVP assincronas, nao salas realtime;
- social existe, mas e chat/interacao/ajuda/guilda sem conexao direta de partida;
- economia, transferencia, claims, upgrades, recursos e ranking precisam de transacoes, ledger e auditoria.

Seguranca minima:

- `anon key` pode existir no cliente.
- `publishable key` pode existir no cliente quando for a key publica do projeto.
- `service_role` nunca pode entrar no cliente, Web export, APK, zip ou repo.
- Policies devem continuar limitando leitura/escrita ao dono.
- Mutacoes economicas usam Edge Functions, idempotencia e ledger.
- Web link publico/unlisted nao e segredo de seguranca; auth e alpha flag sao a barreira real.
- Auth email/senha e alpha gate foram implementados em `T03-P14`; `service_role` continua fora do cliente e smokes remotos usam apenas publishable key.

Regra anti-lock-in:

- Godot usa endpoints logicos do jogo, nao detalhes internos do Supabase.
- `service_role`, policies e tabelas sao detalhes de backend.
- IDs internos do jogo devem permitir migracao futura para API propria.

## Updates E Distribuicao

Todos os canais usam a mesma cadencia de versao.

Distribuicao escolhida para Internal Alpha v0:

- Android: APK direto por link.
- PC Windows: zip direto por link.
- Web: build PC browser exportada; publicacao final aguarda host estatico externo.
- Portal: pagina estatica simples em `portal/internal-alpha/`, considerada suficiente por enquanto; refinamento visual fica para depois de `T03-P18` e publicacao final aguarda host estatico externo.
- Updates: app consulta manifest e mostra aviso/link de download; quando `minimum_supported_version` subir, acoes online ficam bloqueadas ate atualizar.

Manifest remoto atual em `GET /release/manifest`:

```json
{
  "schema_version": "internal_alpha_manifest_v1",
  "channel": "internal_alpha",
  "latest_version": "0.0.1-alpha.0",
  "latest_version_code": 1,
  "minimum_supported_version": "0.0.1-alpha.0",
  "minimum_supported_version_code": 1,
  "released_at": "2026-05-27T00:00:00Z",
  "requires_save_reset": false,
  "portal_url": "PORTAL_URL_PENDING_T03_P17",
  "notes": ["Primeira build interna"],
  "artifacts": {
    "android": { "url": "https://...", "sha256": "..." },
    "pc_windows": { "url": "https://...", "sha256": "..." },
    "web": { "url": "https://..." }
  }
}
```

Status atual (`T03-P15`):

- `ProjectInfo` declara canal, versao, code e schema do manifest.
- `BackendConfig` resolve a URL do manifest por project settings/env e usa `<supabase_url>/functions/v1/release/manifest` como padrao.
- `SupabaseClient` busca o manifest no boot.
- O Hub mostra resumo da versao, status do update, detalhes e URL do manifest.
- Quando o manifest exige `minimum_supported_version_code` maior que o code local, o Hub bloqueia acoes online e permite apenas checar update, trocar save, limpar cache local e abrir ferramentas dev.

Status de export (`T03-P16`):

- Android APK local: `build/android/draxos-mobile-alpha.apk`.
- PC Windows ZIP local: `build/pc/draxos-mobile-alpha.zip`.
- Web build local: `build/web/`.
- Hashes e metadata: `internal-alpha-v0-export-report.md` e `build/internal-alpha/release-artifacts.json`.
- APK Android saiu como `debug_fallback` porque a keystore release dedicada ainda nao foi configurada; suficiente para o teste interno inicial, mas uma keystore release deve ser configurada antes de distribuicoes mais amplas.

Status de publicacao (`T03-P17`):

- APK/PC ZIP publicados no bucket `draxos-internal-alpha`.
- Portal/Web gerados, mas aguardam host estatico externo porque Supabase Storage/Edge Functions nao servem HTML como pagina.
- Manifest remoto reconfigurado com URLs/hashes reais no default versionado da Edge Function `release`.
- Relatorio: `internal-alpha-v0-publication-report.md`.
- Falta publicar Portal/Web em host estatico externo e fazer signoff manual Fabio + 1 tester antes de `T03-P18`.

Politica:

- `latest_version` maior: mostrar update recomendado.
- `minimum_supported_version` maior que versao atual: bloquear acoes online e pedir update.
- Android/PC recebem link de download.
- Web recebe refresh/link para versao publicada.
- Destruir save e permitido apenas se explicitamente marcado no release notes e se houver backup/reset plan.

## Sistemas Da Build

As decisoes detalhadas de uso, layout, tooltips e fluxo ficam em `internal-alpha-v0-design-lock.md`.

### Batalha

- Mantem `battle_log_v1` server-authoritative.
- Cliente apenas apresenta replay.
- Mockup visual atual continua valido: palco 2D procedural, personagens parados, spells, buffs, dano, cooldowns, summons, Familiar, tooltips, HUD e readout compacto.
- Pequenas melhorias entram apenas se aumentarem clareza do playtest.

### Base

Precisa funcionar como fluxo de jogo, nao apenas snapshot.

Predios esperados do primeiro slice:

- Altar das Almas.
- Nucleo de Energia.
- Pocos de Sangue.
- Minas de Cristal.
- Estrutura de Stats.
- Ossario.

Cada predio precisa mostrar:

- level atual;
- producao ou beneficio;
- custo do proximo upgrade;
- tempo/restante;
- status da fila;
- botao de upgrade ou motivo objetivo para bloqueio.

Status local atual:

- a aba Base mostra placeholders clicaveis para os seis predios;
- cada predio tem painel proprio com level, beneficio, producao, custo, tempo, status e tooltip;
- o servidor calcula `can_upgrade`, `blocked_reason`, custo, duracao e remaining time;
- o cliente envia apenas intencao de coleta/upgrade/compra alpha e aplica o estado retornado.

### Social

Alpha basico:

- amigos por username;
- guilda criada por jogador;
- entrar em guilda por nome;
- lista de membros;
- chat de guilda por polling;
- mensagens de erro claras.

Status local atual:

- `GET /social/state` retorna identidade social de conta, amigos, guilda, membros, estruturas e mensagens enriquecidas com username.
- O save `progression_lab` mostra marcador `lab`; a identidade social canonica usa o save `normal` quando existir.
- A aba Social do Hub tem campos para username, nome da guilda e mensagem, com tooltips objetivos e painéis legíveis para dois testadores.
- `POST /social/chat/send` aplica rate limit alpha e retorna feedback amigável quando falta guilda, username nao existe ou a mensagem esta vazia.

### Competicao

Alpha basico:

- matchmaking preview;
- batalha normal atualiza pontos de arena no servidor;
- leaderboard mostra top 10, posicao do jogador e season ativa;
- bots podem ser oponente de treino, mas nao aparecem no ranking;
- `progression_lab` pode batalhar, mas nao pontua competicao.

### Loja

Proof-of-concept:

- redeems diarios `pequeno`, `medio`, `grande` e `premium` entregam apenas Diamante;
- reset dos redeems a meia-noite `America/Sao_Paulo`;
- premium pass alpha comprado com Diamante;
- fila dupla de construcao comprada com Diamante e aplicada na Base;
- pacote pequeno de Energia e pacote medio de recursos;
- claims free/premium idempotentes;
- sem pagamento real.

Status local atual:

- `GET /monetization/state` retorna `shop_summary`, `alpha_products` enriquecidos com custo, ganho, efeito, `can_purchase`, `already_redeemed`/`already_owned` e periodo de redeem.
- `POST /monetization/alpha-purchase` aplica redeems/compras com ledger e idempotencia; redeems diarios nao duplicam com novo `request_id` no mesmo dia.
- A aba Loja do Hub tem botoes de redeem/compra, paineis de resumo, grupos de produtos e recompensas, mensagens objetivas e desabilita produtos ja resgatados/ativos quando o estado esta carregado.

## Design Sessions Pendentes

Design lock fechado em `internal-alpha-v0-design-lock.md`.

Regras finais registradas:

- app hibrido entre idle/manager e hub de RPG;
- Android em paisagem, PC/Web com layout amplo;
- tela inicial com `Continuar`, `Progression Lab` e `Configuracoes`;
- amigos por username;
- usuarios em `progression_lab` aparecem com marcador vermelho `lab` no social/chat;
- redeems diarios entregam apenas Diamante;
- reset diario dos redeems a meia-noite `America/Sao_Paulo`;
- redeem `premium` deve cobrir o custo dos itens premium/conveniencia da loja alpha do build.

Estas decisoes vivem em `docs/design-pending.md` como `DMOB-D048` a `DMOB-D055`.

## Trabalho Manual Do Fabio

- Seguir o tutorial detalhado em `supabase-remote-tutorial.md`.
- Confirmar que o projeto Supabase remoto usado sera `armxgipvnbbshzqawklw`. (`feito em T03-P13`)
- Desativar email confirmation. (`feito e alinhado por supabase config push em T03-P14`)
- Copiar `Project URL` e publishable key para ambiente local/export seguro. (`feito localmente; nao versionar chave real`)
- Criar `.env.internal-alpha.local` ignorado no Git. (`feito localmente`)
- Criar/fornecer convites alpha. (`ALPHA-TEST` existe para smokes; convites humanos finais ainda podem ser definidos`)
- Guardar service role fora do Git.
- Criar keystore Android release internal alpha e guardar senha fora do Git. (`T03-P16`/`T03-P17` usaram debug fallback local; configurar release antes de uma distribuicao mais ampla ou se quiser updates Android com chave dedicada)
- Escolher URL/canal da Web build.
- Aprovar redeems da loja. (`feito para alpha atual; valores seguem calibraveis`)
- Testar com o segundo usuario e preencher checklist.

## Guardrails

- Nao publicar link Web achando que ele e privado por si so.
- Nao colocar secrets em arquivos exportados.
- Nao deixar Progression Lab alterar save normal.
- Nao usar loja alpha como pagamento real.
- Nao tratar leaderboard alpha como balance final.
- Nao importar assets externos nesta fase sem nova decisao.
