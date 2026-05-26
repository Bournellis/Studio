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

- Criar/configurar projeto Supabase remoto Free.
- Desativar email confirmation no alpha interno.
- Configurar URL e anon key por ambiente local, sem commitar secrets.
- Criar ambiente `internal_alpha_v0` no cliente Godot.
- Validar Edge Functions em remoto com healthcheck.
- Documentar reset controlado do banco alpha.

Saida esperada:

- Runbook operacional com passos manuais executaveis.
- Smoke remoto minimo: auth, healthcheck e account state.

### T03-P03 - Conta Email/Senha E Dois Saves

- Implementar fluxo email/senha.
- Manter guest/local como fallback de desenvolvimento, se ainda util.
- Criar/ajustar schema para dois saves por conta: `normal` e `progression_lab`.
- Adicionar reset separado por save.
- Garantir que endpoints server-authoritative recebem/resolvem save correto.
- Garantir que `progression_lab` nao escreve ranking/social normal.

Saida esperada:

- Teste de cross-platform save por token remoto.
- Smokes de reset separado e isolamento.

### T03-P04 - Progression Lab Exportado Interno

- Gatear Progression Lab por flag internal alpha.
- Permitir aplicar perfis/milestones ao save `progression_lab`.
- Mostrar claramente quando o usuario esta no save lab.
- Bloquear ou isolar ranking/social/loja normal quando estiver no lab, conforme design lock.

Saida esperada:

- Um testador consegue alternar entre normal e lab sem corromper progressao.

### T03-P05 - Base Manager Jogavel

- Transformar predios da Base em tela navegavel de alpha.
- Cada predio precisa ter estado, upgrade, custo, tempo, producao/beneficio e feedback.
- Menus devem ser rolaveis em Android/PC/Web.
- Coleta, upgrade e conclusao de job continuam server-authoritative.
- Erros precisam ser objetivos: recurso insuficiente, fila cheia, estrutura em upgrade, offline.

Saida esperada:

- Fluxo de base completo para o save normal e snapshot/isolamento para lab.

### T03-P06 - Social Basico Funcional

- Amigos por username/codigo.
- Guilda: criar/entrar/ver membros.
- Chat de guilda por polling.
- Feedback de rate limit, sem guilda, usuario nao encontrado, offline.
- Dados de social vinculados ao save/conta conforme decisao de design.

Saida esperada:

- Dois testadores conseguem se encontrar e trocar mensagem em guilda.

### T03-P07 - Competicao E Leaderboards

- Ranking basico da season alpha.
- Pontos de arena atualizados por batalha server-authoritative.
- Bots entram ou nao entram conforme design lock.
- UI mostra posicao do jogador, top lista e contexto de season.
- Matchmaking preview continua legivel.

Saida esperada:

- Batalhas alteram pontos e leaderboard atualiza sem mutacao client-side.

### T03-P08 - Loja Proof-Of-Concept

- Redeems alpha fixos para testar premium em varios niveis.
- Produtos: Diamante, premium pass, energia/recurso e reset/boost se aprovado no design lock.
- Claims free/premium do Battle Pass permanecem idempotentes.
- Nenhum gateway real de pagamento.
- UI deixa claro que e alpha internal.

Saida esperada:

- Testador free consegue simular estados premium por redeem e observar impacto no save correto.

### T03-P09 - Batalha Visual Polish Pequeno

- Preservar mockup visual atual como baseline.
- Ajustar apenas clareza de HUD, mensagens, replay, cooldown e tooltips se surgirem no playtest.
- Nao adicionar assets externos nesta track.

Saida esperada:

- Batalha continua boa o suficiente para validar o jogo real enquanto arte final nao existe.

### T03-P10 - Releases E Updates

- Criar schema de manifest remoto em Supabase Storage.
- Cliente consulta manifest no boot e mostra status de update.
- Definir `minimum_supported_version`, `latest_version`, links de Android/PC/Web e notas.
- Exportar Android, PC e Web com mesmo version code/name.
- Publicar artefatos em local definido.

Saida esperada:

- As tres plataformas sabem quando existe update e onde buscar.

### T03-P11 - QA, Smokes E Playtest Fechado

- Rodar validate/GUT.
- Rodar smokes remotos.
- Rodar checklist interno com duas contas.
- Registrar bugs e lacunas.
- Criar relatorio curto de build `internal_alpha_v0`.

Saida esperada:

- Build fechada testavel por Fabio + 1 amigo.

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

- Criar ou confirmar projeto Supabase remoto Free para `internal_alpha_v0`.
- Desativar email confirmation no projeto alpha.
- Guardar `SUPABASE_SERVICE_ROLE_KEY` fora do Git.
- Informar URL e anon key publica do projeto remoto quando a implementacao precisar testar remoto.
- Criar email/senha dos testadores ou permitir cadastro com convite.
- Criar keystore Android internal alpha e guardar senha fora do Git.
- Escolher onde hospedar a Web build e se o link sera unlisted.
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

O smoke remoto ainda precisa ser implementado em T03-P02/T03-P03.

## Regra De Commit

- T03-P00 deve ficar em commit separado de preparacao.
- Cada pacote funcional deve ter commit proprio quando possivel.
- Nao misturar artefatos gerados de laboratorio com mudancas de contrato/codigo.
- Worktree deve terminar limpa a cada etapa entregue.
