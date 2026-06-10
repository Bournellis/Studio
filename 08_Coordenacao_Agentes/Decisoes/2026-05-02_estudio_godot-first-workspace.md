# Decisao: Workspace Godot-First Em D:\Estudio (registro retroativo)

## Metadata

- data: `2026-05-02` (primeiro commit; registrado retroativamente em 2026-06-10)
- decisor: `Usuario`
- projeto: `estudio`
- prioridade_portfolio: `-`

## Contexto

O estudio migrou do legado Unity para Godot e precisava de uma casa unica para projetos, canon e coordenacao de agentes.

## Decision

`D:\Estudio` e o workspace unico: `canon/` compartilhado, `Projetos/` para implementacoes Godot (versao em `.godot-version`, GDScript, GUT para testes), `08_Coordenacao_Agentes/` como hub de coordenacao e `migration/` como arquivo historico do cutover. Nenhuma tarefa padrao deve exigir abrir o repositorio Unity externo.

## Alternatives Considered

- Um repositorio por projeto: rejeitado; canon e coordenacao compartilhados pesam mais que o isolamento.

## Impact

Worktrees externos (`D:\Estudio-worktrees\`) viram o mecanismo de isolamento por agente, mantendo um historico unico.

## Review When

Se algum projeto for publicado comercialmente e precisar de repo/CI proprios.
