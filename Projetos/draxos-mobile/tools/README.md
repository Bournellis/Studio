# tools/

Ferramentas de desenvolvimento e validacao.

- `validate.gd` - validacao headless do projeto Godot, gerando conteudo, checando contrato client e rodando GUT.
- `content_generator.gd` - gera `data/generated/draxos_mobile_catalog.tres` a partir de `data/definitions/*.json`.
- `create_boot_scene.gd` - gera a cena boot minima via API do Godot.
- `economy_simulator/` - fonte JSON e gerador Deno/TypeScript para a planilha de economia de seasons.

Validacao local:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
```

Simulador de economia:

```powershell
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/economy_simulator/generate.ts
```
