# DraxosMobile - Product Brief

- Ultima atualizacao: `2026-05-27`

---

## O Produto

DraxosMobile e um jogo mobile multi-partes. O jogador e um Draxos, mago intergalactico que comeca fraco e cresce em poder ate se tornar uma ameaca cosmica.

O jogador nao e o heroi. O jogador e o vilao.

Todos os modos pertencem a um unico ecossistema com conta, personagem, base e progressao conectadas.

Fonte viva de visao longa: `product-vision.md`. Este brief resume o produto e o slice atual; a visao longa define pilares, anti-pilares, limites de monetizacao, live ops, backend e futuro nao prometido.

---

## Plataformas

| Plataforma | Status |
|---|---|
| Android | Primeiro slice - app nativo |
| PC Windows/Linux | Primeiro slice - executavel |
| PC Browser | Primeiro slice - Godot web export |
| iOS | Futuro |
| Mobile browser | Fora do escopo |

---

## Track 00

Track 00 monta o primeiro slice completo. A primeira etapa e o MVP tecnico minimo.

| Nivel | Inclui |
|---|---|
| MVP tecnico minimo | Godot 4.6.2 + Supabase, guest com convite, batalha fixture server-authoritative e log animavel placeholder |
| Primeiro slice completo | PVP autobattler, base manager, social, ranking, bots, conta, economia, Battle Pass/Diamante, validacao e exports |

## Track 03 - Internal Alpha v0

Track 03 transforma o alpha local em uma build fechada realista para Fabio + 1 amigo. O objetivo e simular um jogo real com conta, save compartilhado entre plataformas, servidor remoto, updates e features principais funcionando em estado de prova profissional.

| Pilar | Decisao |
|---|---|
| Conta | Email + senha via Supabase Auth |
| Acesso | Convite/flag alpha; link Web pode ser publico/unlisted, mas login e acesso alpha sao obrigatorios |
| Saves | Dois saves por conta: `normal` e `progression_lab`, com reset separado |
| Progression Lab | Ferramenta interna/gated, isolada do save normal |
| Loja | Redeems alpha fixos para testar niveis premium sem pagamento real |
| Backend | Supabase remoto Free primeiro |
| Updates | Android, PC e Web recebem a mesma cadencia via manifest remoto |

---

## Primeiro Slice - Escopo

| Sistema | Incluido |
|---|---|
| Character Autobattler PVP assincrono | Sim |
| Base Manager (Refugio) | Sim |
| Lista de amigos + guilda + ajudas | Sim |
| Chat de guilda + mensagens diretas | Sim |
| Ranking por pontos de arena | Sim |
| Matchmaking por poder | Sim |
| Builds simuladas (bots) | Sim |
| Conta guest + registrada + Google Sign-In | Sim; Internal Alpha v0 prioriza email/senha, guest fica para dev/local enquanto util |
| Varinha Magica (arma unica) | Sim |
| 0-3 slots de spell com selecao | Sim |
| 1 slot de passiva (5 opcoes) | Sim |
| 1 slot de pet (7 opcoes) | Sim |
| Battle Pass (Free + Premium) | Sim |
| Moeda premium (Diamante) | Sim |
| Character Autobattler PVE | Futuro |
| PVP Cardgame Roguelike | Futuro |
| Hero Defense | Futuro |
| Open World RPG | Futuro |

---

## UX/Layout Base Do Primeiro Slice

O primeiro slice usa um layout funcional de alpha, com visual final de producao fora do escopo. A navegacao principal parte do `Refugio`, que concentra personagem, poder, recursos, fila de construcao e atalhos para os sistemas.

Telas principais:

| Tela | Funcao |
|---|---|
| Refugio | Hub principal, status do Draxos, poder, recursos, fila de construcao e proximas acoes |
| Batalha | Preview de matchmaking, iniciar batalha, replay, skip/velocidade e resumo de recompensa |
| Base | Seis estruturas, upgrades, coleta offline, armazenamento, pedir/enviar ajuda |
| Social | Amigos, guilda, ajudas, chat de guilda e direct por polling |
| Loja/Passe | Battle Pass, Diamante, recompensas diarias/semanais e fluxos de teste do alpha |

Direcao visual: cartoon gore sombrio, arcano e legivel em mobile, sem depender de arte final para validar loop e balanceamento.

---

## Decisoes Tecnicas Principais

| Decisao | Valor |
|---|---|
| Engine | Godot `4.6.2-stable` |
| Testes client | GUT `9.6.0` |
| Backend alpha | Supabase Auth, Postgres, Edge Functions, Storage e Realtime quando util |
| Plano de saida | Backend Proprio + Postgres |
| Nakama | Alternativa futura apenas se realtime/lobbies/matchmaking/social competitivo virar pilar |
| Batalha | 100% servidor - cliente anima log de eventos |
| Autenticacao | Guest local/dev + email/senha no Internal Alpha v0; Google Sign-In futuro |
| Alpha | Convite/flag alpha, Web/PC/Android internos, APK sideload ou canal interno |
| Season | 4 meses, 2 Battle Passes por season |
| Level maximo Season 1 | 40 por padrao; simulador permite testar 40/50/60 |
| Persistencia de levels | Todos os levels sao permanentes; seasons futuras aumentam o cap |

## Direcao Online

DraxosMobile nao depende de jogadores juntos na mesma partida. As partidas sao PvE/PVP assincronas: o servidor resolve, grava resultado e entrega um replay para o cliente apresentar.

Social existe como camada de retencao e cooperacao, nao como partida realtime:

- amigos por username;
- chat privado/direct;
- chat de guilda;
- guilda;
- ajudas e contribuicoes;
- possivel transferencia de recursos se aprovada em design futuro.

Essa direcao favorece dados relacionais, transacoes, ledger e auditoria. Por isso, Supabase e uma boa ponte para a alpha, e Backend Proprio + Postgres e o melhor alvo de maturidade se o jogo crescer.

---

## Documentos Vivos

- `product-vision.md` - visao longa local, pilares, anti-pilares e limites do produto.
- `game-design-document.md` - design autoritativo para implementacao.
- `design-pending.md` - pendencias de design e balanceamento.
- `contracts/` - contratos tecnicos antes das migrations/codigo.
- `../implementation/tracks/track-00-first-slice-foundation/scope.md` - escopo da Track 00.
- `../implementation/tracks/track-03-internal-alpha-v0/scope.md` - escopo da Internal Alpha v0.
- `../implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/scope.md` - pos-handoff, UX Android/onboarding, modularizacao do Hub e gates futuros.
- `internal-alpha-v0.md` - runbook operacional da build fechada.
- `../../_conceitos/mobile-universe/gdd.md` - GDD historico completo.
- `../../_conceitos/mobile-universe/pendencias.md` - historico de decisoes da fase conceitual.
