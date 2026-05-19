# Track 00 - Scope

- Ultima atualizacao: `2026-05-19`
- Status: escopo definido para preparacao de implementacao
- Projeto: `draxos-mobile`

## Objetivo

Track 00 monta o primeiro slice completo do DraxosMobile. A primeira etapa da track e um MVP tecnico minimo que prova a arquitetura Godot 4.6.2 + Supabase antes de implementar sistemas completos.

## MVP Tecnico Minimo

O MVP tecnico minimo prova arquitetura, persistencia e fluxo client-server. Ele nao prova balanceamento.

Inclui:

- Projeto Godot 4.6.2 abrindo tela simples com botoes `Entrar como guest`, `Solicitar batalha`, `Ver resultado`.
- Supabase com schema minimo para `players`, `resources`, `builds`, `battles`, `bot_builds`, `invite_codes`.
- Conta guest com codigo de convite e progresso salvo no servidor.
- Edge Function logica `battle/request` com bot fixture, simulacao deterministica, gravacao de resultado e retorno de log.
- Cliente Godot chamando Supabase via HTTPRequest e exibindo timeline placeholder do log.
- Fixture tecnica `MVP_ONLY`: Draxos level 1, Varinha Magica, Raio Cosmico, bot basico e recompensa tecnica.
- Recuperacao do ultimo estado e ultima batalha apos reabrir cliente.

Fora do MVP tecnico:

- Pets, passivas, guilda, chat, ranking, Battle Pass, Diamante, loja, ads, Google Sign-In, email/senha, social real e balanceamento final.

Aceite:

- Criar conta guest com convite.
- Solicitar batalha e receber log versionado.
- Resultado fica gravado no servidor.
- Cliente reabre e recupera estado minimo.
- Validacao headless do cliente e testes server minimos passam.

## Primeiro Slice Completo

A Track 00 completa termina quando houver:

- Conta guest, email/senha, Google Sign-In, migracao guest, convite de alpha e persistencia servidor-side.
- PVP autobattler assincrono com varinha, spells do primeiro slice, pets, passivas, summons, anti-stall, recompensas, replay e skip/velocidade visual.
- Base Manager com 6 estruturas, fila de construcao, coleta offline, upgrades, armazenamento, ajudas sociais e custos validados.
- Matchmaking por poder com jogadores reais e bots simulados.
- Ranking por season com snapshot.
- Social funcional: amigos, guilda, ajuda de construcao, chat de guilda e direct por polling.
- Economia funcional: XP/cotas, Almas, Energia, Sangue, Cristais, Ossos, Diamante, recompensas diarias/semanais, Battle Pass Free/Premium.
- Validacao com GUT, testes Deno/TypeScript para Edge Functions, migrations verificaveis e smoke de export PC, Android e PC browser.

## Fora Da Track 00

- iOS.
- Mobile browser.
- Character Autobattler PVE.
- PVP Cardgame Roguelike.
- Hero Defense.
- Open World RPG.
- Chat global interno.
- Hierarquia Draxos profunda.
- Visual final de producao alem do minimo necessario para playtest.

## Gate De Design

Toda decisao de design pendente deve estar registrada em `../../../docs/design-pending.md`.

- O MVP tecnico nao tem pendencia de game design aberta, pois usa fixtures.
- O primeiro slice completo so pode fechar quando as pendencias `PRIMEIRO_SLICE` e `PLAYTEST_ALPHA` necessarias ao slice estiverem resolvidas ou formalmente reclassificadas.
