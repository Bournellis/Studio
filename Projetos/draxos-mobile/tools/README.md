# tools/

Ferramentas de desenvolvimento e validacao.

- `validate.gd` - validacao headless do projeto Godot, gerando conteudo, checando contrato client e rodando GUT.
- `smoke_exports.gd` - smoke leve dos presets Android Alpha, PC Windows Alpha e PC Browser Alpha.
- `smoke_dev_labs.gd` - smoke do caminho real `OS.execute` para Battle Lab e Progression Lab.
- `smoke_dev_lab_ui.gd` - smoke visual/comportamental das telas dev-only; salva screenshots quando rodado sem `--headless`.
- `content_generator.gd` - gera `data/generated/draxos_mobile_catalog.tres` a partir de `data/definitions/*.json`.
- `create_boot_scene.gd` - gera a cena boot minima via API do Godot.
- `economy_simulator/` - fonte JSON e gerador Deno/TypeScript para a planilha de economia de seasons.
- `battle_lab/` - runner Deno do laboratorio de combate, usado pelo HTML/CSV/JSON e pela tela dev-only Godot.
- `progression_lab/` - modelo, gerador e seeder local para saves saudaveis 2h-20h, relatorios, bots e Progression Lab Dev.

Validacao local:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_labs.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_lab_ui.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
```

Simulador de economia:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/economy_simulator/generate.ts
```

Battle Lab:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --compare-with 2026-05-21_archetype_source_tuning_v02
```

Progression Lab:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts
npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all
```
