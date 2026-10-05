# Limpeza preservadora — 2026-10-05

## Metadata

- status: historical
- authority: historical_record
- last_verified: 2026-10-05
- review_when: verificar recuperação desta limpeza
- supersedes: none
- superseded_by: none

Fabio autorizou os lotes 3 a 6; a execução física e a recuperação foram verificadas. Os projetos permanecem congelados.

## Resultado

- Quatro worktrees antigas e 16 cópias auxiliares em MSW foram preservadas antes da remoção. As seis refs de branches antigas mantêm os mesmos commits; nenhuma integração antiga foi retomada.
- 24 diretórios ignorados de cache foram removidos dos dois studios. Fontes, locks, ferramentas, artefatos de build e evidências foram conservados.
- 100 caminhos de APK compartilham agora sua cópia CAS por hardlink NTFS somente leitura. Os 245 caminhos e 121 hashes continuam disponíveis; fontes vinculadas a gates/receipts mantêm identidade independente.
- Nove gates e sete identidades bloqueadas permanecem. Core e RPG Comando não foram alterados. Não houve QA dos jogos, build, integração antiga ou publicação de produto.
- Conteúdo bruto removido/compartilhado: 12.12 GiB; arquivo Git, novas cópias CAS e testes retidos: 4.72 GiB. Economia líquida estimada: 7.40 GiB, pelos bytes dos arquivos; alocação NTFS e pequenos logs não entram no cálculo.

## Evidência e recuperação

[record.json](record.json) contém os caminhos literais, SHA-256 dos manifestos e pastas retidas; [sources.json](sources.json) preserva as fontes documentais anteriores por blob Git e hash.

Arquivo externo: D:/MinigameStudio-backups/studio-archive/preservation-cleanup-20261005/.

1. Confira os hashes dos manifestos em record.json e o hash do bundle em worktrees-preserved.json.
2. Clone Minigame-Studio-before-cleanup.bundle em destino novo, selecionando a branch histórica desejada. Não faça reset/checkout amplo nos studios.
3. Para recuperar o snapshot físico, use a raiz selecionada e cada path relativo de worktrees-preserved.json: copie archive_path para um destino vazio, valide bytes e sha256 e preserve os arquivos únicos. Arquivos regeneráveis e junctions de dependências estão enumerados à parte; destinos compartilhados, locks e toolchains continuam disponíveis.
4. O teste isolado restaurou as seis branches, validou conectividade Git e copiou amostras grandes do CAS; todos os arquivos únicos do CAS passaram por SHA-256. Isto comprova preservação de bytes, sem declarar QA de produto.

Os diretórios restore-probe.git e restored-samples permanecem no arquivo externo: a revisão automática rejeitou sua remoção com a mensagem blocked by policy. Seus bytes estão descontados da economia líquida acima.

APKs: D:/MinigameStudio-backups/artifact-store/. Hardlinks somente leitura são preservação congelada; para uma edição futura autorizada, copie para destino novo, mantendo o CAS imutável.

Pastas de ferramentas, dependências compartilhadas, QA, receipts, pesquisa e scratch ambíguo foram mantidas conforme a lista literal. Novas limpezas ou retomadas exigem novo recorte de Fabio. Sincronização Git final e receipts são provas posteriores externas, separadas da publicação de produto.
