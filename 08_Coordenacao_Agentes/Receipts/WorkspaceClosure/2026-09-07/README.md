# Recuperação e fechamento do workspace — 07/09/2026

- status: `historical`
- authority: `execution_evidence`
- documentation_class: `evidence`
- source_baseline: `dd914833f3c1f0f5521219136dfd672fbe0cb907`
- product_effect: `none`
- human_gate_effect: `none`

Esta evidência acompanha a execução do plano de integridade autorizado por
Fabio em 06/09/2026. Não integra a leitura cotidiana de produto. O arquivo
externo desta onda é `D:\StudioRecovery\closure-20260907`; os manifests e seus
hashes estão no índice desta pasta. A cópia independente fica em
`C:\Users\Fabio\StudioRecovery\closure-20260907`, em outro disco físico local.

## História protegida

A auditoria congelou 7.028 objetos sem referências: 292 commits, 4.529 árvores
e 2.207 blobs. Todos passaram a ser alcançáveis pelas 110 referências locais
`refs/recovery/closure-20260907/`: 109 pontas de commits e um envelope de
custódia para 692 raízes de árvores e 275 blobs isolados.

O envelope usa nomes sintéticos baseados nos OIDs. Ele não reproduz um
checkout de produto e não atribui origem que o Git não comprovou. As refs são
locais, não branches de trabalho e não são enviadas ao remoto.

Os 292 commits receberam disposição individual: 149 têm patch equivalente no
histórico principal; 29 têm árvore inteira idêntica; 14 têm todas as
pós-imagens preservadas; dois não têm delta contra o primeiro pai; 98 foram
revistos em contexto. Não houve cherry-pick de experiência rejeitada, versão
superada ou proposta não adotada.

Outros 5.435 objetos não eram alcançados por essas pontas de commits. Incluem
árvores de snapshots, documentação, arte, perfis de navegador, código em
conflito ou truncado e protótipos. A classificação por OID preserva essas
distinções. A custódia integral de `.git` conserva inclusive reflogs e objetos
fora das refs originais; sua restauração a partir de C: passou por SHA-256 de
todos os arquivos e `git fsck --full --no-reflogs`.

## Material recuperado

- Copa Track04f2: 26 arquivos, 21.578.020 bytes, provenientes do commit
  `d0210c0b04de15494074d861782aca4b4b9a2c2e`; capturas e medições históricas.
- Copa: três documentos, 14.336 bytes, sobre opções de sequência, proposta
  operacional e revisão Track03g/03h; preservados como registros não adotados.
- Relatórios externos: 18 arquivos, 386.348 bytes, provenientes do contêiner
  de worktrees; o destino de custódia mantém o path original e o SHA de cada um.

Esses materiais não comprovam QA atual nem reabrem gates. A consulta literal
usa os manifests de origem e blobs/commits protegidos ou os payloads externos.
Não restaurar documentos antigos por cima das autoridades vivas.

Entre os snapshots residuais há protótipos de upload TUS em
`publish_internal_alpha.ps1`, ausentes do código atual e sem aprovação ou
completude comprovadas. O índice por OID permite consulta futura, sem executar
publicação remota ou transformar essa descoberta em trabalho de produto ativo.

## Retenção e fechamento

O inventário dos ignorados classifica 7.057 arquivos, 2.211.257.483 bytes, em
96 grupos. Builds e rollback, referências artísticas, evidências, runs,
toolchains, configuração privada e derivados permanecem explicitamente
retidos. Os arquivos privados foram inventariados somente por metadados.
O manifesto `cleanup-retention-manifest-v1.md` e suas decisões CR-001–009
permanecem intactos.

A principal foi reanexada à `main` no mesmo commit, sem reset ou alteração de
bytes. Integração, validações, push e remoções efetivamente concluídos são
atestados pelo receipt final externo, não antecipados por este índice.
Documentation Lite conserva sua tag, 19 receipts e 915 fontes recuperáveis.
As decisões humanas pendentes e a pausa dos trabalhos de produto permanecem
separadas deste fechamento técnico.
