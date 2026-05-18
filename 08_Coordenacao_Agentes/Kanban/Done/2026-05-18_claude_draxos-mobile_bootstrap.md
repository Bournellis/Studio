# Kanban — Done

- Data de conclusao: `2026-05-18`
- Agente: `claude`
- Projeto: `draxos-mobile`
- Slug: `bootstrap`

---

## Tarefa

Promover `Projetos/_conceitos/mobile-universe/` de conceito para projeto implementavel como `Projetos/draxos-mobile/`.

---

## O Que Foi Feito

### Scaffold do projeto

Criado `Projetos/draxos-mobile/` com a estrutura completa de projeto oficial do estudio:

- `AGENTS.md` — governanca de agentes: read order (substancial vs delimitado), canon rule, Godot rule, backend rule, platform rule, security rule
- `README.md` — visao geral, current shape, directory map, start here
- `docs/product-brief.md` — plataformas, escopo do primeiro slice (tabela), decisoes tecnicas principais, referencias de design
- `docs/game-design-document.md` — GDD condensado de implementacao: personagem, spells, base manager, economia, autobattler, social, matchmaking
- `docs/architecture.md` — stack, exports por plataforma, arquitetura de conta (fluxo), arquitetura de batalha (diagrama client-server), dados autoritativos, matchmaking, ranking, politica offline, anti-cheat por vetor, estrutura de pastas, schema Supabase inicial
- `implementation/current-status.md` — baseline herdado do conceito, goal ativo, read next, validacao (pendente), proximos passos
- `implementation/tracks/track-00-first-slice-foundation/current-status.md` — objetivo do track, 7 passos sequenciais, nota sobre prompts a definir
- Pastas de modulo com README: `server/`, `core/`, `data/`, `ui/`, `modes/`, `social/`, `tools/`, `tests/`

### Atualizacao dos documentos de estado do estudio

- `Projetos/README.md` — draxos-mobile adicionado como `P2_IMPLEMENTACAO`; mobile-universe atualizado para `ARQUIVO_DESIGN`
- `08_Coordenacao_Agentes/Estado_Atual.md` — entrada DraxosMobile adicionada com status, local, baseline e proximo passo

### Preservacao do conceito

- `Projetos/_conceitos/mobile-universe/` preservado como arquivo de design (gdd.md + pendencias.md)
- Todos os documentos do projeto novo referenciam o GDD completo explicitamente

---

## Correcoes Documentais Subsequentes (2026-05-18)

Identificadas e corrigidas inconsistencias nos documentos de nivel de estudio:

- `08_Coordenacao_Agentes/Prioridades_Estudio.md` — draxos-mobile adicionado como P2; mobile-universe atualizado para ARQUIVO_DESIGN; status P2_IMPLEMENTACAO e ARQUIVO_DESIGN adicionados ao glossario; regra de agentes atualizada
- `AGENTS.md` (raiz) — draxos-mobile adicionado em Workspace Roles, Portfolio Gate, Project Selection Gate e Godot Rule; termos de disambiguacao mobile adicionados; mobile-universe marcado como arquivo de design
- `Projetos/_conceitos/mobile-universe/gdd.md` — status atualizado de P1_CONCEITO para ARQUIVO_DESIGN
- `Projetos/_conceitos/mobile-universe/pendencias.md` — status atualizado de P1_CONCEITO para ARQUIVO_DESIGN; P13 marcado como RESOLVIDO

---

## Estado Final

- `Projetos/draxos-mobile/`: projeto ativo P2, documentado, estruturado, pronto para Track 00
- Todos os documentos de coordenacao do estudio coerentes com o novo estado
- Conceito original preservado e acessivel como referencia
