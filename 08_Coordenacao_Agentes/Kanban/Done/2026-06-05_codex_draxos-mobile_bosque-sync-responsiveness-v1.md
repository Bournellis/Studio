# Bosque Sync Responsiveness v1

## Status

Concluido localmente em 2026-06-05 na branch `codex/draxos-mobile/bosque-sync-responsiveness-v1`.

## Objetivo

Corrigir a regressao de responsividade do Bosque sem enfraquecer a autoridade do servidor: coleta, deposito e craft passam a responder imediatamente no cliente, enquanto encerramento e reward continuam dependentes do snapshot confirmado.

## Entregas

- Backend/contratos: `collect_batch` adicionado ao endpoint existente `/modes/session/event`, com migrations espelhadas em `server/schema` e `supabase/migrations`.
- Servidor: SQL valida nodes, item esperado, duplicidade, capacidade e rejeicao sem mutacao parcial.
- Compatibilidade: `collect_complete` permanece aceito para pacotes antigos.
- Cliente Godot: coleta local-first, batch/coalescing no bridge, fila deterministica `collect_batch -> deposit_all -> craft -> complete`.
- UX: deposito e craft nao bloqueiam em pendencia normal de sync; feedback passa a comunicar salvamento em segundo plano.
- Saida: `Voltar` preserva sessao e tenta flush curto sem prender o jogador.
- Autoridade: `Encerrar visita` continua bloqueado ate sync completo.
- Docs/status: `current-status`, docs de Openworld, contrato de database e coordenacao do Estudio atualizados.

## Validacao

- `deno test --allow-read server/tests/openworld_ruleset_definition_test.ts server/tests/modes_domain_test.ts`
- `deno check server/functions/_shared/mode_domain.ts supabase/functions/_shared/mode_domain.ts server/functions/modes/mode_handler.ts supabase/functions/modes/mode_handler.ts`
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --import`
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
- `git diff --check`

## Pendencias de release

- Aplicar migrations remotas com flag explicita exigida pelo projeto.
- Exportar Web e publicar na URL principal.
- Gerar/publicar APK.
- Registrar evidencia de preview, URL oficial e link do APK.

Essas pendencias dependem de autorizacao explicita de publicacao/remota.
