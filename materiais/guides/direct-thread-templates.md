# Direct Thread Templates

Templates diretos para abrir threads em `D:\Estudio`.

## Regra Global

Toda thread deve declarar:

- `Projeto`
- `Tipo`
- `Objetivo`
- `Rota`
- `Escopo`
- `Regra`
- `Validacao`

Comece por `D:\Estudio\AGENTS.md`, `D:\Estudio\Projetos\README.md` e a secao relevante de `D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md`.

## Implementacao Em RPG Isometrico

```text
Projeto: rpg-isometrico
Tipo: Implementation
Objetivo: executar {TASK_OR_GATE_SLICE}.
Rota: Fast Lane se seguro; use Deep Route se tocar canon, gate, arquitetura ou plataforma.
Escopo:
- D:\Estudio\Projetos\rpg-isometrico\{pasta}
Regra:
- sem canon changes sem avisar
- nao consultar fases historicas salvo necessidade explicita
Validacao:
- rode ou preserve D:\Estudio\Projetos\rpg-isometrico\tools\validate.gd + GUT conforme risco

Leia e siga:
- D:\Estudio\AGENTS.md
- D:\Estudio\Projetos\README.md
- D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md
- D:\Estudio\Projetos\rpg-isometrico\AGENTS.md
- D:\Estudio\Projetos\rpg-isometrico\implementation\current-status.md
- track ativa e gate ativo somente se o status nomear um
```

## Implementacao Em RPG Turnos

```text
Projeto: rpg-turnos
Tipo: Implementation
Objetivo: executar {TASK_OR_CONTENT_SLICE}.
Rota: Fast Lane se seguro; use Deep Route se tocar lore ampla, arquitetura ou progressao.
Escopo:
- D:\Estudio\Projetos\rpg-turnos\{pasta}
Regra:
- nao importar mecanicas do RPG Isometrico sem doc local adotando
- sem canon changes sem avisar
Validacao:
- rode ou preserve D:\Estudio\Projetos\rpg-turnos\tools\validate.gd conforme risco

Leia e siga:
- D:\Estudio\AGENTS.md
- D:\Estudio\Projetos\README.md
- D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md
- D:\Estudio\Projetos\rpg-turnos\AGENTS.md
- D:\Estudio\Projetos\rpg-turnos\implementation\current-status.md
- track ativa e arquivos tocados
```

## Review

```text
Projeto: {rpg-isometrico | rpg-turnos}
Tipo: Review
Objetivo: revisar {tema/arquivos} procurando regressao, risco e testes faltantes.
Rota: Fast Lane.
Escopo:
- D:\Estudio\Projetos\{projeto}\{pasta}
Regra:
- nao implemente ainda
- reporte findings primeiro
Validacao:
- leitura e analise; nao rode runtime salvo necessidade clara
```

## Canon / Estudio

```text
Projeto: estudio
Tipo: Canon
Objetivo: decidir ou atualizar {regra compartilhada}.
Rota: Deep Route conforme D:\Estudio\AGENTS.md.
Escopo:
- D:\Estudio\canon\
- D:\Estudio\08_Coordenacao_Agentes\
- projetos afetados explicitamente
Regra:
- canon compartilhado vence historico
- atualize snapshots operacionais afetados
Validacao:
- auditoria por rg e revisao de consistencia documental
```

## Historical

```text
Projeto: {rpg-isometrico | rpg-turnos | estudio}
Tipo: Historical
Objetivo: consultar {tema historico}.
Rota: Fast Lane + caminhos historicos explicitos.
Escopo:
- D:\Estudio\migration\
- outros caminhos historicos necessarios
Regra:
- nao tratar historico como canon atual
- nao alterar runtime a partir de registro historico
Validacao:
- resumo com fontes consultadas
```

## Auditoria Operacional

```text
Projeto: estudio
Tipo: Operational audit
Objetivo: revisar skills, AGENTS.md, CLAUDE.md, guias e status para evitar leitura excessiva e contradicoes entre projetos.
Rota: Deep Route documental.
Escopo:
- D:\Estudio\AGENTS.md
- D:\Estudio\CLAUDE.md
- D:\Estudio\Projetos\README.md
- D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md
- C:\Users\Fabio\.codex\skills\
Regra:
- nao tocar runtime Godot
- preservar fronteiras entre projetos
Validacao:
- quick_validate.py nas skills afetadas
- rg para referencias antigas ou contraditorias
```
