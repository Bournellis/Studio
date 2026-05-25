# Track 02 - Progression Lab

- Status: `IN_PROGRESS - ESTABLISHMENT`
- Projeto: `draxos-mobile`
- Objetivo: calibrar as primeiras `2h`, `5h`, `10h`, `15h` e `20h` de gameplay ativo com dados cruzados de economia, combate, poder, bots, moeda premium e playtest manual no Godot.

## Problema

O alpha ja possui combate server-authoritative, economia v0, Base, Social, Monetizacao, Battle Lab e simulador economico. Falta uma camada que transforme esses sistemas em estados saudaveis reproduziveis para testar o loop inicial em horas especificas de jogo.

Essa track cria essa camada.

## Entregas

- Documentacao operacional do Progression Lab.
- Modelo versionado com milestones e perfis de jogador.
- Gerador offline de estados saudaveis, relatorios e recomendacoes de poder.
- Seeder local para Supabase criando saves dev reproduziveis.
- Fluxo dev-only no Godot para preparar, carregar e testar manualmente os saves.
- Integracao com Battle Lab para rodar builds dos saves saudaveis.
- Pool inicial de bots e leitura de poder por milestone.

## Milestones

Horas acumuladas de gameplay ativo:

- `2h`
- `5h`
- `10h`
- `15h`
- `20h`

## Perfis

- `free_50_rewards`: jogador free que completa 50% das recompensas.
- `free_100_rewards`: jogador free que completa 100% das recompensas.
- `freemium_basic`: Battle Pass + segunda fila de construcao, completa 80% das recompensas.
- `spender_light`: Battle Pass + segunda fila + gasto leve na loja, completa 100% das recompensas.
- `max_spender`: tempo/gasto maximo possivel para medir teto de aceleracao.

## Fora Do Escopo

- Deploy remoto.
- Pagamento real.
- Ads reais.
- Ajuste definitivo de combate/economia sem relatorio before/after.
- iOS e mobile browser.
- Novos modos pos-slice.

## Criterios De Aceite

- Gerar os 25 estados `5 perfis x 5 milestones`.
- Gerar relatorios offline em `docs/progression-lab/generated/`.
- Seedar estados no Supabase local sem escrever secrets versionados.
- Carregar pelo menos `2h`, `10h` e `20h` no Godot dev-only.
- Rodar Battle Lab usando builds do Progression Lab.
- Produzir recomendacoes de bots e poder sem aplicar automaticamente novos pesos ao jogo.
