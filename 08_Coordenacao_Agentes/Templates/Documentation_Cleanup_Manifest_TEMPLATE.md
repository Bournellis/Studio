# Manifesto de limpeza: <scope>

## Metadata

- status: template
- authority: operational_contract
- last_verified: 2026-07-17
- review_when: antes de qualquer remocao ou quando o HEAD mudar materialmente
- supersedes: none
- superseded_by: none

## Guard

- manifest_mode: `classification_only`
- destructive_authorization: `not_authorized`
- base_ref: `<branch@sha>`
- owner: `<owner>`
- scope: `<literal directories and files>`

Este manifesto prepara uma decisao. Ele nao remove arquivo, nao limpa historia Git e nao autoriza acao destrutiva.

## Preservacao obrigatoria

- decisoes de Fabio e gates humanos;
- contratos vigentes, licencas, provenance, hashes e receipts;
- migrations, evidencias nao regeneraveis e historico unico;
- trabalho nao integrado ou tocado por worktree ativa;
- conteudo cujo destino ou significado seja ambiguo.

## Candidates

| literal_path | classification | unique_content_destination | references_checked | recoverability | decision |
|---|---|---|---|---|---|
| `<path>` | `<keep|extract_then_remove|relocate_then_remove|remove_after_proof>` | `<path or n/a>` | `<result>` | `Git + <receipt>` | `pending` |

## Proof before execution

- [ ] HEAD e worktrees foram rechecados.
- [ ] Conteudo unico foi preservado e validado no destino.
- [ ] Links, validators, manifests e hashes foram rechecados.
- [ ] Targets literais da onda foram aprovados explicitamente.
- [ ] Commit-base local recuperavel foi registrado.
- [ ] A execucao sera uma tarefa separada, pequena e validada.

Sem todos os checks e a autorizacao aplicavel, o resultado permitido e somente `classification_only`.
