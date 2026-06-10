# Decisao: Cenas Geradas Por Script, .tscn Nunca Editado A Mao (registro retroativo)

## Metadata

- data: `2026-05-02` (convencao desde o bootstrap; registrado retroativamente em 2026-06-10)
- decisor: `Shared`
- projeto: `estudio`
- prioridade_portfolio: `-`

## Contexto

Edicao manual de `.tscn` por LLMs gera diffs ilegiveis, conflitos de merge e cenas quebradas silenciosamente.

## Decision

Cenas sao geradas por ferramentas (`tools/bootstrap_scene_generator.gd`, `scene_generator.gd` e equivalentes) e validadas por `validate.gd`. Nao editar `.tscn` gerado como texto, salvo pedido explicito do usuario quando for mais seguro que o caminho de editor/tool.

## Alternatives Considered

- Editar `.tscn` direto: rejeitado; fonte recorrente de regressao com agentes.
- Cenas montadas so em runtime sem arquivo: parcialmente usado (primitivas runtime), mas cenas raiz precisam existir para o editor.

## Impact

Diffs de cena viram diffs de GDScript revisaveis; agentes regeneram em vez de remendar.

## Review When

Se algum projeto passar a depender de cenas autorais complexas feitas no editor.
