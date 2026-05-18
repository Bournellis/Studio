# server/

Backend do DraxosMobile. Contém schema do banco Postgres e Edge Functions do Supabase.

- `schema/` — migrations SQL e definicao de tabelas
- `functions/` — Edge Functions (TypeScript/Deno) para batalha, conta, base e social

Todo estado autoritativo do jogo passa por aqui. O cliente Godot nunca altera recursos diretamente.
