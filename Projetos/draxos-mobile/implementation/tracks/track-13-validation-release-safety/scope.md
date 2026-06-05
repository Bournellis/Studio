# Track 13 - Foundation Validation And Release Safety

- Data: `2026-05-28`
- Status: `TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED`
- Base: `codex/draxos-mobile/track-12-boot-decomposition`
- Branch: `codex/draxos-mobile/track-13-validation-release-safety`

## Objetivo

Transformar validacao, readiness e publicacao Internal Alpha em um sistema seguro, repetivel e auditavel, sem adicionar feature jogavel e sem publicar nada por padrao.

## Dentro Do Escopo

- Runner unico `tools/validate_foundation.ps1` com perfis `Quick`, `Client`, `Release` e `Full`.
- Relatorios locais nao rastreados em `build/validation/foundation-validation-latest.json` e `.md`.
- `tools/publish_internal_alpha.ps1` protegido por modos explicitos.
- `Mode Plan` como default sem upload, deploy, secret update ou verificacao remota.
- `Mode Package` apenas local em `build/internal-alpha/`, sempre com `-ReleaseRoot` versionado.
- `Mode Upload`, `Mode DeployManifest` e `Mode FullPublish` exigindo `-ReleaseRoot` versionado e `-ConfirmRemoteMutation`.
- Checks de regressao `tools/check_release_safety.ps1` e `tools/check_track13_readiness.ps1`.
- Gate/template de walkthrough manual por plataforma.
- Documentacao e status do estudio alinhados a Track 13.

## Fora Do Escopo

- Feature jogavel nova.
- UX nova, economia, tuning ou balanceamento.
- Schema/backend novo.
- Publicacao real, deploy, upload ou mutacao remota durante a track.
- Edicao manual de cenas `.tscn`.
- Execucao real do walkthrough manual; a track entrega o gate e o template.

## Decisoes Travadas

- Safety primeiro.
- Remoto e opt-in; remoto read-only so roda com flag explicita e env publico.
- Publicacao remota exige confirmacao explicita por comando.
- Relatorios em `build/` sao artefatos locais ignorados.
- O cliente continua sem secrets/admin keys e sem autoridade de recursos/batalha.
