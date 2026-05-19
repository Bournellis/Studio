# Current Status

- Last Updated: `2026-05-19`
- Active Project Name: `draxos-mobile`
- Active Surface: `Track 00 — First Slice Foundation`
- Active Track: `Track 00 - First Slice Foundation`
- Active Track Status: `OPEN`
- Current Operational Baseline: `Design do primeiro slice fechado para implementacao. Decisoes pre-implementacao resolvidas (Blocos 1-3, B4.1). Pendencias de design registradas no Bloco 6. Godot project nao inicializado. Supabase project nao configurado.`

---

## Estado Do Design — Visao Rapida

| Sistema | Estado | Observacao |
|---|---|---|
| Personagem (level, stats, XP) | Definido | Cap universal de level = Level Global |
| Arma — Varinha Magica | Definido | Tipo: Varinha (Magico). Qualidade via Ossos. Level 40/season. |
| Spells (10) | Definido | Unlock por level minimo no Altar das Almas. Targeting definido. |
| Summons (3 posicoes) | Definido | HP, duracao, recast, targeting definidos. Escala por level: pendente. |
| Pet (7 opcoes) | Definido | Desbloqueio do slot: **pendente** |
| Passivas (5 opcoes) | Definido | Desbloqueio do slot: **pendente** |
| Sistema de combate | Definido | 7 tipos de dano, DoTs, resistencias, barreiras, status effects, anti-stall |
| Maestria (arma + spells) | Definido | Calculo por fonte de dano. Spells de utilidade: parcialmente definido |
| Base Manager (6 estruturas) | Definido | Permanentes. Cada predio abriga seus upgrades. |
| Estrutura de Stats | Incompleto | Predio incluido no slice mas sem mecanica definida |
| Ossario — producao de Ossos | Incompleto | Taxa de Ossos/hora por level: **pendente** |
| Economia de recursos | Definido | 6 recursos. Gap de Energia intencional (~2x). |
| Sistema de XP e Cotas | Definido | Dobrada/Normal/Reduzida. Acumula 3 dias. Reset semanal. |
| Season (4 meses) | Definido | O que reseta vs permanece: definido |
| Matchmaking + Ranking | Parcial | Formula de poder definida. Pesos e faixa ±X: calibrar no alpha. |
| Diamante (moeda premium) | Parcial | Escala relativa definida. Valores absolutos e lista completa: pendentes. |
| Battle Pass | Parcial | 2 tiers, 2 por season. Conteudo por tier: pendente. |
| Recompensas diarias/semanais | Parcial | Estrutura definida (rewarded ads). Conteudo exato: pendente. |
| Missoes diarias | Parcial | Definido como "bonus 3 primeiras vitorias". Sistema completo: pendente. |
| Quests / Onboarding | Pendente | Estrutura registrada. Conteudo e valores: pendentes. |
| Social (amigos, guilda) | Parcial | Estrutura definida. Custos e bonus da guilda: pendentes. |
| Cosmeticos | Pendente | Categorias listadas. Conteudo: pendente. |
| Schema do banco | Parcial | Referencia inicial em architecture.md. Tabela builds: schema incompleto (pendente design). |

---

## Decisoes Pre-Implementacao

Ver `docs/pre-implementation-decisions.md` para o registro completo.

**Resolvidos:** Blocos 1 (simulador de batalha), 2 (arquitetura de progressao), 3 (mecanicas com comportamento indefinido), B4.1 (XP de construcoes).

**Pendentes antes do playtest:** B4.2 (curva de Energia por perfil de jogador).

**Registrados para o alpha:** Bloco 5 (calibraveis com dados reais).

**Design incompleto registrado:** Bloco 6 — ver lista de criticos e incompletos.

---

## Baseline De Conceito

Decisoes de design completas para o primeiro slice:

- Personagem: Draxos, sem classes, varinha magica (dano Magico), 0-3 spells, 1 passiva, 1 pet, sistema de summons
- Combate: 7 tipos de dano, DoTs, resistencias, barreiras, status effects, anti-stall AoE total aos 30s
- Base Manager: 6 estruturas permanentes, cada uma abriga seus proprios upgrades, Energia como recurso escasso
- Economia: XP cubico (Tibia-inspired), cotas diarias, 6 recursos (inclui Ossos e Diamante), gap de Energia intencional
- Social: amigos, guilda com construcoes e bonus passivos, chat de guilda + direct
- Infraestrutura: Godot 4.x, Supabase, batalha 100% servidor, 3 plataformas (Android, PC, browser)
- Season: 4 meses, 2 Battle Passes, cap de level = 40 (S1)
- Cap universal: Level Global e teto de arma, spells e construcoes

Documentos de design em:
- `docs/game-design-document.md` (referencia condensada — autoritativo para implementacao)
- `../../_conceitos/mobile-universe/gdd.md` (GDD completo — arquivo historico de design)
- `../../_conceitos/mobile-universe/pendencias.md` (historico de decisoes de design)
- `docs/pre-implementation-decisions.md` (decisoes pre-implementacao — estado atual das pendencias)

---

## Active Goal

Executar Track 00: inicializar Godot project, configurar Supabase, estabelecer conexao cliente-servidor, implementar conta guest e loop minimo de batalha simulada.

---

## Read Next

- `../AGENTS.md`
- `docs/pre-implementation-decisions.md`
- `docs/game-design-document.md`
- `docs/architecture.md`
- `implementation/tracks/track-00-first-slice-foundation/current-status.md`

---

## Validation

Godot project nao existe ainda — nao ha validacao disponivel.

Quando inicializado:
```powershell
D:\Estudio\.local-tools\godot\4.x\Godot_vX.X.X-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
```

---

## Next

Iniciar `Track 00 - First Slice Foundation`:
1. Inicializar Godot project 4.x em `D:\Estudio\Projetos\draxos-mobile\`
2. Configurar Supabase project (Auth, Postgres, Edge Functions)
3. Implementar conexao HTTPRequest Godot → Supabase
4. Criar schema inicial do banco (ver `docs/architecture.md`)
5. Implementar conta guest com codigo de convite
6. Implementar loop minimo: solicitar batalha → receber log → animar resultado
