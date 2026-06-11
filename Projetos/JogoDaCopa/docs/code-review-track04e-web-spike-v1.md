# Code Review PRE-MERGE - Track 04E Web Export Spike & Render Profile V1

- Date: `2026-06-11`
- Reviewer: Claude (Fable 5)
- Branch: `codex/jogodacopa/track04e-web-spike-v1` (parou na branch, como instruido)
- Veredito: **NAO APROVADA AINDA - hotfix 04E.1 obrigatorio na mesma branch antes do merge** (evidencia invalida; codigo de alta qualidade)

## O que esta excelente (codigo)

- `autoloads/render_profile.gd` e exemplar: todos os valores em constantes nomeadas, roles por tipo de material/shader, contrato auto-validavel (`validate_profile_contract` com `push_error`), fallbacks documentados como `push_warning` unico no boot web, zero fork de gameplay.
- Refactor de `_build_night_environment` e FIEL 1:1: todos os valores desktop (background 0.82/0.72, ambient 0.34/0.74, tonemap 1.08/1.72, glow 0.42/0.92/0.28/0.86/1.65/9.0, ssao, fog) conferidos contra main, identicos. Sky noturno intocado.
- Export Web contratual: `thread_support=false`, sem SharedArrayBuffer, sem COOP/COEP - exatamente a decisao registrada. Validate ganhou `_check_web_export_contract` e check do autoload.
- 4 testes unitarios novos de RenderProfile; validate PASS 85 testes/1250 asserts.
- Gate permanente registrado em AGENTS local + validation.md (build web + smoke + screenshot por track).
- Integracao por roles em factory/builder/ball/avatar/feedback com multiplier 1.0 no desktop = desktop bit-identico por construcao.

## BLOQUEANTE B1 - Evidencia visual invalida (capture pipeline mente)

TODAS as cenas de jogo das evidencias (desktop E web) mostram o estadio LAVADO/claro, nao a arena noturna aprovada. Medicao objetiva (luma media do ceu, quadrante superior direito):

| Fonte | Ceu (luma 0-255) |
|---|---|
| 04C aprovada (behind-goal / high-diagonal) | 53.7 / 60.0 |
| 04E desktop kickoff/goal/result | 170.8 / 176.8 / 177.7 |
| 04E web kickoff/goal/result | 173.5 / 171.4 / 170.1 |
| 04D result (ja aprovada, mesma infra de captura simulada) | 105.0 |

Constatacoes:

1. O codigo do environment esta correto e `_configure_world()` e incondicional - o problema esta no CAMINHO DE CAPTURA em runtime, nao no refactor. O jogo real no editor permanece noturno (playtests de Fabio nunca viram "dia").
2. O bug e PRE-EXISTENTE: a result da 04D ja saia lavada (105) e passou no review porque o objeto avaliado era o painel de stats - falha de review minha, registrada abaixo.
3. A 04E HERDOU e possivelmente agravou (105 -> ~173) o estado via os capture scenes novos (`jdc_capture` + `debug_start_match`).
4. CONSEQUENCIA GRAVE: o relatorio de paridade desktop vs web descreve fenomenos ("night sky has more contrast", "ACES/night fog gives deeper stadium volume", glow nas estruturas) que NAO sao visiveis nas proprias imagens anexadas. O inventario de paridade nao e confiavel e a decisao visual de Fabio nao pode ser tomada sobre ele.
5. Paridade desktop-vs-web ENTRE SI e alta nas capturas (ambas igualmente lavadas) - o RenderProfile provavelmente funciona; nao da para afirmar ate recapturar com a noite real.

## B2 - BOM U+FEFF introduzido em 5 arquivos .gd

`runtime_primitive_factory.gd`, `player_avatar_3d.gd`, `combatant_3d.gd`, `football_ball.gd`, `football_field_builder.gd` ganharam BOM no inicio (`+﻿class_name`). Godot tolera, mas e sujeira de encoding que o source-integrity nao detecta hoje. Limpar no hotfix + estender o check.

## Hotfix 04E.1 (mesma branch) - escopo obrigatorio

1. TEST-FIRST: teste que reproduza o bug ANTES do fix (vermelho confirmado): na cena montada em modo captura, assert WorldEnvironment presente com `tonemap_mode == ACES`, `background_mode == BG_SKY` e `sky_top_color` escuro; MAIS check de luminancia na imagem capturada (ceu < 90 em cena noturna de jogo; lavado e 170+).
2. Diagnostico com debugger/console: por que o caminho de captura perde o ambiente noturno (erros de runtime durante `_configure_world`/sky? environment substituido depois? estado dos capture scenes?). ROOT CAUSE documentado por escrito - proibido corrigir sem explicar.
3. Recapturar TODAS as evidencias (desktop + web, mesmas cenas) com a noite real e refazer o inventario de paridade item a item.
4. Remover os 5 BOMs + source-integrity passa a rejeitar BOM em `.gd`/`.gdshader`.
5. O check de luminancia de captura entra no gate web permanente (impede regressao silenciosa de ambiente para sempre).

## Licao de processo (minha, registrada)

Na 04D aprovei a captura de result olhando o painel e nao o ambiente. Regra nova de review: toda captura de cena de jogo e comparada contra a baseline visual da track anterior aprovada (e agora ha check numerico de luminancia no proprio validate, entao a classe inteira de regressao fica coberta por maquina).

## Re-review pos-hotfix 04E.1 (2026-06-11, mesma data)

**VEREDITO FINAL: APROVADA PARA MERGE**, condicionada a aprovacao visual de Fabio sobre a paridade desktop vs web.

- Test-first cumprido de verdade: gate vermelho confirmado antes do fix (sky luma `180.2` >= 90) e verde depois (60.2-75.8 nas cenas desktop).
- Root cause documentada: o caminho de evidencia reusava a chase camera de gameplay (baixa, FOV 82, dentro da arena, amostra dominada por vidro/teto/fog claro). Fix: camera de evidencia dedicada `Track04ECaptureCamera` so em modo captura, constantes nomeadas, zero fork de gameplay/render.
- Recapturas CONFERIDAS por luminancia: desktop ceu 71-73 (familia noturna; baseline 04C 54-60), web ceu 9-11. Arena noturna com neon/torcida visivel nas duas plataformas.
- BOMs removidos nos 5 arquivos (verificado byte a byte) + validate rejeita BOM permanentemente.
- Gate de luminancia permanente no capture tool (`NIGHT_SKY_MAX_LUMA_255 = 90.0`, aborta com erro) + captura obrigatoria por track via AGENTS = regressao de ambiente coberta por maquina.
- Validate PASS 86 testes/1264 asserts; export web PASS single-threaded; Chrome smoke PASS; perf web saudavel (rAF medio 7.03ms, p95 7.0ms).

### Decisao visual pendente (Fabio)

Web e visivelmente MAIS ESCURO que desktop (ceu ~10 vs ~72): "noite mais fechada e limpa" no Compatibility. Se quiser aproximar do desktop, e tuning centralizado das constantes `WEB_*` do RenderProfile (barato, follow-up de polish).

### Follow-ups registrados

- F1 (para 04F, importante): evidencia da VISAO DA CHASE CAMERA (o que o jogador realmente ve) desktop vs web - as capturas atuais usam so a camera de evidencia externa; a paridade da visao de gameplay no web ainda nao foi evidenciada.
- F2: ceu desktop da camera de evidencia (71-73) levemente acima da baseline 04C (54-60) - aceitavel, mesma familia; observar apos F1.

## Pos-merge

Merge em main, validate integrado, PUSH PENDENTE via GitHub Desktop, e segue para 04F (Web RC).
