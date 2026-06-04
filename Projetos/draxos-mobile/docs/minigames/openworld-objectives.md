# Openworld Objectives

- Status: `VIVO`
- Data: `2026-06-04`
- Mode id: `openworld`
- Slice atual: `forest`
- Documento tecnico principal: `docs/minigames/openworld.md`
- Decision pack: `docs/minigames/openworld-decision-pack.md`
- Package framing: `Bosque Mecanico Basico v2`

Este documento define a intencao de produto do Openworld Bosque dentro do
DraxosMobile. Ele nao autoriza codigo, backend, economia, recompensas novas,
publicacao remota ou expansao de gameplay por si so.

## Regra Central

O Openworld atual e alpha interno. O objetivo e aprender, em escala pequena,
se um espaco navegavel melhora a rotina do DraxosMobile sem substituir a Arena
PVE, sem abrir campanha e sem transformar o jogo em mundo aberto completo.

Bosque Mecanico Basico v2 e um minigame livre e relaxante. O jogador entra,
coleta, deposita, crafta, constroi pequenas estruturas, volta quando quiser e
encerra visita quando quiser. Orientacao e ajuda, nao meta obrigatoria.

## Bosque Mecanico Basico v2

Papel do slice:

- mode_id: `openworld`;
- slice_id: `forest`;
- player-facing entry: `Bosque`;
- funcao: minigame fullscreen de coleta, deposito, craft e construcao leve;
- estado: pacote documental para orientar futuras lanes de implementacao.

Contratos de experiencia:

- sem pressa, sem falha e sem inimigos;
- coleta por proximidade/parada perto de recursos;
- bolso como inventario temporario da visita;
- bau como armazenamento da visita/save para craft;
- craft de `Bolsa Simples I` e `Fogueira Estavel I`;
- `Fogueira Estavel I` como estrutura permanente apos craft;
- entrada e saida livres, sem conclusao exigida.

## Orientacao, Nao Objetivo Obrigatorio

A orientacao v2 e um banner discreto de seis passos:

1. Explore o Bosque sem pressa.
2. Pare perto de um recurso para coletar.
3. Seu bolso guarda o que voce encontra. Quando pesar, volte ao bau.
4. Perto do bau, use Depositar para guardar tudo.
5. Com materiais no bau, crie melhorias e pequenas estruturas.
6. Quando quiser, encerre a visita e volte depois.

Regras:

- o jogador pode ignorar, fechar ou reabrir a orientacao;
- progresso/dispensa persistem no save normal server-side;
- `Sessao` deve permitir reabrir o banner;
- nenhuma etapa bloqueia movimento, coleta, deposito, craft, `Voltar` ou
  `Encerrar visita`;
- a orientacao nao concede recompensa propria.

## Objetivos De Validacao Mecanica

Bosque v2 deve provar:

- movimento, camera, colisao, bordas e controles touch/PC/Web;
- coleta de recursos fixos sem bloquear movimento;
- bolso, peso, bau, deposito e retomada;
- craft simples a partir do bau;
- uma estrutura pequena persistente e bloqueante no mundo;
- sessao online retomavel, eventos revisionados e ACK sem rollback visual;
- saida livre por `Voltar` e finalizacao explicita por `Encerrar visita`.

A pergunta desta etapa e: "o minigame basico esta claro, previsivel e confiavel?"
Nao e: "o Openworld completo ja esta divertido o suficiente?"

## Recursos E Crafts Contratados

O ruleset v2 deve conter recursos fixos suficientes para `Bolsa Simples I` e
`Fogueira Estavel I` numa unica visita, com pequena folga.

Minimo combinado:

- `galho`: 6;
- `folha`: 3;
- `resina`: 1;
- `folha_seca`: 2;
- `pedra_pequena`: 1.

Folga esperada:

- pelo menos 1 `galho` adicional;
- pelo menos 1 `folha` adicional;
- pelo menos 1 recurso leve adicional para descoberta.

Essa folga e didatica. Ela nao cria economia ampla, farm, reward novo,
respawn ou geracao procedural.

## Estrutura Permanente

`Fogueira Estavel I` deve aparecer apos craft:

- perto de `x=305 y=330`;
- como objeto procedural permanente da sessao/save;
- com colisao bloqueante pequena;
- sem NPC, quest, combate, loot, reward novo ou sistema economico proprio;
- registrada no resumo leve de finalizacao quando construida.

## Saida Livre

- `Voltar`: preserva/pausa a visita em andamento e retorna ao shell/refugio.
- `Encerrar visita`: finaliza a visita e mostra resumo leve.
- Nao existe requisito de coletar tudo, craftar tudo ou completar orientacao.
- Retomar depois deve continuar do estado server-side normal quando houver
  sessao/snapshot valido.

## Candidatos Futuros Nao Aprovados

O Openworld completo segue fora de escopo. Ainda assim, o Bosque pode servir
como evidencia para decidir se o DraxosMobile fica melhor como jogo de menus,
como jogo com um mundo navegavel ou como mistura controlada dos dois.

Essas ideias nao sao backlog automatico. Elas so podem virar trabalho depois de
decisao propria registrada em `docs/design-pending.md` e no decision pack.

### Etapa 2 - Menu No Mundo

Candidato experimental: expandir o Bosque com uma casa/altar do mago, arredores
e uma pequena cidade para testar funcoes hoje resolvidas por menus como lugares
fisicos. A pergunta nao e "criar uma cidade", e sim descobrir quais funcoes
ganham clareza quando viram espaco navegavel e quais continuam melhores como UI
direta.

Essa etapa nao aprova combate, NPCs com questline, mapa amplo, economia nova,
PVP, social completo ou producao pesada de assets.

### Etapa 3 - Conflito Minimo

Candidato experimental posterior: uma area pequena com monstros, poucos NPCs e
um loop minimo de matar monstros, coletar recursos, cumprir tarefas simples e
voltar. Essa etapa so existe para testar se conflito leve combina com
DraxosMobile sem substituir Arena PVE, sem abrir campanha e sem criar mundo
continuo.

Antes dela, o projeto precisa decidir qual area pode ter risco, quais recursos
podem sair do modo, como quests se conectam com conta/save, como combate no
mundo se separa do Autobattler/Arena e qual evidencia justifica sair do Bosque
relaxante.

## Fora Do Escopo Atual

- inimigos;
- NPCs;
- quests;
- combate;
- cidade;
- full open world;
- mapa novo amplo;
- respawn ou procedural generation;
- economia ampla;
- reward novo;
- remote publication;
- migracoes, Edge Functions, Godot client, ruleset JSON ou testes nesta lane.

## Como Avancar

Uma futura lane de implementacao deve atualizar ruleset/runtime/testes a partir
dos contratos em `docs/minigames/openworld.md` e deste documento, mantendo o
escopo pequeno e reversivel.

Antes de expandir alem do Bosque relaxante, o projeto precisa de nova decisao
registrada em `docs/design-pending.md` ou em decision pack proprio.
