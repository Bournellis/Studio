# First Session Clarity v1

- Status: `VALIDADO_LOCAL`
- Data: `2026-05-30`
- Escopo: client-only

## Objetivo

First Session Clarity v1 melhora a primeira leitura do loop publicado sem mudar backend, schema, simulador, economia, tuning ou conteudo.

O jogador/tester deve entender rapidamente:

1. onde esta no Refugio;
2. qual e o proximo passo;
3. por que coletar, evoluir, preparar e batalhar fazem parte do mesmo ciclo;
4. como a recompensa da batalha volta para a base.

Fluxo protegido:

`Refugio -> coletar -> evoluir -> preparar -> batalhar -> recompensa -> voltar para base`

## O Que Mudou

- Refugio ganhou uma linha persistente de primeira sessao dentro do painel `Progresso`.
- A CTA principal do Refugio recebeu tooltips mais orientadas ao ciclo: recompensa, coleta, evolucao e batalha.
- Preparacao agora explica, em uma frase curta, como ler a tela antes da primeira batalha.
- Resultado de batalha ganhou o bloco `Proximo passo`, conectando recompensa recebida com coleta, evolucao da base e nova batalha.
- `tools/smoke_foundation_loop.gd` passou a validar as mensagens de primeira sessao em recompensa, coleta, evolucao e resumo.
- Testes client cobrem a nova copy em Refugio, Preparacao e Resultado.

## Contratos

- API publica: sem mudanca.
- Supabase/schema/migration: sem mudanca.
- Simulador, recompensa, economia e tuning: sem mudanca.
- Conteudo, armas, spells, pocoes e comportamento: sem mudanca.
- Publicacao: deve usar a pipeline Internal Alpha ja existente.

## Fora De Escopo

- Tutorial longo ou narrativa de onboarding.
- Novo fluxo de conta/save.
- Social expansion, direct chat, ajudas, contribuicoes ou moderacao.
- Novas armas, spells, pocoes, receitas, comportamento avancado ou tuning numerico.
- Visual final ou assets finais.
- Account/save migration para `account_profiles` + `game_saves`.

## Criterios De Aceite

- Refugio mostra uma pista de primeira sessao junto do painel de progresso.
- Coleta, evolucao e batalha continuam usando a CTA contextual existente.
- Preparacao nao usa termos tecnicos visiveis como `build`, `behavior`, `slot`, `endpoint`, `schema` ou `snapshot`.
- Resultado da batalha orienta o retorno para a base e o proximo passo.
- Layout responsivo de Entry/Refugio/Batalha continua passando em `tools/smoke_responsive_layout.gd`.
- `validate_foundation.ps1 -Profile Client` passa antes da publicacao.

## Validacao Local

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools\smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools\smoke_responsive_layout.gd
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:`$false }"
```

Resultado em `2026-05-30`: PASS. O runner Client passou com GUT `123/123` e `1990` asserts, `smoke_foundation_loop.gd`, `smoke_responsive_layout.gd`, `smoke_runtime_config.gd`, `smoke_foundation_hardening.gd`, `smoke_exports.gd`, Deno release typecheck light e `git diff --check`.

## Proxima Decisao

Depois da revisao manual Android/Windows/Web deste pacote, a decisao recomendada e escolher entre:

- ajuste pontual de primeira sessao, se o loop ainda tiver friccao;
- Social Routine v1.1, se a primeira sessao for aceita;
- um passe visual pequeno apenas se a compreensao do loop estiver bloqueada por apresentacao.
