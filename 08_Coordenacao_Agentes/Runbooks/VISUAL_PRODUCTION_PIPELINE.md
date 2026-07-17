# Pipeline de producao visual

## Metadata

- status: living
- authority: runbook
- last_verified: 2026-07-17
- review_when: o contrato de provenance, evidencia ou gate visual mudar
- supersedes: none
- superseded_by: none

## Objetivo

Transformar uma intencao visual local em asset integrado e evidenciavel sem confundir integracao tecnica, aprovacao artistica, licenca e publicacao.

Este runbook e um metodo operacional. Ele nao define direcao de arte, layout, produto ou prioridade para nenhum projeto.

## Estados

1. `reference_collected`: origem e risco foram registrados; ainda nao e asset de runtime.
2. `mockup_reference`: comunica a intencao em preview ou runtime, sem promessa de polish.
3. `polish_candidate`: esta integrado, legivel e tecnicamente revisavel.
4. `final_candidate`: passou pelos checks locais, mas continua pendente de revisao humana, legal e de publicacao.
5. `final_approved`: existe decisao humana identificavel para o escopo exato.

Nenhum agente promove um item para `final_approved` por inferencia. `final_candidate` nunca significa publicavel.

## Fluxo local-first

1. Ler o contrato visual e o estado tecnico do projeto receptor.
2. Registrar asset IDs, tamanhos de runtime, estados, restricoes e nao-escopo antes de produzir um lote.
3. Produzir primeiro uma referencia ou familia pequena; nao redesenhar o layout aprovado silenciosamente.
4. Registrar provenance prospectiva para cada asset novo que entrar no runtime.
5. Integrar em worktree do projeto e validar no menor perfil tecnico proporcional.
6. Capturar preview ou screenshot no perfil alvo sem incluir segredo, dado pessoal ou credencial.
7. Criar bundle de evidencia com `tools/create_evidence_manifest.py` quando a evidencia for versionada.
8. Registrar o gate humano separadamente do resultado tecnico.

O inventario, a provenance, os prompts autorizados e as evidencias vivem no projeto receptor. Cards locais nao editam snapshots globais; quando necessario, usam a fila de Portfolio Sync.

## Contrato do lote

Antes da producao, registrar:

- projeto, tela ou cena e contrato local de origem;
- asset IDs e paths pretendidos;
- dimensoes, transparencia, estados e area segura;
- elementos que a engine deve renderizar, como texto e numeros;
- referencia visual e o que nao pode ser copiado literalmente;
- ferramenta, modelo ou processo manual previsto;
- criterios tecnicos e decisoes subjetivas reservadas a Fabio;
- budget de arquivos, evidencia e storage;
- publication status inicial `not_reviewed`.

## Gates independentes

- Gate tecnico: importacao, layout, runtime, hashes e validadores estao verdes.
- Gate visual: Fabio aprova ou rejeita leitura, composicao, identidade e feel com base em evidencia.
- Gate de direitos: origem, licenca, termos, modificacoes e uso permitido foram revisados.
- Gate de publicacao: release, store, marketing e remoto foram autorizados explicitamente.

Um gate verde nao resolve os demais. QA em screenshot nao substitui device fisico quando o contrato local o exigir.

## Regras de seguranca

- Usar paths literais e worktree isolada; nunca escrever em `D:\Minigame Studio`.
- Nao embutir chaves, tokens, dados pessoais ou URLs autenticadas em prompt, asset, log ou evidencia.
- Texto, numeros, logos e marcas somente quando o contrato local e os direitos permitirem.
- Binario novo acima do limite duro exige LFS literal ou excecao registrada antes do commit.
- Gerador ou importador nao pode alterar arquivos fora do lote previsto; diff inesperado e hard stop.
- Rejeitados e intermediarios nao sao apagados por este runbook. Limpeza exige manifesto proprio e autorizacao aplicavel.

## Entrega minima

- inventario local atualizado;
- registros de provenance e hashes;
- assets e previews nomeados por ID;
- validacoes e manifest de evidencia, quando versionado;
- status tecnico, visual, direitos e publicacao separados;
- decisao humana pendente descrita sem presumir resultado.
