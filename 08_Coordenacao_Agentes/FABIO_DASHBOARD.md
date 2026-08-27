# Painel Fabio - Estudio

- Ultima atualizacao de produto: `2026-06-29`; politica Git atualizada em `2026-08-27`.
- Tipo: sintese humana para decisao rapida do Fabio.
- Visualizacao em navegador: `08_Coordenacao_Agentes/FABIO_DASHBOARD.html`.
- Nao e fonte tecnica de verdade.

## Como usar

Este painel existe para Fabio decidir foco sem navegar como agente.

Fontes vivas vencem este painel em caso de conflito:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `08_Coordenacao_Agentes/Estado_Atual.md`
3. `Projetos/<Projeto>/implementation/current-status.md`

## Leitura de 30 segundos

O Estudio tem tres frentes ativas ou retomaveis no curto prazo:

- `JogoDaCopa`: baseline publica 10D aprovada; a pergunta agora e escolher entre reducoes locais conservadoras ou nova melhoria de feel/polish.
- `DraxosMobile`: pacote tecnico/Web aprovado para carregar; a Arena core ainda precisa de prova humana antes de tuning, economia, PVP, conteudo ou expansao.
- `FpsPlayground`: Track 14I aprovada; proxima evolucao recomendada e `Multi-Arena Balance Baseline V1` antes de novas armas/buffs/mapas/tuning.

`draxos-roguelike-cardgame` esta preservado em pausa temporaria, com Design Lab Wave 01 pronto para selecao manual futura.

## Melhor acao por disponibilidade

| Se voce tiver... | Melhor acao |
|---|---|
| 5 minutos | Abrir este painel e escolher qual pergunta humana quer responder primeiro. |
| 15 minutos | Ler `Estado_Atual.md` e confirmar se o foco do dia e JogoDaCopa, DraxosMobile ou FpsPlayground. |
| 30-45 minutos com PC/editor | Testar ou decidir a proxima etapa do JogoDaCopa pos-10D. |
| 30-45 minutos com acesso ao Internal Alpha | Executar a prova humana da Arena em DraxosMobile seguindo `Projetos/draxos-mobile/docs/arena-pve-product-proof.md`. |
| Sessao tecnica curta | Abrir escopo para FpsPlayground `Multi-Arena Balance Baseline V1`. |
| Sem PC | Revisar decisao estrategica: qual frente merece energia depois da rodada atual. |

## Perguntas humanas abertas

| Projeto | Pergunta humana | O que destrava |
|---|---|---|
| JogoDaCopa | Apos Track 10D aprovada, vale continuar reducoes conservadoras ou abrir polish/feel? | Proxima track de gameplay/publicacao. |
| DraxosMobile | O roteiro Arena prova o core ou ainda mostra problema de UX/clareza? | Tuning/expansao somente depois do veredito. |
| FpsPlayground | Multi-arena atual produz leitura suficiente para balance baseline? | Arsenal, buffs, mapas, tuning ou bot intelligence. |
| Draxos Roguelike | Quais candidatos Wave 01 merecem promocao manual? | Promocao de conteudo e suporte real a mecanicas bloqueadas. |
| RPG Isometrico / RPG Turnos | Algum deles deve sair do arquivo historico agora? | Retomada explicita; por padrao, nao agir. |

## O que agentes podem fazer sem mudar produto

- Organizar documentacao e roteamento.
- Preparar planos e auditorias read-only.
- Criar handoffs claros para Codex.
- Rodar validadores locais/documentais.
- Sugerir proxima track, sem abrir implementacao automaticamente.

## O que nao fazer automaticamente

- Usar `pull`, force, tags, outras refs/remotos ou sincronização Git fora do runbook delegado.
- Publicar, subir pacote, mutar Cloudflare/Supabase ou deployar manifest.
- Trocar foco de portfolio.
- Deletar branches/worktrees antigas.
- Mover cards ou fechar historico sem aprovacao.
- Iniciar tuning, economia, PVP, conteudo ou expansao antes do gate humano correspondente.

## Links vivos

- `documentation-index.md`
- `Prioridades_Estudio.md`
- `Estado_Atual.md`
- `../Projetos/README.md`
- `../Projetos/JogoDaCopa/implementation/current-status.md`
- `../Projetos/draxos-mobile/implementation/current-status.md`
- `../Projetos/FpsPlayground/implementation/current-status.md`
- `../Projetos/draxos-roguelike-cardgame/implementation/current-status.md`
