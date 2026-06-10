# Avaliacao Externa Do Estudio - 2026-06-10

- Autor: Claude (Fable 5), a pedido de Fabio
- Escopo: estrutura do estudio, formato de trabalho, operacao com agentes e implementacoes tecnicas
- Metodo: leitura dos docs de coordenacao, canon, AGENTS locais, kanban/handoffs, e amostragem de codigo em todos os projetos
- Status: avaliacao pontual; nao e canon nem documento operacional

## Resumo Executivo

O estudio e um caso raro de operacao multiagente bem pensada por um solo dev. O volume entregue desde 2026-05-02 (899 commits em ~5,5 semanas, ~107k linhas de GDScript proprio, ~23k de TypeScript server-side, ~21k de SQL, 6 projetos Godot, backend Supabase publicado em Internal Alpha) com qualidade de processo acima de muitos times profissionais.

A doenca sistemica do estudio e uma so: **estado duplicado em prosa que so cresce**. O mesmo snapshot de portfolio vive em 6+ arquivos, baselines viram paragrafos de 300+ palavras listando todo pacote historico, e o drift ja e visivel hoje. Isso e assinatura de docs escritos por modelos antigos com contexto curto: repetir tudo em todo lugar era defesa; hoje e custo e risco.

Nota por area:

| Area | Nota | Comentario |
|---|---|---|
| Backup/risco de perda | CRITICO | Sem git remote: 899 commits existem so neste disco |
| Operacao com agentes | Otima | Worktrees, gates, hard stops, templates - referencia |
| Qualidade tecnica do codigo | Boa/Otima | Tipado, em camadas, server-authoritative, labs |
| Validacao e release safety | Otima | validate.gd por projeto, perfis, ConfirmRemoteMutation |
| Documentacao (conteudo) | Boa | Contratos e planos de track sao excelentes |
| Documentacao (estrutura) | Fraca | Duplicacao massiva, drift ativo, snapshots inchados |
| Testes | Mediana | Cobertura estreita e arquivos de teste monoliticos |

## O Que Esta Muito Bom

### 1. Operacao multiagente

O conjunto Portfolio Gate -> Project Selection Gate -> read order, com taxonomia de status (`P0_IMPLEMENTACAO`...`ARQUIVO_DESIGN`), worktrees dedicados fora da arvore principal, branches nomeadas, registro em Kanban/Doing antes de editar e commit por estagio logico e exatamente o que times multiagente maduros fazem. As branches reais (`codex/jogodacopa/...`) confirmam que a regra e seguida, nao so escrita.

O card de backlog do Track 02 do JogoDaCopa e um exemplo de especificacao excelente: goal, escopo por sub-track, out of scope, expected files, criterios de aceite verificaveis e plano de handoff. Se todo trabalho futuro mantiver esse padrao de card, a metade do AGENTS.md raiz fica redundante.

Os Hard Stops do DraxosMobile (secrets nunca no cliente, `-ConfirmRemoteMutation` para mutacao remota, escopo bloqueado ate decisao explicita, `.tscn` nunca editado como texto) sao o melhor guardrail do workspace.

### 2. Cultura de validacao

Todo projeto tem `tools/validate.gd` com perfis; o validador do JogoDaCopa checa ate a presenca dos docs obrigatorios. DraxosMobile tem matriz de validacao, smoke de layout responsivo como gate de publicacao e release ops com evidencia de deploy. O espelho `server/` vs `supabase/functions` esta byte-identico hoje (verificado por diff).

### 3. Tooling de simulacao do roguelike

AutoRun Gate Pack, Scenario Fixtures, Battle Lab, Card Impact V1-V5 com assinaturas causais por carta, Design Lab com promotion manifest e golden metrics: isso e infraestrutura de balanceamento de nivel industrial. O fluxo before/change/after/compare para redesign de cartas em lotes pequenos e a coisa mais sofisticada do estudio.

### 4. Arquitetura tecnica

- Camadas consistentes entre projetos (Foundation/Gameplay/Presentation/Composition/Online; padrao de modos com bootstrap/session/loop/HUD/results).
- DraxosMobile server-authoritative de verdade: edge functions tipadas com api versioning, idempotencia, mutacao transacional, auth context e 44 migrations - o cliente nunca simula resultado.
- Cenas geradas por script em vez de `.tscn` editado a mao: decisao perfeita para trabalho com LLMs (diffs legiveis, sem merge hell de cena).
- GDScript tipado, nomes claros, constantes de tuning centralizadas com guia de tuning.

### 5. Capacidade de aprender sobre a propria operacao

`07_Aprendizados/` (drift documental, compactacao de snapshot, higiene de worktree) mostra que o estudio ja diagnosticou seus proprios problemas. O diagnostico esta certo; falta atacar a causa em vez do sintoma.

## O Que Precisa Melhorar

### P0-1. Sem backup remoto (risco existencial)

`git remote -v` esta vazio. Todo o estudio - 899 commits, todos os projetos - existe somente em `D:\`. Um defeito de disco apaga 2 meses de trabalho. Nada abaixo importa comparado a isso.

### P0-2. Estado duplicado + drift ativo

O snapshot de portfolio vive simultaneamente em: `AGENTS.md` raiz, `CLAUDE.md`, `README.md` raiz, `canon/canon-brief.md`, `Prioridades_Estudio.md`, `Estado_Atual.md`, `Projetos/README.md`, `Painel_Visual_Estudio.html`, alem dos AGENTS/manuais locais. Drift ja presente hoje:

- `README.md` raiz: roguelike como "active P0" e DraxosMobile em `BOSQUE_DIEGETIC_LAUNCHER...` (2 pacotes atras).
- `CLAUDE.md`: DraxosMobile com "Track ativa: Track 00" e nenhuma mencao a JogoDaCopa/FpsPlayground - um agente Claude entrando hoje recebe um mapa errado do estudio logo na primeira leitura.
- `canon/canon-brief.md`: mapa de projetos sem JogoDaCopa/FpsPlayground, roguelike "P0", pacote "atual" do mobile defasado, URLs e version codes embutidos num doc que se diz estavel.

A regra dos proprios docs ("ao concluir tarefa, atualize Prioridades + Estado_Atual + Projetos/README") institucionaliza a triplicacao: todo update precisa acertar 3+ arquivos para sempre.

### P0-3. Snapshots inchados que violam a propria regra de tamanho

`Estado_Atual.md` manda ser "compacto e orientado a decisao", mas a entrada do DraxosMobile carrega ~300 palavras de baseline com a cadeia completa de 12+ pacotes historicos e URLs de preview. O AGENTS.md do DraxosMobile repete a mesma litania ("remains the previous" aparece 30 vezes). `Projetos/README.md` tem bullets de ~300 palavras. Custo: todo agente paga esses tokens em toda sessao, e cada copia e mais uma superficie de drift. Historico de pacotes pertence a UM arquivo de historico por projeto, nao ao snapshot.

### P1-4. Roteamento por listas de keywords no AGENTS.md raiz

A linha de roteamento do DraxosMobile enumera ~80 termos/markers historicos. Isso era muleta para modelos fracos em desambiguar; modelos atuais resolvem com uma regra curta ("citou mobile/PVP/Supabase -> draxos-mobile") + a tabela de portfolio. A lista exige manutencao infinita e ja contem markers obsoletos.

### P1-5. Testes estreitos e monoliticos

- JogoDaCopa: 3 arquivos de teste para 4.3k linhas - pouco para um Track 02 de 7 sub-tracks (os criterios de aceite pedem validate verde por track, bom, mas a malha e fina).
- DraxosMobile: `test_boot_mobile_ui.gd` com 3.649 linhas e o pior padrao para agentes: caro de ler, facil de quebrar, dificil de editar com precisao. Testes monoliticos custam mais tokens do que o codigo que cobrem.
- `battle_engine.gd` com 2.965 linhas/230 funcs funciona porque os labs seguram a regressao, mas e um god-object; os directors extraidos mostram o caminho certo.

### P1-6. Residuos e higiene

- `Projetos/FpsShooter/` e uma casca morta pos-split (0 arquivos rastreados, caches `.godot`, dirs vazios) - apagar.
- Nomes legados de FPS dentro do projeto de futebol: `fps_player_controller.gd`, `fps_feedback_controller.gd` (referenciados ate no validate.gd). Renomear no Track 02.
- Mudancas nao commitadas na arvore principal (Estado_Atual, docs do JogoDaCopa, card de backlog) - a propria regra do estudio diz que a arvore principal nao e worktree de implementacao.

### P1-7. Decisoes sub-registradas

2 arquivos em `Decisoes/` contra 264 cards Done e 40 handoffs. Decisoes de produto/arquitetura estao enterradas em handoffs e baselines, onde drift as apaga. O template existe; falta o habito de 5 linhas por decisao.

### P2-8. Canon com identidade confusa

`canon/` descreve majoritariamente o RPG Isometrico (pausado indefinidamente), enquanto os projetos ativos (JogoDaCopa, FpsPlayground) vivem fora do canon e o canon-brief carrega estado operacional volatil. Canon deveria ser so o que e estavel (lore, arquitetura compartilhada, mode standard); estado operacional nunca deveria entrar la.

### P2-9. Docs versionados como arquivos paralelos

`battle-drama-v1-1.md`, `first-session-clarity-v1.md`, etc. (55 docs no mobile): sufixo de versao no nome do arquivo gera documentos "vivos" paralelos. O documentation-index mitiga, mas o padrao acumula. Doc vivo + changelog interno escala melhor.

## Recomendacoes Priorizadas

### Agora (1-2 horas, antes de voltar ao JogoDaCopa)

1. **Criar remote privado (GitHub/GitLab) e push de `main` + branches.** Maior retorno por minuto investido em toda esta avaliacao.
2. Commitar ou descartar as mudancas pendentes na arvore principal; apagar `Projetos/FpsShooter/`.

### Curto prazo (proxima janela de manutencao, ~1 dia)

3. **Eleger fonte unica de estado**: `Prioridades_Estudio.md` (tabela) + `Estado_Atual.md` (max ~12 linhas por projeto). Todos os outros arquivos (README raiz, CLAUDE.md, canon-brief, AGENTS raiz) passam a apontar, nunca copiar - zero markers, zero URLs, zero "proximo passo" fora da fonte unica.
4. Mover a cadeia historica de pacotes do DraxosMobile para `draxos-mobile/docs/release-history.md` (tabela: pacote, data, release root, preview). Snapshots citam so o pacote atual + link.
5. **Automatizar o anti-drift**: um script (`tools/check_doc_drift.ps1` no padrao dos check_* existentes) que falha se encontrar markers de pacote/URLs/"latest" fora dos arquivos permitidos. Rodar no validate. O aprendizado de 2026-06-09 ja descreve isso manualmente; automatizar e o passo que falta.
6. Substituir as listas de keywords do AGENTS.md raiz por regras curtas de roteamento + ponteiro para a tabela de portfolio.
7. Fundir `draxos-mobile/AGENTS.md` e `docs/agent-operating-manual.md` num arquivo so (hoje se sobrepoem e divergem).

### Medio prazo

8. Registrar 1 decisao em `Decisoes/` por escolha de produto/arquitetura (5-10 linhas). Retroativamente, so as ~10 maiores.
9. Quebrar `test_boot_mobile_ui.gd` por tela/fluxo; estabelecer teto (~400 linhas) por arquivo de teste novo.
10. No JogoDaCopa Track 02: renomear `fps_*` -> `football_*`/`shared_*` e ampliar a malha de testes junto com cada sub-track (o card ja pede GUT atualizado - manter).
11. Gerar `Painel_Visual_Estudio.html` (e o trecho operacional do canon-brief) a partir de `Estado_Atual.md` por script, em vez de manter a mao.
12. Consolidar docs `*-v1/v1.1` do mobile em docs vivos com changelog; manter cadencia mensal de "GC documental" registrada em `07_Aprendizados/`.

## Sobre Trabalhar Com Modelos Atuais

O scaffolding pesado (read orders de 12 passos, keywords enumeradas, avisos repetidos em todo arquivo, baselines re-narradas) compensava limitacoes de modelos antigos: contexto curto, roteamento fraco, tendencia a esquecer regras. Modelos atuais seguem melhor poucas regras claras com uma fonte de estado precisa do que muitas regras redundantes com copias divergentes - redundancia hoje *piora* o comportamento, porque o agente le duas versoes e escolhe a errada.

Vale manter como esta: hard stops, worktrees, gates de validacao, cards de track detalhados, labs. Vale enxugar: tudo que e copia de estado, listas enumerativas e historia em prosa dentro de snapshots. A regra pratica: **estado vive em 1 lugar, historia vive em arquivos de historia, e todo o resto e ponteiro.**

## Numeros De Referencia (2026-06-10)

- Commits: 899 (desde 2026-05-02, sem remote)
- GDScript proprio (sem addons): JogoDaCopa 4.3k, FpsPlayground 3.8k, draxos-mobile 44.7k, roguelike 27.5k, rpg-isometrico 17.7k, rpg-turnos 8.8k
- Backend: 22.8k linhas TS (espelhadas em `server/` e `supabase/`, em sincronia), 44 migrations (~20.9k linhas SQL)
- Markdown: 781 arquivos, ~69.8k linhas
- Kanban: 264 Done, 1 Backlog, 0 Doing | Handoffs: 40 | Decisoes: 2
- Testes (arquivos): mobile 15, roguelike 14, isometrico 22, turnos 13, JogoDaCopa 3, FpsPlayground 2
