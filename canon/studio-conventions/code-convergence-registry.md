# Registro de convergencia de codigo

## Metadata

- status: living_read_only
- authority: operational_contract
- last_verified: 2026-07-17
- review_when: uma segunda implementacao equivalente ou extracao compartilhada for proposta
- supersedes: none
- superseded_by: none

## Estado

- registry_mode: `observation_only`
- shared_core_status: `not_authorized`
- extraction_candidates: `5_deferred`

Este registro torna semelhancas visiveis sem criar dependencia entre projetos. Ele nao autoriza shared core, addon global, movimentacao de arquivos nem mudanca de contrato local.

## Quando registrar

Uma observacao pode virar candidato somente quando existem pelo menos duas implementacoes locais com responsabilidade equivalente, testes identificaveis e limites de produto compativeis.

Nomes parecidos, utilitarios pequenos ou copia historica nao bastam. O agente deve comparar comportamento, ownership, persistencia, plataforma, falhas e contratos de dados.

## Recibo do candidato

Use `08_Coordenacao_Agentes/Templates/Code_Convergence_Candidate_Receipt_TEMPLATE.md` para registrar:

- projetos, commits, paths e hashes observados;
- responsabilidade comum e diferencas obrigatorias;
- contratos e testes locais que nao podem regredir;
- custo de dependencia, versao, rollback e ownership;
- status `observation`, `local_adoption_proposed`, `extraction_proposed`, `rejected` ou `superseded`;
- decisao humana ou tecnica necessaria antes de qualquer escrita.

O recibo e read-only em relacao aos projetos observados. Ele nao altera arquivos, nao promove comportamento a canon e nao cria fonte compartilhada.

## Gate de extracao

Uma extracao futura exige tarefa `cross_project` ou `global_governance`, escritor global, adocao explicita de cada projeto receptor, suite de regressao e plano de rollback.

Ate esse gate, cada projeto continua dono de sua implementacao. Correcao local nao deve ser atrasada para perseguir convergencia abstrata.

## Registro atual

Os cinco grupos auditados estao fixados por path e SHA-256 em `08_Coordenacao_Agentes/Registers/code-convergence-candidates-v1.md`.

Todos permanecem `candidate/deferred`. Os helpers de evidencia, LFS e secret scan sao tooling global novo; eles nao extraem runtime dos projetos nem formam shared core de gameplay.
