# DraxosMobile - Foundation Loop Audit

Status: VIVO
Atualizado em: 2026-05-28
Etapa atual: `FOUNDATION_AUDIT_ACTIVE`

## Proposito

Esta auditoria executa a primeira leitura pratica da Foundation Audit sobre o loop interno pos-login:

`Base -> coletar recursos -> evoluir base -> batalhar -> receber recompensas -> verificar base novamente`

O objetivo nao e rebalancear combate, economia, armas, spells, pass ou conteudo. O objetivo e entender se a fundacao implementada permite ao jogador executar o loop com clareza, poucos cliques, feedback bom e retorno natural para a base.

Leitura curta: a fundacao tecnica existe. O app ja tem Refugio, Base, coleta, evolucao, batalha server-authoritative, replay, resumo, recompensas e retorno ao Refugio. A lacuna atual esta na ergonomia do loop: a acao principal compete com muitos atalhos, a evolucao fica escondida em estados comuns, e o retorno pos-recompensa ainda nao conduz o jogador a verificar a base atualizada.

## Metodo

- Leitura dos presenters e flows do app shell: `modes/boot/boot.gd`, `modes/boot/surfaces/`, `modes/boot/flows/`.
- Leitura dos contratos de rota/acao: `modes/boot/ui/app_shell_route_contract.gd`, `modes/boot/ui/app_shell_action_contract.gd`.
- Leitura de testes client que cobrem Refugio, CTA contextual, Base, Shop e batalha.
- Smoke sem rede executado depois de import Godot da worktree: `tools/smoke_foundation_hardening.gd`.
- Smoke de surfaces com Supabase foi lido como referencia, mas nao executado nesta auditoria porque cria sessao/conta e toca backend.

## Resultado Executivo

| Area | Fundacao real implementada | Friccao atual | Lacuna para produto live |
| --- | --- | --- | --- |
| Entrada pos-login | `entry` e `refuge` existem; Refugio imersivo esconde chrome e vira home jogavel. | Entry ainda mistura login, save, dev tools/reset e pode atrasar a sensacao de "estou no jogo". | Depois do login, o usuario deve cair num estado jogavel com uma proxima acao obvia. |
| Refugio como centro | Refugio tem board, icones, popup contextual e CTA inferior. | Ha muitos destinos com peso parecido: Batalha, Preparacao, Refugio, Social, Competicao, Loja, Coletar, Energia, Perfil. | O loop principal precisa dominar a primeira decisao; social/loja/competicao devem ficar secundarios nesta etapa. |
| Coleta | Coleta existe por CTA contextual, icone rapido, popup de Refugio e tela Base. | Caminhos redundantes e confirmacao tornam uma acao rotineira mais pesada. | Coletar deve ser uma acao primaria curta, com feedback imediato e sem duvida de onde clicar depois. |
| Evolucao da base | Evolucao existe no Base presenter, no painel embutido do Refugio e na CTA quando `next_upgrade_ready`. | CTA de evoluir so aparece depois de log de batalha e coleta deixarem de ter prioridade; caso contrario exige abrir Refugio, selecionar estrutura e tocar evoluir. | Evoluir precisa ser visivel como parte natural do loop, mesmo quando existe historico de batalha ou coleta recente. |
| Batalha | Pedido de batalha, replay, skip, resumo e logs existem. | Batalha compete com outras entradas; se o jogador nao entende a CTA contextual, ele abre menus para achar "Pedir batalha". | Batalhar deve ser o proximo passo evidente quando base/coleta/evolucao nao pedem acao imediata. |
| Recompensas | Summary mostra resultado, recompensa, recursos e ranking; ha botao `Voltar ao Refugio`. | A recompensa encerra bem, mas o retorno nao explica "volte e confira sua base"; tambem nao ha refresh explicito da base como promessa de UX. | Pos-recompensa deve conduzir o jogador para a base/refugio atualizado, com confirmacao clara do ganho. |
| Verificar base novamente | `return_refuge` limpa estado de batalha e volta para o Refugio. | O retorno e tecnico, nao uma etapa de loop; pode cair no mesmo Refugio cheio de atalhos e com CTA capturada por log de batalha. | O fim da batalha deve reabrir o ciclo: mostrar base, recursos, coleta/evolucao possivel e proxima acao. |

## Mapa De Cliques Atual

| Etapa | Melhor caminho atual | Caminho alternativo comum | Observacao |
| --- | --- | --- | --- |
| Coletar | CTA inferior `Coletar` -> confirmar. | Icone `Coletar` -> popup -> `Coletar agora` -> confirmar. | Bom quando a CTA aparece; pesado quando o jogador usa popup. |
| Evoluir | CTA inferior `Evoluir` -> confirmar. | Icone `Refugio` -> popup -> escolher estrutura -> `Evoluir <predio>` -> confirmar. | A CTA so aparece quando nao ha log de batalha e nao ha coleta pronta. |
| Batalhar | CTA inferior `Batalhar`. | Icone `Batalha` -> popup -> `Pedir batalha`. | Bom como fallback, mas nao deve competir com destinos secundarios. |
| Receber recompensa | Replay termina -> `battle_summary` mostra recompensa. | Botao `Pular` acelera replay; logs podem ser abertos. | A apresentacao existe; nao e prioridade refazer visual agora. |
| Voltar para base | `Voltar ao Refugio`. | `Ver logs da batalha` -> `Voltar ao Resultado` -> `Voltar ao Refugio`. | Retorna tecnicamente, mas nao garante uma leitura fresca da base como etapa de loop. |

## Achados Principais

### P0 - O loop existe, mas a proxima acao nao e soberana

O Refugio esta tentando ser home, menu, mapa, colecao de atalhos e painel de progresso ao mesmo tempo. Para Foundation V0, a tela pos-login precisa responder primeiro: "qual e o proximo clique do loop?". Hoje essa resposta depende de estado, leitura de icones e descoberta de popups.

Recomendacao: criar um passe de UX focado em uma trilha primaria de loop dentro do Refugio. A CTA contextual pode ser mantida, mas precisa virar a fonte principal de verdade visual, com estados claros: coletar, evoluir, batalhar, ver recompensa, verificar base.

### P0 - A CTA contextual pode ficar capturada pelo ultimo log de batalha

`_refuge_context_cta_data` prioriza `SessionStore.has_battle_log()` antes de coleta, evolucao e batalha. Isso e coerente para nao perder recompensa, mas se o log persistir como "resultado recente", o usuario pode ver `Ver resultado` quando a proxima acao desejada do loop ja deveria ser coletar, evoluir ou batalhar de novo.

Recomendacao: no proximo passe, separar "resultado pendente de leitura" de "historico ja visto". Depois que o resumo for visto e o jogador voltar ao Refugio, a CTA deve conduzir para base/coleta/evolucao/batalha, nao para um log antigo.

### P0 - Evoluir base fica escondido em estados normais

Evoluir e parte central do loop, mas so vira CTA primaria quando nao existe log de batalha e nao existe coleta pronta. Nos demais casos, depende do jogador abrir o menu de Refugio, entender o mapa de estruturas, selecionar predio e acionar evolucao. Esse caminho funciona como UI tecnica, mas ainda nao como loop de V0.

Recomendacao: promover "evolucao pronta" para sinal persistente no Refugio, mesmo quando outra acao esta mais urgente. A CTA primaria pode continuar unica, mas o estado da base precisa mostrar claramente que existe evolucao esperando.

### P1 - Coleta tem caminhos demais e confirmacao demais

Coletar existe em varios lugares, o que prova que o dominio esta implementado. Para UX, porem, isso cria ruido: a mesma acao aparece como CTA, icone, popup e botao de Base. Alem disso, coleta rotineira pede confirmacao.

Recomendacao: tratar coleta como acao rotineira de baixa friccao. Confirmacao deve ficar para gastar recurso, iniciar evolucao ou acoes irreversiveis; coleta pode confirmar por feedback pos-acao.

### P1 - Batalha encerra bem, mas nao reabre o ciclo com intencao

O resumo de batalha mostra recompensa e tem `Voltar ao Refugio`. O contrato tecnico esta correto: `return_refuge` limpa estado de replay e volta para a camada imersiva. A experiencia, porem, nao diz "voce ganhou X; veja como isso muda sua base". O jogador volta para um hub generico.

Recomendacao: depois de recompensa, o botao principal deve comunicar retorno ao ciclo, por exemplo "Voltar e verificar base". No retorno, o Refugio deve destacar recursos recebidos e a proxima acao de base.

### P1 - Base tem duas faces conceituais

Existe a Base como rota de app chrome (`base_management`) e existe a Base embutida no popup do Refugio. Tecnicamente isso e util, mas para o jogador pode parecer que Refugio e Base sao coisas diferentes quando o loop quer que sejam o centro do mesmo ciclo.

Recomendacao: no V0, escolher uma leitura dominante: Refugio e a base jogavel. A rota full Base pode continuar como detalhe/gerenciamento, mas o loop principal deve acontecer no Refugio.

### P2 - Recompensa diaria/Loja compete semanticamente com recompensa de batalha

O app ja tem `claim_reward:daily_collect_base` na Loja, alem das recompensas de batalha. Como mock/substancia isso ajuda o app a nao parecer vazio. Para o loop atual, porem, "receber recompensas" deve significar primeiro recompensa da batalha e impacto na base.

Recomendacao: manter Loja/recompensa diaria fora da trilha primaria ate o loop Base/Batalha estar claro.

### P2 - Falta smoke de UX do loop

Os testes atuais cobrem presenca de icones, prioridade da CTA, renderizacao de Base/Shop e retorno de batalha ao Refugio. Eles nao cobrem uma sequencia de UX Foundation: entrar no Refugio, coletar, ver evolucao, batalhar, ver recompensa e retornar para base com proxima acao correta.

Recomendacao: criar um smoke sem rede, com fixtures de `SessionStore`, para validar a ordem e prioridade visual do loop antes de implementar novos conteudos.

## Melhor Proximo Pacote

Nome sugerido: `Foundation Loop UX Pass`.

Escopo recomendado:

1. Fazer do Refugio a tela operacional dominante do loop.
2. Transformar a CTA inferior em um "proximo passo" confiavel, com estado lido/visto para resultado de batalha.
3. Dar sinal persistente para coleta pronta e evolucao pronta sem exigir popup.
4. Reduzir friccao de coleta; manter confirmacao para evolucao/gasto.
5. Alterar o retorno da batalha para reconectar recompensa -> recursos -> base -> proxima acao.
6. Criar smoke sem rede para o loop UX, usando fixtures e sem tocar Supabase.

Fora desse pacote:

- Social novo.
- Direcao visual final.
- Apresentacao final da batalha.
- Armas, spells, economia, balanceamento e grande volume de conteudo.
- Schema/backend novo, salvo se uma falha objetiva do loop exigir contrato minimo.

## Criterios De Aceite Para O Passe Seguinte

- Depois do login/refugio, o jogador sempre ve uma acao primaria do loop sem abrir menu.
- Coletar exige no maximo um toque de decisao e retorna feedback imediato.
- Evoluir base fica visivel como oportunidade mesmo quando nao e a CTA primaria.
- Batalhar vira o proximo passo claro quando base/coleta/evolucao nao pedem acao.
- O resumo de batalha mostra recompensa e conduz explicitamente para verificar a base.
- Ao voltar da batalha, a CTA nao fica presa em resultado antigo ja visto.
- Social, loja, competicao e preparacao continuam acessiveis, mas secundarios ao loop.
- Existe smoke sem rede para a sequencia de loop e prioridades de CTA.

## Evidencias

- `modes/boot/surfaces/hub_surface_presenter.gd`: Refugio imersivo, icones, popup, CTA contextual e prioridade `Ver resultado -> Coletar -> Evoluir -> Batalhar`.
- `modes/boot/surfaces/base_surface_presenter.gd`: Base full e embutida, coleta, mapa de estruturas, detalhe e evolucao.
- `modes/boot/flows/surface_action_flow.gd`: fluxos server-backed de `show_base`, `collect_base` e `upgrade_base_structure`.
- `modes/boot/flows/battle_lifecycle_flow.gd`: pedido de batalha, replay, summary e retorno ao Refugio.
- `modes/boot/surfaces/battle_replay_presenter.gd`: resumo de batalha, recompensa, recursos, ranking, logs e `Voltar ao Refugio`.
- `tests/client/test_boot_mobile_ui.gd`: cobertura de icones do Refugio, CTA contextual, Base, Shop e retorno da batalha.
- `tools/smoke_foundation_hardening.gd`: smoke sem rede de rotas, UI mobile, session/save e battle mode; passou em 2026-05-28 apos `--import` da worktree.
