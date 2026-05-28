# Track 09 Agent Prompts

## T09-A Coordination / Visual Direction

```text
Vamos trabalhar em D:\Estudio\Projetos\draxos-mobile. Nao edite direto em D:\Estudio: crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t09-coordenacao e branch codex/draxos-mobile/t09-coordenacao.

Objetivo: abrir Track 09 - Portrait Entry, Refugio Scene And Visual Loop Rework. Documente a decisao: Entry e a primeira tela operacional; Refugio e a home jogavel/Base; o app inteiro fica portrait por enquanto; assets/referenciaimagens e moodboard, nao asset runtime.
```

## T09-B Route / Orientation Foundation

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t09-route-orientation e branch codex/draxos-mobile/t09-route-orientation. Dependa de T09-A.

Objetivo: ajustar AppRoutes/AppShell para root entry, playable refuge, base_management, aliases legados e portrait fixo. Android, PC e Web nao devem depender de landscape. Nao alterar backend, schema, economia ou simulador.
```

## T09-C Entry Page

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t09-entry-page e branch codex/draxos-mobile/t09-entry-page. Dependa de T09-B.

Objetivo: criar pagina inicial Entry com Login/Criar conta, save normal/lab, reset com confirmacao, Labs Dev quando habilitado e CTA Entrar no Refugio. Preservar acoes existentes no boot.gd.
```

## T09-D Refugio Scene

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t09-refugio-scene e branch codex/draxos-mobile/t09-refugio-scene. Dependa de T09-B.

Objetivo: transformar o Refugio em cena portrait com altar, recursos/status e hotspots para Batalha, Base, Social, Competicao, Loja e Perfil. Base atual vira gestao interna, nao primeira tela.
```

## T09-E Internal Menus

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t09-internal-menus e branch codex/draxos-mobile/t09-internal-menus. Dependa de T09-D.

Objetivo: adaptar Base management, Social, Competicao e Loja para telas/paineis internos com Voltar no layout portrait. Nao alterar contratos HTTP, schema, economia, ranking ou mensagens.
```

## T09-F Battle Portrait

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t09-battle-portrait e branch codex/draxos-mobile/t09-battle-portrait. Dependa de T09-B.

Objetivo: recriar battle_running e battle_summary em portrait fullscreen, com botao Pular grande e summary completo. Nao alterar simulador, recompensa, battle_log_v1 ou endpoints battle/*.
```

## T09-G Visual Reference / Asset Slots

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t09-visual-reference e branch codex/draxos-mobile/t09-visual-reference. Dependa de T09-D.

Objetivo: documentar slots visuais, placeholders e politica de uso de assets/referenciaimagens como moodboard. Nao importar arte final.
```

## T09-H Validation

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t09-validation e branch codex/draxos-mobile/t09-validation. Dependa de T09-C a T09-G.

Objetivo: atualizar smokes e GUT para o novo loop portrait-first: entry root, refuge scene, internal screens, battle portrait, PC/Web vertical. Remover expectativas landscape antigas.
```

## T09-I Integration

```text
Crie worktree D:\Estudio-worktrees\draxos-mobile--codex--t09-integration e branch codex/draxos-mobile/t09-integration. So comece depois de T09-C a T09-H entregarem.

Objetivo: integrar Track 09, resolver conflitos, validar matriz completa e atualizar status/portfolio. Guardrails: sem backend, schema, tuning, assets finais ou publicacao remota.
```
