# Current Status

- Last Updated: `2026-05-19`
- Active Project Name: `draxos-mobile`
- Active Surface: `Track 00 - First Slice Foundation`
- Active Track: `Track 00 - First Slice Foundation`
- Active Track Status: `OPEN`
- Current Operational Baseline: `Preparacao documental da Track 00 concluida: escopo, MVP tecnico minimo, contratos iniciais, pendencias de design vivas e prompts atomicos definidos. Godot project nao inicializado. Supabase project nao configurado.`

---

## Estado Atual

| Area | Estado | Observacao |
|---|---|---|
| MVP tecnico minimo | Definido | Prova Godot 4.6.2 + Supabase com guest, battle fixture e log animavel |
| Primeiro slice completo | Escopo definido | Inclui PVP autobattler, base manager, social, ranking, bots, economia, Battle Pass/Diamante |
| Design pendente | Registrado | Fonte viva: `../docs/design-pending.md` |
| Contratos tecnicos | Definidos | Fonte inicial: `../docs/contracts/` |
| Godot project | Pendente | Proxima implementacao: Track 00 P01 |
| Supabase project | Pendente | Track 00 P02 |
| Validacao | Pendente | Depende de `project.godot` e `tools/validate.gd` |

---

## Fontes Vivas

- Escopo Track 00: `tracks/track-00-first-slice-foundation/scope.md`
- MVP tecnico: `tracks/track-00-first-slice-foundation/mvp-technical-definition.md`
- Plano sequencial: `tracks/track-00-first-slice-foundation/implementation-plan.md`
- Prompts atomicos: `tracks/track-00-first-slice-foundation/implementation-prompts.md`
- Pendencias de design: `../docs/design-pending.md`
- Contratos: `../docs/contracts/`
- Design autoritativo: `../docs/game-design-document.md`
- Decision log historico: `../docs/pre-implementation-decisions.md`

---

## Decisoes De Escopo

- Track 00 monta o primeiro slice completo.
- MVP tecnico minimo e a primeira etapa da Track 00.
- MVP tecnico usa fixtures `MVP_ONLY` e nao depende de balanceamento final.
- Tudo que exigir design ou tuning entra em `../docs/design-pending.md` antes de implementar.
- iOS e mobile browser ficam fora da Track 00.

---

## Baseline De Conceito Preservada

- Personagem: Draxos, sem classes, varinha magica, 0-3 spells, 1 passiva, 1 pet, summons.
- Combate: 7 tipos de dano, DoTs, resistencias, barreiras, status effects, anti-stall.
- Base Manager: 6 estruturas permanentes e Energia como gargalo.
- Social: amigos, guilda, ajudas, chat de guilda e direct.
- Infraestrutura: Godot 4.6.2, Supabase, batalha 100% servidor, Android + PC + PC browser.
- Season: 4 meses, 2 Battle Passes, cap Season 1 = 40.

---

## Read Next

1. `../AGENTS.md`
2. `tracks/track-00-first-slice-foundation/scope.md`
3. `tracks/track-00-first-slice-foundation/mvp-technical-definition.md`
4. `../docs/design-pending.md`
5. `tracks/track-00-first-slice-foundation/implementation-prompts.md`

---

## Validation

Godot project nao existe ainda; nao ha validacao executavel do projeto.

Quando inicializado:

```powershell
D:\Estudio\.local-tools\godot\4.6.2-stable\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
```

---

## Next

Executar Track 00 P01:

1. Inicializar Godot 4.6.2 em `D:\Estudio\Projetos\draxos-mobile\`.
2. Criar cena boot minima e `tools/validate.gd`.
3. Configurar GUT 9.6.0.
4. Atualizar status antes de seguir para Supabase base.
