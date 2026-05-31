# Codex - DraxosMobile Remote Lab Runner

- Data: `2026-05-31`
- Projeto: `Projetos/draxos-mobile`
- Branch: `codex/draxos-mobile/remote-lab-runner`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-consistency-pass`
- Objetivo: permitir Battle Lab e Progression Lab no Web export usando runner remoto interno, protegido pela mesma entrada alpha de e-mail/Supabase do projeto.
- Arquivos pretendidos: `server/functions/lab-runner/`, `supabase/functions/lab-runner/`, `server/functions/deno.json`, `supabase/functions/deno.json`, `online/supabase_client.gd`, `dev/battle_lab/battle_lab_screen.gd`, `dev/progression_lab/progression_lab_screen.gd`, testes client/backend e docs operacionais.
- Docs lidos: `AGENTS.md`, `Projetos/draxos-mobile/AGENTS.md`, `implementation/current-status.md`, `Prioridades_Estudio.md`, `Projetos/README.md`, `Estado_Atual.md`.
- Plano de validacao: `git diff --check`, Deno check da nova function espelhada, testes backend do lab runner, GUT client focado nos labs e `validate.gd` se o escopo client exigir.
- Handoff: entregar runner remoto sem service role no cliente/export; se remoto nao puder ser publicado nesta etapa, deixar claro o deploy pendente.
- Status: `CONCLUIDO_LOCALMENTE`.
- Entrega: Battle Lab e Progression Lab agora possuem runner remoto interno para Web export, protegido pela mesma conta alpha Supabase por e-mail/senha e save `normal` registrado. O runner nao expõe service role, nao grava runs oficiais e nao muta economia/ranking/progresso.
- Validacao: `git diff --check`, Deno check da function espelhada, `lab_runner_contract_test`, `deno task check` em `server/functions` e `supabase/functions`, e Godot `tools/validate.gd` (`138/138`, `2364` asserts).
- Pendente externo: deploy/publicacao remota do pacote antes do proximo teste humano no link Web.
