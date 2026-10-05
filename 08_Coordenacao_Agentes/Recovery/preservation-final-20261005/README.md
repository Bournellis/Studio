# Fechamento da preservação — 2026-10-05

## Metadata

- status: historical
- authority: historical_record
- last_verified: 2026-10-05
- review_when: verificar backup e recuperação deste fechamento
- supersedes: none
- superseded_by: none

Os lotes 1 a 6 terminaram e suas autorizações foram consumidas. Este fechamento foi autorizado por Fabio; os studios permanecem congelados, com retenção passiva e consulta seletiva. Nova intervenção exige escopo explícito.

## Backup verificado

Destino: C:/Studio-preservation-backups/preservation-20261005-closeout/. C: está no disco físico 1; D: está no disco físico 0. Foram copiadas e verificadas 6162 entradas, 8.46 GiB: arquivo da limpeza, 140 APKs, índices, manifestos, provas originais e objetos LFS locais. SHA-256, tamanho e cópias independentes de bytes foram conferidos.

[record.json](record.json) fixa o hash do receipt externo e o manifesto inicial. O backup contém instruções de recuperação, manifest.json, BACKUP-VERIFIED.json e, após integração, os bundles Git finais e provas em closeout-evidence/. A cópia preserva o acervo desta limpeza; não é uma imagem completa dos studios ou do computador.

As origens históricas permanecem em D: e seus manifestos não foram reescritos. A recuperação aplica source_prefix_mappings para resolver os caminhos originais em um destino vazio. restore-probe.git e restored-samples continuam em D: como cópias redundantes de teste e não foram duplicados no backup.

## Fontes e limites

[sources.json](sources.json) preserva os blobs Git exatos das entradas anteriores. Gates e obrigações bloqueadas mantêm o mesmo JSON; somente o texto de orientação foi encerrado. Produto, assets, runtime, QA dos jogos, builds, integrações antigas, automações e publicação não foram retomados. Core e RPG Comando não foram alterados.
