# Code Review - JogoDaCopa Track 06B - ESC Menu Completo V1

- Data: `2026-06-13`
- Revisor: Claude (review pre-merge de UI/visual)
- Branch: `codex/jogodacopa/track06b-esc-menu-v1` (commits `2882881b` feat, `ebc6db89` handoff)
- Base: `main` apos merge da 06A (`b585b5d2` / close `4f18f2fa`)
- Veredito: `APROVADO no code review`. Falta o veredito subjetivo de feel do Fabio. Uma acao obrigatoria no merge (item 1 das observacoes).

## Escopo verificado

- Novo autoload `autoloads/game_settings.gd` (`GameSettings`) + registro em `project.godot` e no contrato do `validate.gd`.
- `autoloads/render_profile.gd`: contrato de qualidade `Alta`/`Leve`.
- ESC completo em `presentation/hud/football_hud.gd` (abas Controles/Audio/Video/Sensibilidade).
- `modes/menu/main_menu_root.gd`: dropdown de qualidade agora funcional, volumes lidos de `GameSettings`.
- `modes/football/football_root.gd`: sensibilidade no spawn, refresh de qualidade em runtime, pause.
- Testes: `tests/unit/test_game_settings.gd`, `tests/unit/test_pause_menu.gd`. Captura: `tools/capture_track06b_esc_menu.gd`.

## GameSettings / persistencia (OK)

- `ConfigFile` em `user://jogodacopa_settings.cfg`: volumes (4 buses), fullscreen, qualidade, sensibilidade; defaults sanos e clamps em todos os campos.
- Fonte unica de verdade: menu principal e ESC leem/escrevem o mesmo `GameSettings` e sincronizam via sinais (`quality_changed` etc.). Sem caminhos divergentes.
- `_uses_validation_defaults()`: durante `validate.gd`/GUT, ignora o config do usuario e usa defaults - mantem os testes deterministicos sem sujar o `user://` real.
- Logs corretos: `push_error` em falha de save e em bus de audio ausente; `push_warning` quando fullscreen Web fica salvo mas pendente de gesto do navegador.

## RenderProfile Alta/Leve (OK, decisao de Fabio atendida)

- `Leve` roteia `get_active_profile_id()` para o profile `web` mesmo no desktop (`get_profile_id_for_quality(LIGHT, is_web=false) == web`), aplicando as constantes de fallback Web (viewports menores, glow/particulas reduzidos) - exatamente "Leve tambem no desktop".
- A decisao tecnica de aplicacao esta documentada na propria UI: ambiente/placares/SubViewports e preview atualizam na hora; materiais/caches pesados entram no proximo carregamento (label de aviso no painel Video). Coerente com "aplicar quando seguro".
- Registrado em `get_known_fallbacks()`.

## ESC menu (OK)

- Abas Controles (tabela 2 colunas vinda de `CONTROL_HINTS` da 06A), Audio (4 sliders), Video (tela cheia + Qualidade + aviso), Sensibilidade (slider). Mais Continuar / Reiniciar partida / Sair ao menu.
- ESC abre/fecha, mouse liberado, foco inicial em Continuar, secao default Audio. Tudo verificado em screenshots nas 3 resolucoes.
- Dropdown decorativo do menu principal agora e real (`Alta`/`Leve`), aplica no preview 3D e sincroniza com o ESC.

## Testes (clique real + persistencia + cross-platform) (OK)

- `test_pause_menu.gd`: clique REAL (`InputEventMouseButton` via `viewport.push_input` + `Input.flush_buffered_events`, no centro do `get_global_rect()` de cada controle), assertando o sinal proprio de cada controle (`pressed`/`toggled`/`value_changed`), em `1920x1080`, `1366x768`, `1280x720`. Cobre Continuar, Reiniciar, as 4 abas, os 4 sliders de volume, toggle de tela cheia, dropdown de qualidade (abre via clique real), slider de sensibilidade, Sair, e o dropdown de qualidade do menu principal. E o padrao correto (nao e teste de presenca).
- `test_game_settings.gd`: persistencia real - grava todos os campos, instancia NOVA carrega do arquivo e confere; e teste dedicado provando `Leve` = profile Web no desktop (viewport de placar/preview e particulas reduzidas), `Alta` = desktop.
- Validate full: PASS, `95` testes / `1512` asserts (era `91`/`1298`), Web gzip `30.34 MiB / 50.00 MiB`, source integrity `41` arquivos.
- Export Web release PASS; boot Web local `1280x720` PASS sem tela preta, console so com warnings conhecidos do RenderProfile (sem erros).

## Zero mudanca de gameplay (OK)

O `+46` em `football_root.gd` e: aplicar a sensibilidade salva no spawn, reconstruir ambiente/redimensionar SubViewports na troca de qualidade, e fios do pause. Fisica da bola, `kick`, movimento, regras e contratos de input nao foram tocados.

## Evidencia visual (analisada)

12 screenshots (`docs/screenshots/track-06b/`), 4 abas x 3 resolucoes. Conferido: tabela de Controles completa, 4 sliders de Audio, Video com tela cheia + Qualidade + aviso, Sensibilidade com slider; layout estavel ate `1280x720`. Estilo ainda e funcional/simples - esperado, pois a identidade broadcast e escopo da 06C/06D.

## Observacoes

1. OBRIGATORIO no merge: a branch ja atualizou `implementation/current-status.md`, `Estado_Atual.md` e `Prioridades_Estudio.md` para `READY_FOR_REVIEW_PRE_MERGE` (corretamente NAO alegam "merged"). Na FASE 8, ao mergear, o Codex precisa virar esse texto para o marker de MERGED (ex.: `JOGO_DA_COPA_TRACK_06B_ESC_MENU_V1_MERGED`) e mover o card para `Done/`; senao a `main` herda status defasado dizendo "aguardando review".
2. `load_settings()`: se o `ConfigFile.load` falhar por motivo diferente de arquivo inexistente (config corrompido), cai em defaults e retorna `false` SEM `push_warning`. Por "falha silenciosa proibida", sugiro logar `push_warning` no caso de erro de parse. Nao bloqueante.
3. No teste de qualidade, a ABERTURA do popup do `OptionButton` e por clique real, mas a SELECAO do item usa `select(1)` + `item_selected.emit(1)` (popups nativos sao dificeis de clicar headless). A fiacao selecao->profile fica coberta; so o clique no item do popup nao e via clique real. Aceitavel.
4. Estilo do ESC e plano de proposito - polish broadcast vem na 06C/06D. Nao e defeito.

## Proximo passo

1. Fabio da o OK de feel (abrir/fechar ESC, trocar abas, mexer nos sliders, testar `Leve` no desktop). Ajustes de feel entram na propria branch antes do merge.
2. Apos OK: Codex executa a FASE 8 - merge em `main`, card para `Done/`, ATUALIZAR os markers de status para MERGED (obs. 1), commitar os docs untracked de `docs/` (incluindo este review). Sem publicacao (so na 06E).
3. Push pelo GitHub Desktop.
4. Liberar a 06C ║ 06D (paralelas) - PRE-REQUISITO: baixar as Kenney Fonts (`assets/fonts/kenney/`) antes de comecar essas duas.
