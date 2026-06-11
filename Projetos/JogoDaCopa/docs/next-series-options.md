# JogoDaCopa - Opcoes da Proxima Serie (esboco para decisao)

- Date: `2026-06-11` (recriado apos perda de untracked em fechamento de thread; conteudo original preservado)
- Author: Claude (para a sessao de decisao com Fabio, apos o playtest de confirmacao)
- Baseline assumida: Track 03L (arena selada + facing) fechada e aprovada; jogo estavel sem divida tecnica relevante.

## Porta A - Modo Copa (profundidade de produto)

O nome do projeto vira verdade: torneio eliminatorio de 8 selecoes (quartas -> semi -> final), bots com kits/dificuldade crescentes por fase, tela de chaveamento entre partidas, final com celebracao especial e tela de campeao. Persistencia simples da campanha (save JSON do bracket).

- Escopo: `04A` regras/estado do torneio puros (bracket, avanco, seeds - estilo match_rules, testavel) -> `04B` UI de chaveamento + fluxo entre partidas (REGIME DE UI completo) -> `04C` curva de dificuldade por fase, identidade dos adversarios, final/campeao + save/load.
- Custo: 3 tracks medias.
- Destrava: jogo com comeco-meio-fim; 1x1 vira modo treino; base para tudo que vier depois.
- Riscos: 04B e UI nova (regime novo mitiga); save/load e superficie nova (JSON minimo).

## Porta B - Conteudo (variedade)

Segunda arena com identidade propria (builder parametrizado facilita), mais kits, mutators opcionais (bola rapida, gravidade baixa, partida relampago) como toggles isolados.

- Escopo: `04A` Arena 2 -> `04B` kits + selecao -> `04C` mutators com testes de isolamento (default OFF).
- Custo: 2-3 tracks leves.
- Destrava: rejogabilidade, material para screenshots/trailer.
- Riscos: porta menos transformadora; conteudo sem um modo que o organize pode virar enfeite.

## Porta C - Distribuicao (feedback externo)

Build baixavel nas maos de 3-5 pessoas reais. Export release polido, settings de qualidade/resolucao, hints de primeira partida, pagina itch.io (Codex prepara artefatos; Fabio cria conta/pagina), roteiro de perguntas para testers.

- Escopo: `04A` release readiness (export, settings, onboarding, smoke em maquina limpa) -> `04B` kit de pagina (capsules, texto, changelog) + checklist de publicacao.
- Custo: 2 tracks leves + tempo social de Fabio.
- Destrava: o unico dado que nem Claude nem Codex fornecem - reacao de gente de fora; define a proxima serie de gameplay com autoridade.
- Riscos: expoe cedo (mitigavel: pagina privada/link direto).

## Porta D - Encerrar o foco (portfolio)

Fechar num marco redondo e devolver o foco ao Draxos roguelike (P0 historico, pausado desde 2026-06-10). Track unica: export final, baseline marcada, docs consolidados, retro (as Quality Gates servem para todos os projetos), Estado_Atual/Prioridades com a retomada do Draxos.

- Custo: 1 track curta.
- Destrava: o Draxos (Design Lab esperando) e disciplina de portfolio.
- Riscos: momentum (mitigavel com a Porta C curta antes).

## Combinacoes que se pagam

- **C -> D**: 2 tracks leves publicam o jogo; foco volta ao Draxos enquanto feedback externo chega sozinho.
- **A -> C**: a Copa da arco completo ANTES de mostrar - primeira impressao mais forte, custo maior antes do primeiro dado externo.

## Leitura do Claude (opiniao, nao decisao)

Pelo criterio "aprendizado por hora investida": **C -> D**. Pelo criterio "o jogo que voce imaginou": **A** - e modo Copa (regras puras + curva de dificuldade) e o tipo de trabalho em que o pipeline com o Codex brilha. A unica porta que eu nao escolheria isolada e a B: conteudo rende mais quando a Copa ou o feedback externo disserem qual conteudo importa.
