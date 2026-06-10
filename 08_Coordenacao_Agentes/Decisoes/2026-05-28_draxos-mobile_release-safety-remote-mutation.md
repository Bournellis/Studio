# Decisao: Release Safety Com Confirmacao Explicita De Mutacao Remota (registro retroativo)

## Metadata

- data: `2026-05-28` (Track 13; registrado retroativamente em 2026-06-10)
- decisor: `Shared`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

Agentes com acesso a CLI Supabase/Cloudflare podem publicar ou mutar infraestrutura remota por engano durante validacao.

## Decision

Publicacao remota so via `tools/publish_internal_alpha.ps1` com aprovacao explicita do usuario, `-ReleaseRoot` versionado fresco e `-ConfirmRemoteMutation`. `Mode Plan`/`Mode Package` sao os unicos modos default-safe. `validate_foundation.ps1 -Profile FullPublish` desabilitado por design. Nunca rodar mutacao remota como passo de validacao.

## Alternatives Considered

- Confiar em revisao humana do comando: rejeitado; fragil em operacao multiagente.

## Impact

Zero publicacoes acidentais desde a entrega do Track 13; padrao reutilizavel para projetos futuros com backend.

## Review When

Se o fluxo de release mudar de Cloudflare Pages/Supabase ou ganhar CI dedicada.
