# Code Review - Track 03I Menu Interaction Fix V1

- Date: `2026-06-11`
- Reviewer: Claude (Fable 5)
- Scope: commits `f40de7b..702725a` (primeira track sob o regime de evidencia de UI).

## Incidente de fechamento #4

Truncamento pos-fechamento de novo (5 ins/183 del, menu/tests/docs); restaurado e verificado por Claude no ritual. Reforca a necessidade da Track 03J (Quality Gates no AGENTS) e da espera de 15-30s antes de fechar a janela.

## Evidencias do regime novo - todas presentes

1. **Teste-primeiro comprovado pela historia do git**: `eb6c484 test(...): reproduce main menu real click failure` ANTES de `676ccce fix(...)`. O teste injeta mouse motion + press + release reais via `viewport.push_input` e asserta sinais - nao usa emit_signal/pressed().
2. **Causa raiz documentada e plausivel**: a raiz `MainMenuRoot` ficava com hit-area `0x0`, colapsando o hit-test de toda a cadeia (`MenuSafeArea > MenuScroll > ...`). Os filhos existiam e eram visiveis - por isso 2 gerasoes de testes de presenca passaram com o menu quebrado. Explica as DUAS falhas consecutivas de UI.
3. **Fix por simplificacao**: raiz sincronizada ao viewport com `MOUSE_FILTER_PASS`, hierarquia minima (preview/shade IGNORE, resto default), sem ScrollContainer para meia duzia de controles.
4. **3 resolucoes**: teste de clique parametrizado em 1920x1080/1366x768/1280x720; screenshots gerados e INSPECIONADOS por Claude - painel integro, todos os controles visiveis e alcancaveis nas tres (1080p e 720p verificados visualmente; layout centrado consistente).
5. **Regra permanente**: "UI Interaction Rule" registrada em `docs/architecture-overview.md`.

## Notas (nao bloqueiam)

- N1 (cosmetico): o enquadramento do preview 3D atras do menu esta sem graça (campo chapado em angulo baixo). Vale um ajuste de camera do preview numa track futura de polish.
- N2 (processo): este review ocorreu pos-merge porque a 03I foi especificada antes do regime pre-merge existir. A partir da 03J (Quality Gates no AGENTS), tracks de UI param na branch para review antes da merge.

## Verdict

**Aprovado** - pendente apenas da confirmacao visual/manual de Fabio clicando o menu de verdade (a evidencia automatizada e forte, mas o gate de UI termina no olho humano). Proximo: playtest de confirmacao completo + decisao das portas (docs/next-series-options.md) + aplicar a Track 03J quando Fabio quiser.
