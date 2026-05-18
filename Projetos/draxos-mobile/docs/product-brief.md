# DraxosMobile — Product Brief

- Ultima atualizacao: `2026-05-18`

---

## O Produto

DraxosMobile e um jogo mobile multi-partes. O jogador e um Draxos — mago intergalactico — que comeca fraco e cresce em poder ate se tornar uma ameaca cosmica.

O jogador nao e o heroi. O jogador e o vilao.

Todos os modos pertencem a um unico ecossistema com conta, personagem, base e progressao conectadas.

---

## Plataformas

| Plataforma | Status |
|---|---|
| Android | Primeiro slice — app nativo |
| PC (Windows/Linux) | Primeiro slice — executavel |
| PC Browser | Primeiro slice — Godot web export |
| iOS | Futuro |
| Mobile browser | Fora do escopo |

---

## Primeiro Slice — Escopo

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
| Engine | Godot 4.x |
| Backend | Supabase (Auth, Postgres, Edge Functions, Realtime) |
| Batalha | 100% servidor — cliente anima log de eventos |
| Autenticacao | Guest + username/senha + Google Sign-In |
| Alpha | Convite por codigo, APK sideload + PC executavel |
| Season | 4 meses, 2 Battle Passes por season |
| Level maximo Season 1 | 40-50 |

---

## Documentos De Design Completos

O design detalhado do jogo esta em:

- `../../Projetos/_conceitos/mobile-universe/gdd.md` — GDD completo com todos os sistemas, formulas e valores
- `../../Projetos/_conceitos/mobile-universe/pendencias.md` — decisoes abertas e historico de resolucoes
- `docs/game-design-document.md` — referencia de implementacao condensada
- `docs/architecture.md` — arquitetura tecnica
