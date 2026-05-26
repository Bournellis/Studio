# DraxosMobile - Internal Alpha v0 Design Lock

- Ultima atualizacao: `2026-05-26`
- Track: `T03-P01 - Design Lock Da Build Interna`
- Status: `LOCKED`

Este documento registra as decisoes de uso, layout e comportamento da Internal Alpha v0. O objetivo e fazer o app parecer uma simulacao funcional de jogo real, nao uma tela puramente de desenvolvimento, mesmo ainda sem arte final.

## Intencao De Uso

Loop principal do jogador:

1. Entrar no app.
2. Coletar recompensas e producao acumuladas.
3. Batalhar para ganhar recompensas diarias, XP e progresso.
4. Ver recompensas.
5. Checar upgrades, claims e recompensas novas.
6. Evoluir o que for possivel.
7. Batalhar novamente.

Loja e Social existem em paralelo ao loop principal. A loja deve incentivar uma entrada diaria para um pequeno claim, mas a build de teste tambem tera claims/redeems grandes para acelerar a experiencia quando o testador quiser simular momentos mais avancados.

O jogo deve usar um hibrido de:

- `idle/manager`: foco em coleta, timers, upgrades, recursos e eficiencia de rotina.
- `hub de RPG`: foco em personagem, build, batalha, progressao e leitura de fantasia.

Decisao: para a Internal Alpha v0, priorizar o loop manager como ergonomia e o hub de RPG como enquadramento. A tela deve guiar o jogador para `batalhar > coletar > evoluir`, mas sempre lembrar que ele esta desenvolvendo um Draxos com build propria.

## Fluxo Inicial

Fluxo apos update/login:

1. Tela inicial.
2. Escolha: `Continuar`, `Progression Lab`, `Configuracoes`.
3. `Continuar` abre o app comum com save `normal`.
4. `Progression Lab` abre o save `progression_lab`.
5. `Configuracoes` concentra logout, visibilidade de tooltips, reset de saves e informacoes da build.

Ferramentas de dev/internal ficam disponiveis em todas as plataformas da Internal Alpha v0, mas precisam estar visualmente separadas do app comum e protegidas por flag/permissao alpha.

## Layout Por Plataforma

Android:

- Orientacao alvo: paisagem.
- Batalha ocupa quase a tela inteira.
- Barra inferior com navegacao principal.
- Topo fixo com recursos, poder, nivel e save ativo.
- Layout em painel unico por vez, com telas rolaveis quando necessario.
- Tooltips por botao `?`.

PC/Web:

- Layout amplo, usando melhor a largura disponivel.
- Batalha ocupa quase a tela inteira.
- Topo fixo com recursos, poder, nivel e save ativo.
- Barra inferior pode permanecer para consistencia, mas telas internas podem usar paineis lado a lado.
- Base pode mostrar imagem de fundo/area clicavel e painel lateral de detalhes.
- Tooltips por hover e tambem por `?` quando o elemento for importante.

Regras responsivas:

- Nenhum texto importante pode depender de hover exclusivo.
- Conteudo longo deve rolar dentro da tela.
- Botoes de acao primaria devem ficar proximos do conteudo afetado.
- Modais perigosos devem usar confirmacao clara e botao visualmente diferente.

## Navegacao E HUD

Abas principais sempre visiveis no app comum:

- `Refugio`
- `Batalha`
- `Base`
- `Social`
- `Competicao`
- `Loja`

HUD superior sempre visivel:

- username;
- save ativo;
- level;
- poder;
- recursos principais;
- estado de conexao/update quando relevante.

Recomendacao aplicada para configuracoes:

- `Configuracoes` fica na tela inicial e em um botao discreto no topo do app.
- `Logout`, `trocar save`, `resetar save`, `versao/update` e `mostrar/esconder dicas` ficam dentro de Configuracoes.
- Reset de save usa modal com botao perigoso, sem exigir digitar texto.

## Tooltips E Ajuda

Tooltips sao parte essencial da build porque o segundo testador nao conhece o projeto.

Regras:

- Android usa botoes `?` inicialmente.
- PC/Web usam hover e `?` para elementos importantes.
- O usuario pode esconder botoes `?` nas configuracoes.
- Tooltips devem existir em quase tudo que tenha regra, recurso, timer, status, efeito ou decisao.
- Tooltips nao devem floodar a tela; cada tooltip deve ser curto e direto.
- Quando relevante, incluir informacao tecnica util para o jogador.

Formato recomendado:

```text
Nome
O que e: uma frase curta.
Como funciona: regra principal.
Importa porque: impacto pratico.
```

Glossario obrigatorio:

- Poder
- Energia
- Almas
- Sangue
- Cristais
- Ossos
- Diamante
- Instrumento Ritual
- Spell
- Doutrina
- Familiar
- Summon
- Barreira
- Cooldown
- Dano ao longo do tempo
- Status mental/corporal/elemental/Morte
- Save Normal
- Progression Lab

## Conta E Saves

Cadastro/login:

- email;
- senha;
- username;
- convite/flag alpha.

Tela inicial escolhe entre:

- `Continuar`: save `normal`;
- `Progression Lab`: save `progression_lab`.

Save `progression_lab`:

- precisa ter faixa visual permanente;
- usa a mesma conta e o mesmo social;
- fica fora da competicao;
- nao pontua score/ranking;
- pode usar loja;
- pode batalhar e evoluir dentro do proprio save lab;
- nao altera o save `normal`.

Reset:

- reset separado para `normal`;
- reset separado para `progression_lab`;
- modal com botao perigoso basta.

## Base

Predios da Internal Alpha v0:

- Altar das Almas;
- Nucleo de Energia;
- Pocos de Sangue;
- Minas de Cristal;
- Estrutura de Stats;
- Ossario.

Apresentacao:

- A Base deve funcionar como uma imagem/fundo com icones ou placeholders clicaveis.
- Cada predio clicavel abre uma tela/painel proprio.
- A tela de predio mostra level, producao/beneficio, custo do proximo upgrade, tempo, status da fila, tooltip e historico minimo se existir.
- Tempos de construcao sao reais.
- Nao existe `Coletar tudo` nesta versao.

## Refugio E Personagem

Personagem/build fica dentro do Refugio.

O jogador deve poder:

- ver Instrumento Ritual;
- trocar Instrumento quando houver opcoes;
- ver/equipar spells;
- ver/equipar Doutrina;
- ver/equipar Familiar;
- consultar poder total;
- abrir tooltip de composicao detalhada do poder.

Mesmo quando uma troca ainda nao estiver disponivel por conteudo, a tela deve mostrar o slot e explicar o que desbloqueia ou falta.

## Batalha

Antes da batalha:

- mostrar preview rapido dos dois jogadores;
- mostrar instrumento, spells, doutrina, familiar e poder principal.

Durante o replay:

- batalha ocupa quase a tela inteira;
- controles: pausar, pular, velocidade e timeline;
- tooltips para personagem, spell, buff/debuff, dano, cooldown e summon;
- log textual fica escondido em aba ou expansor.

Depois da batalha:

- mostrar vencedor/derrota;
- recompensas;
- XP;
- pontos de ranking quando aplicavel;
- eventos principais.

O cliente continua apenas apresentando `battle_log_v1`; nenhum resultado e calculado no cliente.

## Social

Social pertence a conta inteira, nao ao save.

Internal Alpha v0 inclui:

- amigos;
- chat privado/direct;
- guilda;
- chat de guilda.

Moderacao:

- apenas rate limit controlado nesta versao;
- sem bloquear/denunciar nesta build, salvo necessidade tecnica simples.

Progression Lab:

- usa o mesmo social da conta;
- nao pontua competicao.
- jogadores usando o save `progression_lab` aparecem no social/chat com marcador vermelho `lab`.

Identificador social:

- amigos sao adicionados por username.
- senha nunca deve ser usada como identificador social.

## Competicao

Leaderboard:

- bots nao aparecem.
- top 10 visivel.
- se o jogador estiver fora do top 10, mostrar tambem a posicao dele.

Pontuacao:

- toda batalha normal altera pontos.
- save `progression_lab` nao pontua.
- bots podem existir para matchmaking, mas nao aparecem na leaderboard.

## Loja

Loja funciona nos dois saves.

Redeems alpha:

- pequeno;
- medio;
- grande;
- premium.

Moeda:

- todos os redeems entregam apenas Diamante.
- nao existe `alpha_points` na Internal Alpha v0.

Frequencia:

- cada pacote pode ser resgatado 1 vez por dia por save.
- reset diario acontece a meia-noite no horario `America/Sao_Paulo`.

Uso:

- o jogador usa Diamante para comprar recursos e facilidades na loja.
- Premium, Battle Pass, fila dupla e outras facilidades devem estar disponiveis para compra com Diamante.
- o redeem `premium` deve entregar Diamante suficiente para comprar todos os itens premium/conveniencia da loja alpha daquele build, usando Battle Pass e fila dupla como referencia minima.
- Nao precisa exibir aviso de pagamento real, desde que nao exista gateway real.

Regra de valores:

- `pequeno`, `medio` e `grande` sao aceleradores diarios graduais.
- `premium` e calculado a partir do custo total dos itens premium/conveniencia disponiveis no catalogo da loja do build.
- valores numericos finais vivem no catalogo/seed da loja e podem ser rebalanceados sem reabrir o design lock, desde que mantenham as regras acima.

## Updates

Versao inicial:

- `internal_alpha_v0`.

Politica:

- update obrigatorio bloqueia login.
- Web mostra aviso de update.
- Android e PC mostram link de download dentro do app.
- update que quebra save pode resetar automaticamente no alpha interno.

## Follow-Ups Ainda Necessarios

Nenhum bloqueador de design para T03-P01.

Valores numericos dos redeems e precos da loja entram como dados calibraveis de implementacao, seguindo as regras deste documento.
