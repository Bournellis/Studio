# DraxosMobile Internal Alpha Portal

Status: `BASE_COMPLETE`.

Este portal e o ponto unlisted da Internal Alpha v0. Ele nao e seguranca. O jogo precisa exigir email/senha e alpha gate no backend. O portal apenas organiza:

- link da build Web;
- download do APK Android;
- download do ZIP PC;
- changelog;
- checklist rapido do tester;
- problemas conhecidos.

## Arquivos

- `index.html`: portal estatico inicial.
- `manifest.example.json`: exemplo do manifest de updates.

## Como Usar

1. Depois de `T03-P16`, atualize os links em `index.html`.
2. Depois de publicar os artefatos, substitua os placeholders:
   - `ANDROID_APK_URL`;
   - `PC_ZIP_URL`;
   - `WEB_GAME_URL`;
   - `MANIFEST_URL`.
3. Publique esta pasta em um host estatico unlisted.
4. Envie o link apenas ao tester.

## Guardrails

- Nao colocar `service_role`, `sb_secret_...`, senha de banco ou senha de keystore no portal.
- Nao tratar URL unlisted como privada.
- Nao colocar dados pessoais reais no changelog.
- Nao prometer monetizacao real; loja alpha e proof-of-concept.

## Refinamento Futuro

Fabio vai trabalhar melhor no portal depois de `T03-P18`. Ate la, esta base e suficiente para release candidate.
