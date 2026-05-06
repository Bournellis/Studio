# Codex Workflow Guide

Este guia explica como abrir e conduzir threads do Codex em `D:\Estudio` sem ler contexto demais. O workspace agora e multi-projeto: escolha o projeto antes de seguir docs profundas.

## Modelo Central

- `AGENTS.md` na raiz governa o workspace.
- `Projetos/README.md` e o registro leve de projetos.
- `08_Coordenacao_Agentes/Estado_Atual.md` e o snapshot vivo do estudio.
- `canon/` e a fonte compartilhada de produto, arquitetura, plataforma, progressao e lore.
- Cada projeto oficial em `Projetos/` precisa ter `AGENTS.md` e `implementation/current-status.md`.

Projetos ativos:

- `Projetos/rpg-isometrico/`: RPG de acao isometrico campaign-first.
- `Projetos/rpg-turnos/`: RPG-cardgame por turnos, independente em mecanicas, com lore compartilhada quando adotada.

## Entrada Padrao

Use esta ordem para quase toda thread:

1. `D:\Estudio\AGENTS.md`
2. `D:\Estudio\Projetos\README.md`
3. secao relevante de `D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md`
4. `AGENTS.md` do projeto alvo, se houver projeto alvo
5. `implementation/current-status.md` do projeto alvo
6. track ativa e arquivos tocados

Nao abra docs de outro projeto para uma tarefa local, salvo quando a pergunta pedir comparacao ou reuso explicito.

## Quando Usar Fast Lane

Use Fast Lane quando:

- a tarefa e local a um projeto ou area;
- nao muda canon;
- nao decide arquitetura, plataforma, produto ou progressao compartilhada;
- os arquivos tocados sao previsiveis.

Prompt base:

```text
Projeto: {rpg-isometrico | rpg-turnos | estudio}
Tipo: {Quick | Implementation | Review}
Objetivo: {uma frase}
Rota: Fast Lane se seguro; sem mudancas de canon
Escopo: {arquivos ou pastas}
Validacao: {validate.gd/GUT conforme risco | docs only}
```

## Quando Usar Deep Route

Use Deep Route quando:

- a tarefa afeta mais de um projeto;
- muda canon, arquitetura, plataforma, produto, progressao ou lore compartilhada;
- define track, gate, roadmap ou padrao futuro;
- depende de contexto historico amplo.

Prompt base:

```text
Projeto: {estudio | projeto alvo}
Tipo: {Canon | Architecture | Gate | Planning | Historical}
Objetivo: {decisao ou investigacao}
Rota: Deep Route conforme AGENTS.md
Regra: pode atualizar docs operacionais; canon apenas se necessario e explicito
```

## Exemplos Por Projeto

### RPG Isometrico

```text
Projeto: rpg-isometrico
Tipo: Implementation
Objetivo: corrigir {bug} na superficie ativa.
Rota: Fast Lane se seguro; sem canon changes.
Escopo: Projetos/rpg-isometrico/{pasta}
Validacao: preserve ou rode tools/validate.gd + GUT conforme risco.
```

### RPG Turnos

```text
Projeto: rpg-turnos
Tipo: Implementation
Objetivo: implementar {feature/fix} no cardgame.
Rota: Fast Lane se seguro; nao importar mecanicas do isometrico.
Escopo: Projetos/rpg-turnos/{pasta}
Validacao: preserve ou rode tools/validate.gd conforme risco.
```

### Estudio / Canon

```text
Projeto: estudio
Tipo: Canon
Objetivo: decidir {regra compartilhada}.
Rota: Deep Route conforme AGENTS.md.
Regra: atualizar canon e snapshots operacionais afetados.
```

## Thread Hygiene

Mantenha a mesma thread quando:

- e a mesma tarefa delimitada;
- os mesmos arquivos seguem em jogo;
- voce esta corrigindo falha da validacao da mudanca atual.

Abra nova thread quando:

- mudar de projeto;
- mudar de implementation para review/planning/canon;
- a thread ficou misturada com assuntos sem relacao;
- a pergunta for historica e nao deve poluir uma tarefa ativa.

## Como Manter Baixo O Custo De Contexto

- Diga o projeto alvo no inicio.
- Diga `Fast Lane` quando a tarefa for local.
- Diga `sem canon changes` quando for implementacao.
- Aponte arquivos ou pastas quando souber.
- Use `historical` e caminhos explicitos quando quiser historia.
- Nao peça analise do workspace inteiro se a tarefa cabe em um projeto.

## Sidecar Agents

Claude ou outro agente deve ser consultivo e delimitado:

- entregue projeto, tipo, objetivo e escopo;
- mantenha decisoes de canon, status operacional e validacao centralizadas;
- integre conclusoes aceitas de volta nos arquivos do workspace.

## Atualizacao De Estado

Atualize `Estado_Atual.md` ou `implementation/current-status.md` somente quando mudar status observavel, track ativa, baseline ou proximo passo. Detalhes longos devem ir para Kanban Done, Handoffs, Decisoes ou registros de track.
