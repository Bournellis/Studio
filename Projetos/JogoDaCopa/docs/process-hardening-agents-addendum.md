# Process Hardening - Adendo para o AGENTS.md local (aplicado)

- Date: `2026-06-11` (recriado apos perda de untracked em fechamento de thread; conteudo original + secao Gameplay Evidence)
- Author: Claude (consolidando as licoes operacionais da sessao de 2026-06-10/11); politica de rede revisada por decisao de Fabio em 2026-06-11.
- Aplicacao: o texto da secao abaixo foi inserido no `Projetos/JogoDaCopa/AGENTS.md` (apos a secao "Validation") pela Track 03J, junto com o registro da decisao vigente de git local vs rede.

## Origem das regras (contexto, nao entra no AGENTS)

Nascidas de falhas reais: 2 quebras consecutivas de UI invisiveis a testes de presenca (02E, 03G); rig decorativo aprovado por teste estrutural (02C); fallback silencioso escondendo o avatar do bot (02C-bis); pose do avatar corrompida por manipulacao manual de keyframes (03H); 5 incidentes de truncamento de worktree pos-fechamento de thread, um deles levando `.git/config` e index; perda de docs untracked em fechamento (suspeita de git clean indevido).

---

## TEXTO APLICADO NO AGENTS.md (secao "Quality Gates")

### Quality Gates

#### Evidencia por tipo de mudanca

- **Fisica, regras, bot, sistemas**: testes GUT de comportamento sao evidencia suficiente. Review pos-merge permitido.
- **UI interativa (menu, HUD clicavel, telas)**: teste de presenca/visibilidade NAO e evidencia. Obrigatorio: (a) teste de clique real - `InputEventMouseButton` injetado via viewport nas coordenadas globais do controle, assertando o sinal disparado - cobrindo todos os controles da tela alterada, nas resolucoes 1920x1080, 1366x768 e 1280x720; (b) screenshots das 3 resolucoes em `docs/screenshots/<track>/`; (c) review pre-merge: a track para na branch e registra handoff para review de Claude + aprovacao visual de Fabio ANTES da merge.
- **Feel/tuning (forcas, velocidades, timings)**: valores em constantes nomeadas com antes->depois registrado no doc da track; a palavra final e do playtest humano, nunca do agente.

#### Gameplay Evidence Capture (combinado Fabio/Claude 2026-06-11)

- Toda track com efeito visivel em jogo (arena, avatar, animacao, VFX, HUD, camera) encerra com FASE DE EVIDENCIA: o Codex roda o jogo na maquina real (janela, nao headless) via script de captura (padrao `tools/capture_*`), simulando os inputs relevantes, e salva:
  - Screenshots padronizados em `docs/screenshots/<track>/`: menu, kickoff, SEQUENCIA de corrida (4 frames consecutivos, ~0.15s entre eles, mostrando facing e animacao), momento do chute, gol com VFX, e 4 angulos da arena (frontal do gol, lateral, alto diagonal, interior do gol) - mais capturas especificas do escopo da track.
  - Relatorio em `docs/playtest-reports/<track>.md`: o que foi executado (cena, duracao, inputs), checklist objetivo passa/falha do que da para julgar por imagem, e observacoes.
- Papeis: Codex captura e relata (nao julga estetica); Claude analisa as imagens no code review; Fabio da o veredito subjetivo final (feel, vida, beleza).
- Sequencias de frames sao obrigatorias para mudancas de animacao/movimento - frame unico nao evidencia movimento.

#### Bugfix e teste-primeiro

- Correcao de bug de playtest comeca REPRODUZINDO o bug em teste (vermelho) antes do fix, quando a natureza permitir. Se o teste passar no codigo supostamente quebrado, PARAR e registrar handoff pedindo mais dados.
- Causa raiz documentada no doc da track e obrigatoria; "corrigido" sem causa identificada nao fecha track.

#### Falha silenciosa proibida

- Todo caminho de fallback (load de asset, build de rig, recurso opcional) DEVE logar erro permanente via `push_error`/`push_warning`. Fallback que degrada visual/comportamento sem log e defeito, mesmo que o jogo rode.

#### Fechamento de thread (anti-truncamento e anti-perda)

- Ultimo ato obrigatorio de toda thread, no worktree principal pos-merge: `git status --short` + `git diff --check` + check de integridade de fontes + imprimir `WORKTREE_VERIFIED` somente apos a escrita estabilizar. NAO encerrar o processo antes dessa linha.
- `git clean` e PROIBIDO em qualquer fase. Arquivos untracked no worktree principal pertencem a Fabio/Claude: nunca deletar; docs untracked de Claude em `docs/` devem ser COMMITADOS no commit de registro da track corrente.
- Operador humano: aguardar 15-30s apos o relatorio final antes de fechar a janela/processo.
- Antes de iniciar track nova: worktree sujo ou git inoperante => PARAR e registrar handoff. Verificacao/recuperacao pos-thread e papel de Claude.
- Worktree NOVA: rodar import headless do editor (`--headless --editor --quit`) UMA VEZ antes de validar ou julgar erros de runtime. Erros `No loader found` / fallbacks de asset em worktree recem-criada sao quase sempre cache de import ausente (`.godot/` local), nao bug do jogo (licao da godot-debugger-bugs-v1, 2026-06-11).

#### Remote GitHub & Push (analise Claude/Codex 2026-06-11; decisao de Fabio)

- Remote: `origin = https://github.com/Bournellis/Studio.git` (monorepo do estudio). E o UNICO backup contra perda de disco - e o historico local ja sofreu 8 incidentes de corrupcao em 2 dias.
- **REVISADO 2026-06-11 (decisao de Fabio apos falha pratica)**: agentes NAO executam operacoes de REDE no git (`push`/`fetch`/`pull`) - o Git Credential Manager abre prompt interativo de login que trava o agente. Toda sincronizacao com origin e feita por FABIO via **GitHub Desktop** ("Fetch origin" / "Push origin").
- Divisao definitiva: **Codex/Claude = git LOCAL** (commit, merge, branch, worktree, restore); **Fabio/GitHub Desktop = REDE** (push, fetch, pull).
- Ritual de fechamento de track: apos merge em main + verificacoes, o relatorio final do Codex termina com a linha `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin` antes do `WORKTREE_VERIFIED`. Fabio pusha apos cada track (ou no minimo a cada rodada de merges). O remoto nunca fica mais de 1 rodada atras.
- Se o Desktop mostrar divergencia (pull necessario / historico diferente): NAO resolver pelo Desktop - avisar Claude para diagnostico antes de qualquer pull/rebase.
- Branches de track nao sao pushadas por padrao. Excecao: branch em review pre-merge que va pernoitar -> Fabio pusha pelo Desktop como backup.
- Demais usos do GitHub Desktop: leitura LIVRE (diff, historico). `Discard changes` equivale ao git clean PROIBIDO com agente ativo - restore cirurgico e papel de Claude.
- Sem credenciais/tokens em arquivos do repo, em prompts ou em logs.

#### Permanentes do projeto (promovidos das regras de serie)

- Paridade de bot: toda acao nova do player tem uso/resposta equivalente do bot na mesma track.
- Caminho unico de forca na bola via `FootballBall3D.kick()`; fisica base (massa/bounce/drag/limites) intocavel sem decisao explicita de Fabio (excecao registrada: `continuous_cd` autorizado na 03L).
- Contratos de input preservados (tap LMB / RMB) com testes de regressao.
- Input actions novas somente via `autoloads/app_bootstrap.gd`.
- Assets externos somente CC0 / CC-BY (atribuicao registrada) / Pixabay Content License, listados em `docs/asset-licenses.md` ANTES do uso.

---

## Mini-prompt aplicado (Track 03J)

```
Workspace: D:\Estudio. Projeto: Projetos/JogoDaCopa. Voce controla o git LOCAL (NUNCA push/fetch/pull).
Track 03J - Process & Git Policy V1 (docs-only).
1. Card em Kanban/Doing; worktree/branch padrao (track03j-process-git-policy-v1).
2. Leia docs/process-hardening-agents-addendum.md e insira a secao "Quality Gates" (texto integral, incluindo Remote GitHub & Push) no Projetos/JogoDaCopa/AGENTS.md apos a secao Validation, seguindo o protocolo de edicao de AGENTS.md.
3. Registre a decisao vigente em 08_Coordenacao_Agentes/Decisoes/2026-06-11_estudio_git_remote_github_desktop.md.
4. Commite docs untracked de Claude em Projetos/JogoDaCopa/docs/, se existirem. Atualize docs/documentation-index.md. validate PASS, merge local, card Done, prune, status limpo, PUSH PENDENTE e WORKTREE_VERIFIED.
```
