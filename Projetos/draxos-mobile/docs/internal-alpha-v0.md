# DraxosMobile - Internal Alpha v0

- Ultima atualizacao: `2026-05-26`
- Fonte de execucao: `../implementation/tracks/track-03-internal-alpha-v0/`
- Design lock: `internal-alpha-v0-design-lock.md` (`LOCKED`)
- Setup remoto: `internal-alpha-remote-setup.md`
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

Status local atual (`T03-P07`):

- Godot persiste o save ativo e envia `x-draxos-save-type`.
- Supabase local resolve `normal` e `progression_lab` por `players.save_type`.
- Uma mesma sessao Auth pode criar/carregar dois players/saves distintos.
- Batalha, Base, Social, Competicao, Loja e Telemetria usam o save ativo no servidor.
- `progression_lab` fica fora do ranking com motivo explicito `PROGRESSION_LAB_DOES_NOT_RANK`.
- O hub possui reset perigoso do save ativo; o servidor reconstrui apenas aquele save, preservando o outro.
- A tela Progression Lab Dev possui `Aplicar no Save Lab`; o servidor valida o perfil/milestone contra o catalogo versionado, aplica apenas no save `progression_lab` e preserva o save `normal`.
- A Base ja funciona como fluxo jogavel local: mapa de predios clicaveis, painel por predio, tooltips, custo/tempo/producao/status vindo do servidor, compra alpha de Energia e upgrade server-authoritative por estrutura.
- O Social ja funciona como fluxo basico local: amigos por username, criar/entrar em guilda, membros/estruturas visiveis, chat de guilda por polling, rate limit e marcadores `normal`/`lab`.
- A Competicao ja funciona como leaderboard alpha local: batalha normal pontua no servidor, ranking mostra top 10 + posicao do jogador, bots ficam fora da tabela e o Lab continua sem pontuacao.

## Backend Remoto

Alvo inicial:

- Supabase Free.
- Edge Functions para acoes autoritativas.
- Postgres com RLS.
- Storage para manifest e artefatos de update.
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

Regra anti-lock-in:

- Godot usa endpoints logicos do jogo, nao detalhes internos do Supabase.
- `service_role`, policies e tabelas sao detalhes de backend.
- IDs internos do jogo devem permitir migracao futura para API propria.

## Updates E Distribuicao

Todos os canais usam a mesma cadencia de versao.

Manifest remoto em Supabase Storage:

```json
{
  "schema_version": "internal_alpha_manifest_v1",
  "channel": "internal_alpha",
  "latest_version": "0.0.1-alpha.0",
  "minimum_supported_version": "0.0.1-alpha.0",
  "released_at": "2026-05-26T00:00:00Z",
  "notes": ["Primeira build interna"],
  "artifacts": {
    "android": { "url": "https://...", "sha256": "..." },
    "pc_windows": { "url": "https://...", "sha256": "..." },
    "web": { "url": "https://..." }
  }
}
```

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
- Mockup visual atual continua valido: palco 2D procedural, personagens parados, spells, buffs, dano, cooldowns, summons, Familiar, tooltips e HUD.
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

- redeem alpha de Diamante/moedas;
- premium pass alpha;
- pacotes fixos para testar diferentes niveis premium;
- claims free/premium idempotentes;
- sem pagamento real.

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

- Criar projeto Supabase remoto Free ou confirmar qual sera usado.
- Desativar email confirmation.
- Copiar `Project URL` e publishable key para ambiente local/export seguro.
- Criar/fornecer convites alpha.
- Guardar service role fora do Git.
- Criar keystore Android internal alpha e guardar senha fora do Git.
- Escolher URL/canal da Web build.
- Aprovar redeems da loja.
- Testar com o segundo usuario e preencher checklist.

## Guardrails

- Nao publicar link Web achando que ele e privado por si so.
- Nao colocar secrets em arquivos exportados.
- Nao deixar Progression Lab alterar save normal.
- Nao usar loja alpha como pagamento real.
- Nao tratar leaderboard alpha como balance final.
- Nao importar assets externos nesta fase sem nova decisao.
