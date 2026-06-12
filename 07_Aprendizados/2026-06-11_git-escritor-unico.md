# Aprendizado: Escritor Unico No .git

- Data: `2026-06-11`
- Area: operacao multiagente / versionamento

## Problema

Durante a configuracao do remote, tres falhas atingiram o repositorio principal: `index.lock` orfao, `.git/index` corrompido (`bad signature 0x00000000`) e `.git/config` ilegivel. Causa comum: mais de um processo escrevendo no mesmo `.git` ao mesmo tempo (IDE com autofetch, agente em sessao remota, cliente git local), agravada por uma camada de filesystem que entrega reescritas de arquivos com o tamanho antigo (conteudo completo + bytes NUL no final, ou truncado quando o arquivo cresceu).

## Sinais De Alerta

- `fatal: Unable to create .git/index.lock: File exists` sem nenhum git rodando.
- `error: bad signature 0x00000000` / `fatal: index file corrupt`.
- `fatal: bad config line 1` logo apos uma operacao de remote.
- Janela do Git Credential Manager reaparecendo em loop - combinada com URL errada de remote, o acesso negado e reinterpretado como credencial invalida.

## Regra

- Um escritor por vez no `.git` da arvore principal: enquanto um agente executa task que commita, nao usar GitHub Desktop/IDE para commit, stage ou discard nessa arvore. O Desktop atua como painel: revisar diffs, fetch e push.
- Agentes em ambiente remoto/sandbox devem verificar integridade apos commit (blobs sem bytes NUL) e preferir indice externo (`GIT_INDEX_FILE` fora da arvore montada) quando o filesystem for suspeito.
- Reparo padrao: remover `index.lock` orfao; se o index corromper, `rm .git/index && git reset` reconstroi a partir do HEAD sem tocar nos arquivos de trabalho.

## Adendo: Falso Sujo Em Sessao Remota

O mesmo filesystem tambem mente na LEITURA: arquivos que cresceram em commits recentes do host podem aparecer truncados na visao do agente remoto, fazendo `git status` listar modificacoes que nao existem (conteudo igual a um prefixo exato do blob do HEAD, as vezes cortado no meio de uma palavra). Antes de concluir que um handoff ficou sujo ou de commitar qualquer coisa nesse estado, confirme com `cmp <(git show HEAD:arquivo | head -c TAMANHO_TRABALHO) arquivo`: prefixo exato = ilusao da montagem, arvore real limpa. Nunca faca `git add` de arquivos nesse estado.

## Beneficio

Evita perda de staging, commits com blobs corrompidos e loops de autenticacao que mascaram erro de configuracao.
