# Active Games Hardening Program - Handoff

- Data: `2026-06-09`
- Agente: Codex
- Branch: `codex/estudio/active-games-hardening-program`
- Worktree: `D:\Estudio-worktrees\estudio--codex--active-games-hardening-program`
- Escopo entregue: primeira onda executavel de hardening dos dois jogos ativos, focada em contratos, validacao e guardas antes de refactors maiores.

## Estado Entregue

### Draxos Roguelike Cardgame

- Criada matriz viva de validacao por tipo de mudanca em `Projetos/draxos-roguelike-cardgame/docs/hardening-validation-matrix.md`.
- Adicionado validador estatico de `promotion_manifest.json` do Design Lab em `tools/lab/design_lab_promotion_manifest_validator.gd`.
- `design_lab_reporter.gd` agora bloqueia escrita de reports quando o manifesto de promocao nao preserva aprovacao manual, candidatos selecionados estruturados e validacoes obrigatorias.
- `tests/unit/test_design_lab_tooling.gd` cobre manifesto valido escrito pelo reporter e rejeicao de manifesto inseguro.
- `docs/design-lab.md`, `docs/autorun-lab.md`, `tools/README.md` e `implementation/current-status.md` foram alinhados ao novo gate.

### DraxosMobile

- Criado `Projetos/draxos-mobile/docs/hardening-program.md` como mapa vivo de fronteiras, matriz de validacao, ordem de refactor e guardas de pacote atual.
- Criado `Projetos/draxos-mobile/tools/check_hardening_contracts.ps1`.
- `validate_foundation.ps1 -Profile DocsOnly` agora executa a guarda de hardening.
- `docs/agent-operating-manual.md`, `docs/documentation-index.md`, `docs/multi-agent-workflow.md`, `tools/README.md` e `implementation/current-status.md` apontam para o novo contrato.
- Nenhuma publicacao, deploy, upload, schema remoto, tuning, economia ou gameplay foi alterado.

## Validacoes Executadas

- Global: `git diff --check` - PASS.
- Roguelike: `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd` - PASS, `221/221` GUT tests, `1953` asserts.
- Mobile: `tools/check_hardening_contracts.ps1 -ProjectDir .` - PASS.
- Mobile: `validate_foundation.ps1 -ProjectDir . -Profile DocsOnly -NoProjectWrites` - PASS.
- Mobile: `validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun -NoProjectWrites` - PASS.

## Riscos Residuais

- Este handoff entrega a base de contratos e gates para o programa completo; as ondas de refactor mecanico em runtime continuam devendo ser executadas em trilhas menores e seriais.
- Roguelike ainda deve executar refactors de `BattleEngine`, `BattleRoot`, `RunSession` e catalog split apenas depois de testes de paridade especificos por fronteira.
- Mobile ainda deve dividir `SessionStore`, `SupabaseClient`, bridge do Bosque, Arena presenters/handlers e espelhos server/supabase em trilhas separadas, sempre com gates correspondentes.
- Playtest humano do pacote Mobile `BOSQUE_DIEGETIC_LAUNCHER_FOUNDATION_V1_PUBLISHED_INTERNAL_ALPHA` continua sendo entrada prioritaria antes de refactor pesado em UX/runtime.
- Avisos opcionais de assets visuais/GUT resource/alpha no Roguelike permanecem conhecidos e nao bloqueantes.

## Status De Portfolio

Sem mudanca de prioridade, estagio publicado ou proximo passo observavel nos documentos raiz:

- `Draxos Roguelike Cardgame` continua `P0_IMPLEMENTACAO`, com Design Lab como ponte recomendada antes de full-run feel playtests.
- `DraxosMobile` continua `P2_IMPLEMENTACAO`, com Bosque Diegetic Launcher Foundation v1 como Internal Alpha publicado e playtest humano focado como proximo passo.
- `Prioridades_Estudio.md`, `Estado_Atual.md` e `Projetos/README.md` nao exigiram atualizacao.

## Proximo Handoff

Abrir trilhas menores por projeto:

1. Roguelike combat/UI/run-data: refactors de baixo risco com paridade local.
2. Mobile session/client/openworld/arena: splits de dominios com `ClientQuick`, `ServerQuick` ou `FullLocal` conforme arquivo tocado.
3. Integrar uma trilha por vez e rodar gates completos apos cada merge.
