# Current Status

- Last Updated: `2026-05-18`
- Active Project Name: `draxos-mobile`
- Active Surface: `Track 00 — First Slice Foundation`
- Active Track: `Track 00 - First Slice Foundation`
- Active Track Status: `OPEN`
- Current Operational Baseline: `Conceito promovido para implementavel. Godot project nao inicializado. Supabase project nao configurado. Design do primeiro slice completo.`

---

## Baseline De Conceito (Herdado De `_conceitos/mobile-universe/`)

Decisoes de design completas para o primeiro slice:

- Personagem: Draxos, sem classes, varinha magica, 0-3 spells, 1 passiva, 1 pet
- Combate: 7 tipos de dano, DoTs, resistencias, barreiras, status effects, anti-stall
- Base Manager: 6 estruturas, fila de construcao, Energia como recurso escasso
- Economia: XP cubico (Tibia-inspired), cotas diarias, 4 recursos, Diamante premium
- Social: amigos, guilda com construcoes e bonus passivos, chat de guilda + direct
- Infraestrutura: Godot 4.x, Supabase, batalha 100% servidor, 3 plataformas
- Season: 4 meses, 2 Battle Passes

Documentos de design em:
- `docs/game-design-document.md` (referencia condensada)
- `../../Projetos/_conceitos/mobile-universe/gdd.md` (GDD completo)
- `../../Projetos/_conceitos/mobile-universe/pendencias.md` (decisoes abertas)

---

## Active Goal

Executar Track 00: inicializar Godot project, configurar Supabase, estabelecer conexao cliente-servidor, implementar conta guest e loop minimo de batalha simulada.

---

## Read Next

- `../AGENTS.md`
- `../../canon/canon-brief.md`
- `docs/product-brief.md`
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
