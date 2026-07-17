# Matriz de emuladores e API Android

## Metadata

- status: `living`
- authority: `technical_contract`
- last_verified: `2026-07-17`
- review_when: `Android preset, resolved SDK levels, viewport contract or product platform changes`
- supersedes: `generic or external device lists for DraxosMobile QA`
- superseded_by: `none`

## Fonte local

O produto é Android-first, portrait, `arm64-v8a`, com viewport-base `390x844` e mínimo de janela `360x640`. O contrato responsivo Android cobre `360x800` e `390x844`.

O preset atual não fixa `minSdk` ou `targetSdk`; portanto, esta matriz não inventa uma faixa de suporte.

Uma tarefa autorizada de candidato extrai do APK `resolved_min_sdk`, `resolved_target_sdk` e `resolved_compile_sdk`. Os inteiros entram no recibo e resolvem os símbolos abaixo somente no relatório daquela rodada.

Isso é evidência do candidato, não decisão permanente de suporte.

## Perfis obrigatórios quando existir candidato

| profile_id | API | Viewport e navegação | Objetivo DraxosMobile |
|---|---|---|---|
| `android_compact_floor` | `resolved_min_sdk` | portrait `360x800`, arm64, navegação disponível nessa API | entry/login, update panel, Refúgio, Arena, scroll e touch targets |
| `android_reference_target` | `resolved_target_sdk` | portrait `390x844`, arm64, gesture navigation | fluxo técnico login → Refúgio → Arena → resultado → resume |
| `android_tall_cutout_target` | `resolved_target_sdk` | portrait `432x936`, arm64, cutout e gesture navigation | teclado, overlays, barras do sistema e risco de safe area |
| `android_recovery_target` | `resolved_target_sdk` | portrait `390x844`, arm64 | background/foreground, perda de processo e recuperação de sessão/tentativa |

Se `resolved_min_sdk == resolved_target_sdk`, os perfis compact e reference continuam separados por viewport e cenário. Uma imagem indisponível é `blocked_environment`; não se troca silenciosamente o nível API.

## Roteiro técnico comum

1. Confirmar que o APK rehashado coincide com o recibo do candidato.
2. Instalar sem usar conta, token, keystore ou serviço remoto de produção.
3. Verificar boot, entry/login local permitido, update panel, Refúgio e entrada/saída da Arena técnica.
4. Verificar toque, scroll, teclado, retorno, rotação bloqueada em portrait e ausência de clipping.
5. No perfil recovery, registrar background/foreground, encerramento pelo sistema e retomada.
6. Registrar resultado por `profile_id`, API inteira, resolução, SHA256 do APK e source SHA.

## Fora da matriz

- Tablet, landscape, ChromeOS, iOS e mobile browser não são compromissos desta baseline.
- Marca/modelo comercial e aparelho físico não são emuladores canônicos.
- Passar na matriz não prova performance térmica, haptics, conectividade real, ergonomia física ou Arena product proof.
