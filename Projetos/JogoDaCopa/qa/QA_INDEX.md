# QA Index — JogoDaCopa

## Metadata

- status: living
- authority: technical_contract
- last_verified: 2026-07-16
- review_when: runner, jornada, gate ou ambiente mudar
- supersedes: none
- superseded_by: none

O JSON é a autoridade de comandos; este índice governa leitura humana, jornadas, gates e evidências. IDs devem corresponder exatamente.

## Runners

- runner_id: `structure_fast`
- runner_id: `rules_fast`
- runner_id: `runtime_full`
- runner_id: `web_package_local`

## Jornadas críticas

- capability_id: `boot`
- capability_id: `match`
- capability_id: `ball`
- capability_id: `super`
- capability_id: `goal`
- capability_id: `pause`
- capability_id: `result`
- capability_id: `web_package`
- capability_id: `feel`
- capability_id: `camera`
- capability_id: `audio`
- capability_id: `visual`
- capability_id: `publication`

## Gates

Boot, partida, bola, SUPER, gol, pause, resultado e pacote Web possuem cobertura automática local. Feel, câmera, áudio, visual e publicação permanecem manuais; a automação fornece evidência, não decisão.

Execução Runtime deve preservar 108/108 testes e 1.844 asserts, rodar duas vezes sem alterar arquivos rastreados e nunca publicar. Evidência histórica permanece em `../docs/playtest-reports/` e `../docs/screenshots/`; novos bundles seguem `estudio_evidence_v1` após o cutover.
