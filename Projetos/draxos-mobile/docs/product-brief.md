# DraxosMobile - Product Brief

- Ultima atualizacao: `2026-05-19`

---

## O Produto

DraxosMobile e um jogo mobile multi-partes. O jogador e um Draxos, mago intergalactico que comeca fraco e cresce em poder ate se tornar uma ameaca cosmica.

O jogador nao e o heroi. O jogador e o vilao.

Todos os modos pertencem a um unico ecossistema com conta, personagem, base e progressao conectadas.

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

---

## Primeiro Slice - Escopo

| Sistema | Incluido |
|---|---|
| Character Autobattler PVP assincrono | Sim |
| Base Manager (Altar/Santuario) | Sim |
| Lista de amigos + guilda + ajudas | Sim |
| Chat de guilda + mensagens diretas | Sim |
| Ranking por pontos de arena | Sim |
| Matchmaking por poder | Sim |
| Builds simuladas (bots) | Sim |
| Conta guest + registrada + Google Sign-In | Sim |
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

## Decisoes Tecnicas Principais

| Decisao | Valor |
|---|---|
| Engine | Godot `4.6.2-stable` |
| Testes client | GUT `9.6.0` |
| Backend | Supabase Auth, Postgres, Edge Functions, Realtime |
| Batalha | 100% servidor - cliente anima log de eventos |
| Autenticacao | Guest + username/senha + Google Sign-In |
| Alpha | Convite por codigo, APK sideload + PC executavel |
| Season | 4 meses, 2 Battle Passes por season |
| Level maximo Season 1 | 40 |

---

## Documentos Vivos

- `game-design-document.md` - design autoritativo para implementacao.
- `design-pending.md` - pendencias de design e balanceamento.
- `contracts/` - contratos tecnicos antes das migrations/codigo.
- `../implementation/tracks/track-00-first-slice-foundation/scope.md` - escopo da Track 00.
- `../../_conceitos/mobile-universe/gdd.md` - GDD historico completo.
- `../../_conceitos/mobile-universe/pendencias.md` - historico de decisoes da fase conceitual.
