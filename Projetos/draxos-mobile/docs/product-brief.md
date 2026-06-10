# DraxosMobile - Product Brief

- Ultima atualizacao: `2026-06-09`
- Status: `VIVO`

---

## Leitura Atual

DraxosMobile e um jogo mobile-first de progressao persistente construido sobre cinco modos oficiais:

- `Basebuilder`: Refugio/Base atuais.
- `Autobattler`: Arena PVE atual e futuro PVP async dentro do mesmo modo.
- `Openworld`: primeiro slice `forest`, com entrada direta player-facing `Bosque`.
- `Towerdefense`: planned/disabled e oculto ao player ate contrato proprio.
- `Cardgame`: planned/disabled e oculto ao player, sem relacao mecanica com `draxos-roguelike-cardgame`.

O projeto atual deve ser lido como uma base implementada para refinamento. Ele nao e produto final, nao e uma trilha de expansao de conteudo e nao e uma rodada de balanceamento.

A etapa operacional publicada e `Bosque Overlay Interactive Controls Authority v1`: release root `internal-alpha/v0-bosque-overlay-interactive-controls-authority-v1-20260609-d3be1fb`, evidencia `https://9461e4be.draxos-mobile-internal-alpha.pages.dev`, portal oficial `https://draxos-mobile-internal-alpha.pages.dev/`, Web direto `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, versao `0.0.21-alpha.0`, version code `21`, minimum supported version code `13`. O pacote mantem o Bosque vivo e visivel atras de Arena PVE, Refugio/Base, Loja, Social e Perfil em overlay, pausa input/coleta/movimento enquanto menus estao abertos, preserva retorno via shell/`Fechar`/`Voltar`/Esc sem rebootstrap e prova a interacao real no Web publicado por smoke de clique/tecla, incluindo Social typing/actions, Shop cancel/confirm e Arena retomar/abandonar. Bosque Overlay Menu Action Authority v1, Bosque Overlay Navigation Hotfix v1, Bosque Diegetic Launcher Foundation v1, Bosque Bootstrap Authority v1, Bosque Node Cooldown ACK v1, Arena PVE Bonus Visual v1 e todos os pacotes anteriores ficam preservados como historico.

A direcao viva de produto continua `PVE_ARENA_INITIAL_DIRECTION_APPROVED`: Arena PVE e o primeiro core de produto dentro do modo `Autobattler`. Bosque/Openworld e slice integrado de Internal Alpha para validar movimento, coleta, persistencia, cache e fronteira controlada com Arena/Basebuilder; nao e autorizacao para expansao ampla de mundo, economia, conteudo, armas/spells, PVP, visual final ou mutacoes remotas.

## Foco Atual

Playtest humano inicial do pacote anterior, Bosque Bootstrap Authority v1, foi reportado OK por Fabio em 2026-06-09: tudo testado ate aquele momento parecia funcionar. O pacote atual publicado agora precisa de playtest humano focado no overlay persistente: prompts/landmarks do Bosque, abertura de Arena/Base/Shop/Social/Profile, Social digitavel, Shop confirmavel, Arena retomar/abandonar e retorno via `Fechar`, `Voltar` e Esc sem rebootstrap. Bugs futuros voltam ao fluxo normal se aparecerem.

Nao abrir tuning amplo, PVP, economia, conteudo, novas armas/spells, visual final, expansao ampla de Openworld ou mutacoes remotas sem decisao propria. Se aparecer bug novo, tratar como bugfix estreito a partir do pacote atual.

O foco de fundacao anterior foi fechado: Foundation Closeout entregou account/save, ruleset registry, idempotencia v1, admin minimo, API versioning e mutacoes transacionais; Lab Track 16 Alignment atualizou Battle Lab/Progression Lab para pocoes, comportamento, crafting e `po_osso`; Foundation Final Polish, Hardening Platform V1 e Foundation Hardening V2 ficam como baselines tecnicas/historicas preservadas.

A decisao de produto seguinte e `docs/pve-arena-initial-direction.md`: o jogo deve comecar por Arena PVE, nao por PVP-first. O pacote contratual/data-driven inicial vive em `docs/pve-arena-v1.md` e promove os arquivos `data/definitions/pve_arenas.json`, `pve_arena_difficulties.json`, `pve_enemies.json`, `arena_buffs.json` e `arena_rewards.json` como fonte autorada para a proxima implementacao. O loop interno pos-login aceito continua como fundacao historica de app:

`Base -> coletar recursos -> evoluir base -> batalhar -> receber recompensas -> verificar base novamente`

First Session Clarity v1 e a baseline historica de clareza da primeira sessao. A leitura viva apos o main menu refactor, Technical Hardening, Bosque v3 UX/Feel, Arena PVE First Real Run + Update Recovery, Arena Duel Flow Hotfix, Arena PVE Season 1 Loop v1, Arena/Bosque Regression Hotfix, Bosque Sync Responsiveness v1, Bosque Offline-First Checkpoint v1, Bosque Durable Bau Mochila v1, Bosque Fogueira Potion Crafting v1, Bosque World Hub Domain Separation v1, Bosque Session Lifecycle & Durable Structures Hotfix v1, Bosque Persistence Rebase v1, Bosque Feel & Spawn Authority v1, Bosque Resume Exit Lifecycle v1, Bosque Node Cooldown ACK v1, Arena PVE Bonus Visual v1, Bosque Bootstrap Authority v1, Bosque Overlay Navigation Hotfix v1, Bosque Overlay Menu Action Authority v1 e Bosque Overlay Interactive Controls Authority v1 e que Refugio, Arena PVE/Preparacao, Resultado, Social, Loja e Bosque devem permanecer coerentes antes de abrir novo backend, schema, tuning, economia ou conteudo.

Ao abrir o pacote de Arena PVE inicial, devem ser avaliados juntos:

- leveling;
- upgrades;
- recompensas;
- poder de batalha;
- lista inicial de inimigos PVE;
- tamanho e dificuldade das arenas;
- buffs temporarios de stat;
- comportamento ajustavel entre lutas;
- limites de recompensa sem cooldown de combate;
- qualidade da resposta visual/tecnica em Android, PC e PC browser.

Contrato v1 fechado para proxima implementacao:

- tutorial de 1 duelo;
- primeiras arenas reais de 3 duelos;
- cap inicial de 6 duelos;
- primeira lista de inimigos/arquetipos PVE;
- buffs temporarios apenas de stat;
- recompensa inicial calibravel por primeira clear, conclusao, recorde, repeticao reduzida e limites diarios/semanais.

## O Que Existe Como Substancia/Mock

Armas, spells, nomes, tema, imagens, apresentacao atual de batalha, economia, Battle Pass, Diamante, loja, bots, rankings e valores de progressao existem para dar substancia ao jogo e impedir que o app pareca vazio.

Esses elementos nao devem ser tratados como decisao final de design nesta etapa. A Arena PVE inicial promove apenas a estrutura de early game e o tuning integrado necessario para que o jogador consiga vencer duelos, ganhar recursos, melhorar base/build e tentar dificuldade maior.

Terminologia implementada preservada como substancia/mock: Instrumento Ritual, Spell, Doutrina e Familiar.

Ordem recomendada agora:

1. Playtestar o pacote publicado `Bosque Overlay Interactive Controls Authority v1` em Web/APK, incluindo Social typing/actions, Shop cancel/confirm e Arena retomar/abandonar.
2. Tratar bugs futuros por bugfix estreito se aparecerem.
3. Retomar Arena PVE tutorial/primeiras arenas, labs e tuning apenas quando essa decisao existir.
4. Base/preparacao como suporte da Arena PVE.
5. PVP assincrono posterior, com bots como fallback transparente.
6. Social/competicao.
7. Armas, spells, economia fina, novos conteudos e visual final.

## Plataformas

| Plataforma | Papel atual |
|---|---|
| Android | Produto primario e principal referencia de UX |
| PC executavel | Canal de teste, conforto e fallback |
| PC browser | Canal rapido para review e handoff |
| iOS | Futuro possivel, sem compromisso atual |
| Mobile browser | Fora do escopo ate decisao explicita |

## Base Implementada

A base tecnica ja contem:

- Godot `4.6.2-stable`;
- Supabase Auth, Postgres, Edge Functions e Storage;
- email/senha e fluxo de conta alpha;
- saves `normal` e `progression_lab`;
- batalha server-authoritative com replay/log;
- preparacao de loadout e comportamento simples de habilidade/pocao;
- Base/Refugio, coleta, upgrades e recursos;
- social, competicao, loja e laboratorios em estado de prototipo;
- release manifest, build channel e runbooks de publicacao segura;
- validacao local por `validate_foundation.ps1`.

Behavior/potion/crafting esta registrado em `behavior-potion-crafting-v1.md` como base tecnica viva: Ossos inteiros, Po de Osso, Fogueira como estacao, tres pocoes simples, slot de pocao e comportamento simples de habilidade/pocao. Ele nao libera tuning, economia, novas pocoes ou comportamento avancado sem novo pacote explicito.

## Decisoes Que Permanecem Reais

| Area | Decisao |
|---|---|
| Produto | Base builder + Arena PVE inicial + PVP posterior + social basico |
| Arena PVE | Core inicial: tutorial de 1 luta, primeiras arenas de 3 lutas, dificuldade escalavel, loadout travado, buffs temporarios de stat, vida resetada por duelo e sem cooldown de combate |
| PVP | Modo posterior/competitivo; bots podem ser fallback/simulacao, nao fundacao escondida |
| Batalha | Servidor resolve; cliente apresenta log/replay |
| Backend | Supabase como ponte de alpha; Backend Proprio + Postgres como saida preferida se crescer |
| Autoridade | Recurso, recompensa, ranking, batalha e mutacoes importantes ficam no servidor |
| Plataforma | Android primeiro; PC/PC browser para teste e review |
| Conteudo | Deve ser substituivel/versionavel sem reescrever fundacao |

## Documentos Vivos

- `foundation-app-v0-audit.md` - bussola historica preservada da Foundation Audit aceita.
- `implementation/current-status.md` - snapshot vivo da etapa operacional, proximo passo e limites atuais.
- `pve-arena-initial-direction.md` - direcao viva do early game por Arena PVE.
- `pve-arena-v1.md` - contrato inicial de Arena PVE para dados, endpoints, schema e labs.
- `first-session-clarity-v1.md` - pacote publicado de clareza da primeira sessao.
- `product-vision.md` - visao longa local.
- `game-design-document.md` - referencia de implementacao e substancia/mock existente.
- `behavior-potion-crafting-v1.md` - estado vivo de pocoes, crafting inicial e comportamento simples.
- `design-pending.md` - pendencias vivas e ordem de decisao.
- `documentation-index.md` - classificacao de docs vivos, contratos, runbooks, historico e arquivo de design.
- `contracts/` - contratos tecnicos antes de migrations/codigo.
- `internal-alpha-v0.md` - runbook operacional da build fechada.
- `../../_conceitos/mobile-universe/gdd.md` - GDD historico completo, somente contexto.
