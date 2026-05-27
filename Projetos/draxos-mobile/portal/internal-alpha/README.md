# DraxosMobile Internal Alpha Portal

Status: `BASE_COMPLETE_WITH_MANIFEST_CONTRACT`.

Este portal e o ponto unlisted da Internal Alpha v0. Ele nao e seguranca. O jogo precisa exigir email/senha e alpha gate no backend. O portal apenas organiza:

- link da build Web;
- download do APK Android;
- download do ZIP PC;
- changelog;
- checklist rapido do tester;
- problemas conhecidos.

## Arquivos

- `index.html`: portal estatico inicial.
- `manifest.example.json`: exemplo do manifest de updates usado por `GET /release/manifest`.

## Como Usar

1. Depois de `T03-P16`, atualize os links em `index.html`.
2. Depois de publicar os artefatos, substitua os placeholders:
   - `ANDROID_APK_URL_PENDING_T03_P16`;
   - `ANDROID_APK_SHA256_PENDING_T03_P16`;
   - `PC_ZIP_URL_PENDING_T03_P16`;
   - `PC_ZIP_SHA256_PENDING_T03_P16`;
   - `WEB_GAME_URL_PENDING_T03_P16`;
   - `PORTAL_URL_PENDING_T03_P16`.
3. Publique esta pasta em um host estatico unlisted.
4. Envie o link apenas ao tester.

O manifest real da alpha v0 e servido pela Edge Function publica:

```text
https://<project-ref>.supabase.co/functions/v1/release/manifest
```

O arquivo `manifest.example.json` e a copia documental do schema esperado para atualizar links/notas em `T03-P16`.

## Guardrails

- Nao colocar `service_role`, `sb_secret_...`, senha de banco ou senha de keystore no portal.
- Nao tratar URL unlisted como privada.
- Nao colocar dados pessoais reais no changelog.
- Nao prometer monetizacao real; loja alpha e proof-of-concept.

## Refinamento Futuro

Fabio vai trabalhar melhor no portal depois de `T03-P18`. Ate la, esta base e suficiente para release candidate.
