# DraxosMobile - Product Brief

- Ultima atualizacao: `2026-05-30`
- Status: `VIVO`

---

## Leitura Atual

DraxosMobile e um jogo mobile-first de progressao persistente construido sobre tres pilares reais:

- Base builder.
- Autobattler assincrono server-authoritative.
- Social basico.

O projeto atual deve ser lido como uma base implementada para refinamento. Ele nao e produto final, nao e uma trilha de expansao de conteudo e nao e uma rodada de balanceamento.

A etapa atual e `FOUNDATION_AUDIT_ACTIVE`.

## Foco Imediato

O foco imediato e auditar o loop interno pos-login:

`Base -> coletar recursos -> evoluir base -> batalhar -> receber recompensas -> verificar base novamente`

A pergunta central da etapa e: como, onde e com quantas etapas o usuario clica para executar esse loop?

First Session Clarity v1 e o pacote publicado atual para essa pergunta: Refugio, Preparacao e Resultado agora orientam o primeiro ciclo sem novo backend, schema, tuning, economia ou conteudo.

Devem ser avaliados:

- hierarquia da primeira tela apos login;
- posicao dos icones e botoes principais;
- quantidade de etapas ate coletar, evoluir e batalhar;
- clareza do feedback de recurso, upgrade, batalha e recompensa;
- retorno para base apos a recompensa;
- estados de loading, erro, vazio e sucesso;
- qualidade da resposta visual/tecnica em Android, PC e PC browser.

## O Que Existe Como Substancia/Mock

Armas, spells, nomes, tema, imagens, apresentacao atual de batalha, economia, Battle Pass, Diamante, loja, bots, rankings e valores de progressao existem para dar substancia ao jogo e impedir que o app pareca vazio.

Esses elementos nao devem ser tratados como decisao final de design nesta etapa. Eles so viram prioridade quando a Foundation Audit e a ordem de trabalho atual promoverem o assunto.

Terminologia implementada preservada como substancia/mock: Instrumento Ritual, Spell, Doutrina e Familiar.

Ordem recomendada apos a auditoria documental:

1. Loop interno pos-login.
2. Social.
3. Visual geral.
4. Apresentacao da batalha.
5. Armas, spells, economia, balanceamento e conteudo detalhado.

## Plataformas

| Plataforma | Papel atual |
|---|---|
| Android | Produto primario e principal referencia de UX |
| PC executavel | Canal de teste, conforto e fallback |
| PC browser | Canal rapido para review e handoff |
| iOS | Futuro possivel, sem compromisso atual |
| Mobile browser | Fora do escopo ate decisao explicita |

## Base Implementada

A base tecnica ja contem:

- Godot `4.6.2-stable`;
- Supabase Auth, Postgres, Edge Functions e Storage;
- email/senha e fluxo de conta alpha;
- saves `normal` e `progression_lab`;
- batalha server-authoritative com replay/log;
- Base/Refugio, coleta, upgrades e recursos;
- social, competicao, loja e laboratorios em estado de prototipo;
- release manifest, build channel e runbooks de publicacao segura;
- validacao local por `validate_foundation.ps1`.

Track 16 e o ultimo pacote tecnico, com comportamento/crafting/pocoes. Ele esta registrado em `behavior-potion-crafting-v1.md` como base tecnica existente: Ossos inteiros, Po de Osso, Pocao de Vida, crafting inicial, slot de pocao e comportamento simples de habilidade/pocao. Ele nao e a etapa ativa de produto e nao libera tuning, economia, novas pocoes ou comportamento avancado sem novo pacote explicito.

## Decisoes Que Permanecem Reais

| Area | Decisao |
|---|---|
| Produto | Base builder + autobattler + social basico, com futuro de minigames |
| Batalha | Servidor resolve; cliente apresenta log/replay |
| Backend | Supabase como ponte de alpha; Backend Proprio + Postgres como saida preferida se crescer |
| Autoridade | Recurso, recompensa, ranking, batalha e mutacoes importantes ficam no servidor |
| Plataforma | Android primeiro; PC/PC browser para teste e review |
| Conteudo | Deve ser substituivel/versionavel sem reescrever fundacao |

## Documentos Vivos

- `foundation-app-v0-audit.md` - bussola atual da Foundation Audit.
- `first-session-clarity-v1.md` - pacote publicado de clareza da primeira sessao.
- `product-vision.md` - visao longa local.
- `game-design-document.md` - referencia de implementacao e substancia/mock existente.
- `behavior-potion-crafting-v1.md` - estado vivo de pocoes, crafting inicial e comportamento simples.
- `design-pending.md` - pendencias vivas e ordem de decisao.
- `documentation-index.md` - classificacao de docs vivos, contratos, runbooks, historico e arquivo de design.
- `contracts/` - contratos tecnicos antes de migrations/codigo.
- `internal-alpha-v0.md` - runbook operacional da build fechada.
- `../../_conceitos/mobile-universe/gdd.md` - GDD historico completo, somente contexto.
