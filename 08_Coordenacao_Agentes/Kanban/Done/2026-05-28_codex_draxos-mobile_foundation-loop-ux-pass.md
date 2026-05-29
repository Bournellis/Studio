# DraxosMobile - Foundation Loop UX Pass 01

- status: `Done`
- projeto: `draxos-mobile`
- agente: `Codex`
- branch: `codex/draxos-mobile/foundation-loop-ux-pass`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-app-v0-audit`
- base: `c0df1e5`
- data: `2026-05-28`

## Objetivo

Executar o pacote completo recomendado pela Foundation Loop Audit:

`Base -> coletar recursos -> evoluir base -> batalhar -> receber recompensas -> verificar base novamente`

## Entregue

- Refugio ganhou `RefugeLoopPanel` com proxima acao, coleta e evolucao visiveis sem abrir menu.
- CTA primaria passou a usar recompensa de batalha nao vista, em vez de qualquer log antigo.
- Coleta rotineira deixou de pedir confirmacao intermediaria nos caminhos principais.
- Resumo de batalha passou a conduzir para `Voltar e verificar base`.
- Retorno da batalha marca o resultado como visto, salva cache e reabre o ciclo da base.
- `SessionStore` passou a persistir `last_battle_result_seen`.
- Smoke sem rede `tools/smoke_foundation_loop.gd` cobre prioridade do loop.
- Docs vivos e coordenacao foram atualizados para tratar o pass como candidato local de baseline, pendente de revisao manual.

## Fora De Escopo Mantido

- Social novo.
- Visual final, tema final ou apresentacao final de batalha.
- Armas, spells, economia, Battle Pass, balanceamento ou grande volume de conteudo.
- Backend/schema/Supabase APIs.
- Publicacao remota.

## Validacao

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_hardening.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
.\tools\check_agent_ops_foundation.ps1 -ProjectDir .
.\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick -RequireClean:$false
```

Resultados:

- `git diff --check`: OK.
- `smoke_foundation_loop.gd`: OK.
- `smoke_foundation_hardening.gd`: OK.
- GUT client: OK, `111/111` testes, `1794` asserts.
- `validate.gd`: OK.
- `check_agent_ops_foundation.ps1`: OK.
- `validate_foundation.ps1 -Profile Quick`: falhou apenas no drift SQL preexistente dos mirrors `server/schema/migrations` e `supabase/migrations` para `202605270003_internal_alpha_private_downloads.sql`; nao corrigido porque backend/schema esta fora deste pacote.

Notas: os smokes imprimem `telemetry HTTP_ERROR` em ambiente sem rede e warnings de `ObjectDB instances leaked`; comportamento ja observado nos smokes/GUT locais e nao tratado neste pacote.

## Proximo Passo

Revisar manualmente Foundation Loop UX Pass 01 em Android/Windows/Web. Se a ergonomia do loop for aceita, decidir o pacote de Social Basico; se nao for aceita, registrar friccao especifica e ajustar somente o loop.
