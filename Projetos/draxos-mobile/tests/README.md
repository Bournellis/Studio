# tests/

Testes client Godot com GUT 9.6.0.

Escopo:

- Client, UI, parsing de logs, content foundation e validadores GDScript.
- Nao testar simulacao autoritativa de combate aqui; essa logica vive no servidor e deve ser coberta por Deno/TypeScript em `server/tests/`.

Rodar antes de qualquer commit de implementacao client:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
```

`tools/validate.gd` tambem roda GUT via `.gutconfig.json`.
