# QA mobile — DraxosMobile

## Metadata

- status: `living`
- authority: `router`
- last_verified: `2026-07-17`
- review_when: `mobile QA intentions, Android support or candidate integrity contracts change`
- supersedes: `none`
- superseded_by: `none`

Esta pasta roteia QA mobile local. `../qa_manifest.json` continua sendo a autoridade de runners e `../QA_INDEX.md` continua sendo o índice humano de jornadas e gates.

## Ordem de leitura

1. `intent-contract.md` — significado de `DocsCheck`, `Iterate`, `VisualCheck`, `AndroidCheck`, `CandidatePrepare` e `PhysicalGate`.
2. `emulator-api-matrix.md` — perfis de emulador derivados do contrato do DraxosMobile e dos níveis API resolvidos no candidato.
3. `candidate-promotion-receipts.md` — vínculo imutável entre source, artefato, qualificações e registro local de promoção por SHA256.
4. `accessibility-gap-baseline.md` — cobertura e gaps de touch, contraste, reduced motion, locale, safe areas, lifecycle e haptics.

Schemas v1 ficam em `schemas/`. O helper local `../../tools/mobile_candidate_receipts.py` prepara e verifica recibos em dry-run por padrão; ele não é runner de build ou publicação.

## Fronteiras

- Android é o canal primário; PC e Web permanecem canais locais de teste e review.
- Esta documentação não cria APK, candidato, recibo real, export, suporte de API, publicação ou aprovação de Arena.
- Emulador não substitui `PhysicalGate`; `PhysicalGate` não autoriza promoção ou publicação.
- Nenhuma lista de aparelhos de outro workspace é autoridade para o DraxosMobile.
- Secrets, keystore, identificadores de aparelho e paths absolutos não entram em recibos ou evidências rastreadas.
