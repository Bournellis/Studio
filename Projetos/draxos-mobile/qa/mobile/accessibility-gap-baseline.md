# Baseline de acessibilidade mobile

## Metadata

- status: `living`
- authority: `technical_contract`
- last_verified: `2026-07-17`
- review_when: `a listed area is implemented, audited or becomes a candidate gate`
- supersedes: `implicit accessibility assumptions from responsive layout alone`
- superseded_by: `none`

Esta baseline registra cobertura e gaps; ela não abre feature, aprova visual ou transforma risco em requisito de produto sem decisão própria.

## Baseline

| Área | Estado | Evidência existente | Limite ou gap | Revisar quando |
|---|---|---|---|---|
| Touch | `covered_with_manual_residual` | alvos `56px`, CTAs `60px` e regressões touch | ergonomia física não provada | controles mudarem ou antes de `PhysicalGate` |
| Contraste | `gap` | tokens de cor centralizados | não há cálculo de contraste, matriz de estados ou veredito humano rastreado | tokens/branding mudarem ou em `VisualCheck` de candidato |
| Reduced motion | `gap` | nenhuma preferência ou contrato encontrado | animações não expõem modo reduzido verificável | motion entrar em escopo ou antes de audiência ampliada |
| Locale | `gap` | texto atual majoritariamente PT-BR | não há catálogo de tradução, locale switch ou pseudo-localização | novo locale ou expansão de público for proposta |
| Safe areas | `gap` | `immersive_safe_rect()` aplica margem interna responsiva | não consome safe area/cutout do sistema operacional | `android_tall_cutout_target` ou UI fullscreen mudar |
| Lifecycle | `gap` | cache/resume de sessão possui testes locais | não há prova Android de pause/resume, process death e retorno | candidato Android executar `android_recovery_target` |
| Haptics | `gap` | nenhum contrato ou chamada runtime encontrada | feedback háptico permanece sem decisão e sem fallback | Fabio adotar haptics ou um fluxo depender desse feedback |

## Exceções temporárias

Os gaps permanecem aceitos para o alpha interno porque Arena proof ainda está pendente e esta onda não autoriza implementação.

Em projeto ativo, cada gap está refletido no `qa_manifest.json` com motivo e `review_when`. Tocar a área exige decompor o gap ou registrar nova decisão.

Touch é `covered` no manifesto somente para o contrato automatizado atual. `PhysicalGate` continua obrigatório para ergonomia real. O “safe frame” interno não equivale a safe area do Android.

## Evidência mínima para fechar um gap

- teste automatizado ou roteiro manual versionado ligado a source/candidate SHA;
- ambientes e viewports explícitos;
- resultado sem segredo, identificador pessoal ou aprovação de produto implícita;
- atualização coordenada deste arquivo, `qa_manifest.json` e `QA_INDEX.md`.
