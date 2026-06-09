# Thread Cheat Sheet

> Historical cheat sheet. For current project priorities and prompt shapes, use `thread-cheat-sheet-current.md`. Paused projects listed here are historical unless `08_Coordenacao_Agentes/Prioridades_Estudio.md` says otherwise.

Versao curta para abrir threads em `D:\Estudio`.

## Starter Padrao

```text
Projeto: {rpg-isometrico | rpg-turnos | estudio}
Tipo: {Quick | Implementation | Review | Planning | Gate | Canon | Historical}
Objetivo: {uma frase}
Rota: {Fast Lane | Deep Route}
Escopo: {arquivos/pastas ou "a definir pela rota"}
Regra: {sem canon changes | pode atualizar docs | review only}
Validacao: {validate.gd/GUT conforme risco | docs only}
```

## Quick

Use para bugfix pequeno ou ajuste local.

```text
Projeto: rpg-turnos
Tipo: Quick
Objetivo: corrigir {bug curto}
Rota: Fast Lane; sem mudancas de canon
Escopo: Projetos/rpg-turnos/{pasta}
Validacao: docs only ou validate.gd conforme risco
```

## Review

Use quando quiser analise de risco sem implementacao.

```text
Projeto: rpg-isometrico
Tipo: Review
Objetivo: revisar {arquivos/tema}
Rota: Fast Lane
Regra: nao implemente nada ainda
```

## Implementation

Use para feature ou fix local.

```text
Projeto: {rpg-isometrico | rpg-turnos}
Tipo: Implementation
Objetivo: implementar {feature/fix}
Rota: Fast Lane se seguro; sem canon change sem avisar
Escopo: Projetos/{projeto}/{pasta}
Validacao: validate.gd/GUT conforme risco
```

## Planning Ou Gate

Use para planejar proxima fatia de trabalho, track ou gate.

```text
Projeto: {rpg-isometrico | rpg-turnos}
Tipo: Planning
Objetivo: planejar {gate/slice/proxima etapa}
Rota: Deep Route do projeto + status da track ativa
Regra: atualizar docs operacionais se o estado mudar
```

## Canon

Use para produto, arquitetura, plataforma, progressao ou lore compartilhada.

```text
Projeto: estudio
Tipo: Canon
Objetivo: atualizar/decidir {regra compartilhada}
Rota: Deep Route conforme AGENTS.md
Regra: pode atualizar canon e snapshots afetados
```

## Historical

Use para pesquisar historico sem tratar como verdade atual.

```text
Projeto: {rpg-isometrico | rpg-turnos | estudio}
Tipo: Historical
Objetivo: consultar {tema historico}
Rota: Fast Lane + caminhos historicos explicitos
Regra: nao tratar historico como canon atual
```

## Regras Rapidas

- Escolha o projeto antes de ler fundo.
- Use `Estado_Atual.md` como snapshot do estudio.
- Use `implementation/current-status.md` como snapshot do projeto.
- Nao misture mecanicas entre projetos sem adocao local explicita.
- Se a pergunta muda de projeto ou de natureza, abra uma nova thread.
