# Track 11 - Implementation Plan

## Etapa A - Auditoria E Coordenacao

- Ler portfolio, canon brief, registry, estado atual, AGENTS local e status local.
- Registrar worktree/branch no Kanban.
- Separar auditoria em pacotes: docs/coordenacao, cliente Godot, release/backend ops.
- Arquivar Doing antigo de DraxosMobile que ja representa tracks concluidas.

## Etapa B - Consolidacao Documental

- Criar Track 11 com escopo, plano, status, auditoria e registro dos pacotes paralelos.
- Reescrever `implementation/current-status.md` como snapshot operacional compacto.
- Atualizar `README.md` e `AGENTS.md` locais para Track 11.
- Atualizar `Prioridades_Estudio.md`, `Estado_Atual.md`, `Projetos/README.md` e `Painel_Visual_Estudio.html`.

## Etapa C - Release Ops E Readiness

- Atualizar manifest default espelhado em `supabase/functions/release/index.ts` e `server/functions/release/index.ts`.
- Atualizar `portal/internal-alpha/manifest.example.json`.
- Registrar republicacao Track 10/2026-05-28 em docs de handoff/publicacao.
- Adaptar `release_artifacts_remote_smoke.ts` para:
  - reconhecer Cloudflare Access somente com flag explicita;
  - permitir hash SHA256 completo opcional para APK/ZIP.
- Criar `tools/check_track11_readiness.ps1`.

## Etapa D - Primeiro Corte Seguro Do App Shell

- Extrair normalizacao/mensagem de erro de `modes/boot/boot.gd` para `modes/boot/ui/app_shell_error_contract.gd`.
- Manter comportamento existente.
- Adicionar teste unitario sem instanciar o app shell inteiro.

## Etapa E - Validacao E Commit

- Rodar readiness local.
- Rodar Godot validate e GUT client.
- Rodar Deno check dos arquivos alterados.
- Rodar `git diff --check`.
- Mover card Track 11 para `Done`, commitar e confirmar worktree limpa.
