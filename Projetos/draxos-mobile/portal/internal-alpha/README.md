# DraxosMobile Internal Alpha Portal

Status: `T03_P18_HANDOFF_READY`.

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

1. Use `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html` como URL estavel do portal.
2. Use o manifest remoto para conferir links e hashes da build vigente.
3. Para um update, gere novos artefatos, rode `tools/publish_internal_alpha.ps1`, gere o pacote Cloudflare Pages e publique um novo deploy.
4. Envie o link apenas ao tester.

O manifest real da alpha v0 e servido pela Edge Function publica:

```text
https://<project-ref>.supabase.co/functions/v1/release/manifest
```

O arquivo `manifest.example.json` e a copia documental do manifest vigente da Internal Alpha v0. Os hashes finais ficam registrados em `../../docs/internal-alpha-v0-export-report.md` e `../../docs/internal-alpha-v0-publication-report.md`.

Em `T03-P17`, o portal publicado foi gerado em `build/internal-alpha/publish/portal/` por `tools/publish_internal_alpha.ps1`. Em `T03-P18`, o source versionado tambem foi atualizado com os links reais para facilitar iteracao futura.

## Guardrails

- Nao colocar `service_role`, `sb_secret_...`, senha de banco ou senha de keystore no portal.
- Nao tratar URL unlisted como privada.
- Nao colocar dados pessoais reais no changelog.
- Nao prometer monetizacao real; loja alpha e proof-of-concept.

## Refinamento Futuro

Fabio vai trabalhar melhor no portal depois de `T03-P18`. Ate la, esta base e suficiente para release candidate.
