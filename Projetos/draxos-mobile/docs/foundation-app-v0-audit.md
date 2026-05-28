# DraxosMobile - Foundation App V0 Audit

Status: VIVO
Atualizado em: 2026-05-28
Etapa atual: `FOUNDATION_AUDIT_ACTIVE`

## Proposito

Este documento registra a leitura atual do projeto como uma fundacao de produto, nao como uma lista de features finais. Ele separa, de forma deliberadamente dura, o que ja deve ser tratado como fundacao real, o que hoje existe como mock para sentir o produto, e a lacuna ate um jogo live robusto.

O objetivo imediato nao e abrir o jogo ao publico. A etapa atual e descobrir o jogo com o fundador e um circulo muito proximo de possiveis colaboradores, usando um prototipo agradavel o suficiente para pensar melhor o produto real.

Esta auditoria tambem e a proxima etapa operacional. Antes de implementar mais UX, social, visual, batalha, armas, spells ou economia, os documentos vivos precisam explicar corretamente a situacao real do projeto.

## Enquadramento Atual

Etapa atual: `FOUNDATION_AUDIT_ACTIVE`

Leitura correta: o projeto atual e uma base implementada para refinamento. Ele nao e produto final, nao e uma trilha de expansao de conteudo e nao e uma rodada de balanceamento.

Foco imediato da Foundation Audit:

`Base -> coletar recursos -> evoluir base -> batalhar -> receber recompensas -> verificar base novamente`

O problema a auditar nao e se existe conteudo suficiente. O conteudo atual ja existe para dar substancia ao jogo e impedir que o app pareca vazio. O problema atual e como, onde e com quantas etapas o usuario clica para executar o loop interno pos-login.

Nucleo que nao deve mudar:

- Base builder.
- Batalha automatica / autobattler.
- Social basico.
- Estrutura futura para minigames e evolucao por seasons.

O que deve ser tratado como mock nesta etapa:

- Tema especifico de duelo de magos.
- Spells, nomes, imagens, textos de flavor e apresentacao atual.
- Balanceamento, numeros de combate, economia e ritmo.
- Conteudo premium, pass, rankings e progresso como oferta final.
- Visual final, identidade final, assets finais e fantasia definitiva do jogo.
- Apresentacao final da batalha.

O que precisa ser real desde cedo:

- App com loop claro, responsivo e confiavel.
- Backend server-authoritative, auditavel e preparado para evoluir.
- Contratos de dados que nao bloqueiem seasons, minigames, social e migracoes.
- Separacao limpa entre fundacao de produto e conteudo/tema substituivel.
- Documentacao suficiente para um time pequeno conseguir discutir design sem quebrar a base tecnica.

## Regras De Decisao

1. Se algo afeta conta, save, inventario, recursos, batalha resolvida no servidor, base, social, atualizacao, observabilidade ou operacao live, trate como fundacao real.
2. Se algo e nome, arte, tema, spell, texto, numero de balanceamento, reward temporario ou fantasia de apresentacao, trate como mock atual.
3. Se algo parece necessario para futuro minigame, registre contrato e fronteira; nao implemente minigame por ansiedade.
4. Se algo melhora a capacidade do usuario entender o loop, o feedback visual, o estado do app ou a confianca na resposta tecnica, ele pode ser prioridade mesmo sendo prototipo.
5. Antes de produzir muito conteudo, garantir que o app e o backend aceitam trocar conteudo sem reescrever fundacao.
6. A ordem de discussao/execucao apos esta auditoria e: loop interno, social, visual geral, apresentacao da batalha, depois armas/spells/economia.

## Auditoria Dura

| Area | Fundacao real | Mock atual | Lacuna para produto live |
| --- | --- | --- | --- |
| Estado do produto | O projeto deve ser lido como Foundation Audit ativa sobre uma base implementada: base builder + autobattler + social basico, com futuro de minigames. | O historico ainda mistura alpha, slice jogavel, tema de magos, pass, guilda, rankings e features como se fossem promessa de produto. | Atualizar documentos vivos para separar descoberta interna, prototipo de design e readiness live. |
| Loop do usuario | App precisa ensinar rapidamente: entrar, ver base, coletar recursos, evoluir base, batalhar, receber recompensa e verificar base novamente. | Telas e fluxos atuais dao cor ao conceito, mas a quantidade de etapas, posicao de icones e apresentacao atrapalham a experiencia. | Auditar a ergonomia real de cliques, estados, feedback, loading, erro, recompensa e retorno para base. |
| App shell e navegacao | Godot client com autoloads, presenters e modularizacao ja forma base de aplicacao. | Layout, tema visual, nomes de secoes e composicao ainda sao casca temporaria. | Endurecer padrao de navegacao, estado global, loading, falhas de rede, modo offline/recuperacao, responsividade e consistencia mobile/PC/web. |
| Conta e identidade | Email/password, guest/upsert e base de auth ja apontam para conta real. | Nomes, perfis, avatares e identidade social atual sao placeholders. | Consolidar modelo final de account/profile, migracao guest, recuperacao, ban/suspensao, privacidade e suporte. |
| Modelo de save | Existencia de saves e tipos como `normal`/`progression_lab` ajuda a separar laboratorio de jogo principal. | O proprio modelo ainda funciona como atalho de prototipo em partes, incluindo dados de laboratorio e progresso experimental. | Evoluir para contrato robusto de `account_profiles` + `game_saves`, migracoes, snapshots, rollback, ambientes e compatibilidade com seasons. |
| Backend/API | Supabase Edge Functions e RPCs ja sustentam operacoes server-authoritative. | Alguns endpoints e fluxos ainda refletem necessidades de demo, labs e apresentacao atual. | Definir fronteiras estaveis por dominio, versionamento de API, contratos de erro, idempotencia uniforme, testes de integracao e plano de saida para backend proprio quando necessario. |
| Dados economicos | Ledger, recursos, recompensas e idempotencia ja sao fundacao importante. | Valores, moedas, precos, pass, recompensas e pacing sao mock de experiencia. | Formalizar economia live: fontes/sinks, auditoria, conciliacao, operacoes administrativas, protecao contra duplicacao e migracoes de balanceamento. |
| Base builder | Base/refugio, estruturas, upgrade/coleta e comportamento de construcao pertencem ao nucleo real. | Visual, nomes de predios, custos, output e fantasia de cada estrutura sao temporarios. | Separar contrato de estrutura de apresentacao; preparar novas construcoes, seasons, desbloqueios, fila/tempo se adotado, coleta segura e impacto em outros modos. |
| Autobattler | Batalha automatica server-authoritative e log/replay sao parte real do produto. | Magos, fatalities, spells, armas, passivas, bots e tuning sao linguagem de mock para sentir o duelo. | Garantir determinismo, replay confiavel, explainability para o jogador, anti-cheat, simulacao em escala, fixtures, versionamento de regras e troca futura de tema sem quebrar saves. |
| Minigames | O produto precisa nascer com espaco para minigames futuros. | Minigames futuros existem mais como intencao e referencias do que como contratos tecnicos claros. | Criar registro de minigames e contrato de integracao: entrada, custo, recompensa, progressao compartilhada, progressao propria, UI shell, telemetria e ownership de dados. |
| Social basico | Social e guilda/chat/conexoes sao pilares reais, ainda que pequenos no V0. | Nomes de guildas, mensagens, interacoes e fantasia social atual sao mock. | Definir social minimo live: identidade, convite, guilda, chat/moderacao, contribuicao/ajuda, privacidade, abuso, logs e ferramentas de suporte. |
| Competicao/ranking | Ranking, matchmaking por poder e historico podem ser estruturas reais de retencao. | Posicoes, tiers, bots, temporadas e premios atuais sao placeholders. | Definir season model, resets, ligas, matchmaking, recompensas, integridade competitiva, bots oficiais e visibilidade de historico. |
| Conteudo | JSONs de spells, weapons, passives, pets, potions, structures e recipes ja indicam pipeline editavel. | O conteudo concreto e seu tema nao devem ser considerados canon final. | Criar schema/versionamento de conteudo, validadores, migrations, preview, autoria por designers/artistas e separacao clara entre conteudo mock e conteudo candidato. |
| Apresentacao e assets | A apresentacao atual ajuda o fundador e possiveis colaboradores a sentir uma direcao. | Imagens, iconografia, magos, finalizacoes, nomes e fantasia visual sao referencia, nao produto final. | Definir pipeline de substituicao de assets, guidelines tecnicos, resolucoes, fallback, creditos/licencas, bundles e revisao visual por plataforma. |
| Live ops e release | Release manifest, app config e safety gates ja apontam para operacao controlada. | Canais, flags, eventos, pass e conteudo programado ainda estao em modo demonstrativo. | Preparar feature flags, cohorts, kill switches, migrations seguras, rollback, calendario de seasons, ambientes, secrets e checklist de publicacao. |
| Telemetria e observabilidade | Telemetry functions e healthcheck ja sao base para enxergar o sistema. | Eventos atuais provavelmente cobrem mais validacao tecnica do que entendimento de produto. | Definir eventos do loop fundador, funis, erros, latencia, economia, batalha, social, dashboards, alertas e politica de retencao. |
| Seguranca e anti-cheat | Server-authoritative reduz superficie critica do cliente. | Labs, fixtures, bots e conteudo local ainda podem carregar atalhos aceitaveis de prototipo. | Revisar RLS, secrets, permissao por endpoint, validacao de input, abuso de economia, replay tampering, rate limits e trilha de auditoria. |
| Admin e suporte | Algumas bases tecnicas existem, mas operacao humana ainda nao e produto. | Sem necessidade de painel sofisticado para descoberta interna. | Definir ferramentas minimas: localizar conta, ajustar recursos com auditoria, invalidar save, revisar social, diagnosticar batalha e executar migracoes. |
| Validacao/QA | Existem scripts, gates e historico de tracks que dao disciplina tecnica. | A validacao ainda pode estar orientada a features entregues, nao ao novo enquadramento V0. | Criar matriz Foundation V0: app loop, backend contracts, migracoes, dispositivos, rede ruim, erro visual, regressao de batalha/base/social. |
| Colaboradores futuros | Documentacao local e status ajudam a receber co-designers/artistas depois. | O material atual pode induzir novos membros a discutir balanceamento/tema cedo demais. | Criar briefing de colaborador: o que e fixo, o que e mock, como propor tema/conteudo, como nao quebrar contratos tecnicos. |
| Roadmap amplo | Product vision ja registra futuros possiveis como open world, hero defense, PVE e roguelike cardgame mobile. | As ideias futuras ainda nao estao normalizadas como portfolio de minigames/progresso. | Manter registro vivo de futuros modos com grau de compartilhamento: progressao comum, progressao propria, economia, social, backend e UI shell. |

## Lacunas Mais Importantes Agora

1. Reenquadrar a documentacao principal para `FOUNDATION_AUDIT_ACTIVE`, evitando que mock de tema/conteudo vire promessa implicita.
2. Auditar o loop interno pos-login antes de mexer em social, visual geral, batalha, armas, spells ou economia.
3. Mapear exatamente onde a quantidade de etapas, posicao de icones e formato de apresentacao atrapalham coletar, evoluir, batalhar, receber recompensa e voltar para base.
4. Separar conteudo mock de conteudo candidato a produto por schema, pasta, flag ou estado documental claro.
5. Auditar conta/save/backend como fundacao live antes de expandir conteudo.
6. Definir um contrato de minigames, mesmo sem implementar novos minigames agora.
7. Definir o minimo de live ops, telemetria, admin e suporte que um app com possivel sucesso precisara carregar.

## Nao Priorizar Nesta Etapa

- Balanceamento fino de combate.
- Nomes finais de spells, personagens, predios, recursos ou passivas.
- Arte final, tema final ou identidade visual definitiva.
- Apresentacao final da batalha.
- Promessa publica de alpha, beta, launch ou monetizacao.
- Implementar varios minigames antes do contrato modular.
- Produzir grande volume de conteudo antes da fundacao aceitar substituicao e versionamento.

## Melhor Ordem Recomendada

1. Fechar o enquadramento `FOUNDATION_AUDIT_ACTIVE` nos documentos centrais.
2. Fazer a Foundation Audit do loop interno pos-login: base, coleta, evolucao, batalha, recompensa e retorno para base.
3. Escolher quais lacunas de clique, hierarquia visual e feedback viram hardening imediato do V0.
4. Discutir social.
5. Discutir visual geral.
6. Discutir apresentacao da batalha.
7. So depois discutir armas, spells, economia, balanceamento e conteudo detalhado.

Isto ainda nao e um plano completo. E a ordem recomendada para investigar e decidir com menos ruido.

## Perguntas Para A Proxima Rodada

1. Onde o loop atual mais atrapalha: quantidade de etapas, posicao dos icones, formato de apresentacao, feedback de recompensa ou retorno para a base?
2. O V0 deve tratar conta guest como caminho oficial temporario ou ja devemos priorizar account/save final antes de polir mais telas?
3. Social basico significa guilda, amigos, chat, ajuda/contribuicao, ranking compartilhado, ou apenas presenca social inicial?
4. Quais minigames futuros precisam entrar primeiro no registro de contratos: PVE, hero defense, roguelike cardgame, open world, outro?
5. Para voce, "APP perfeito" nesta fase significa mais fluidez de loop, estabilidade tecnica, qualidade mobile, clareza visual, ou resposta elegante a erro/rede?

## Fontes Consultadas

- `docs/product-vision.md`
- `docs/product-brief.md`
- `docs/game-design-document.md`
- `docs/design-pending.md`
- `docs/architecture.md`
- `docs/agent-operating-manual.md`
- `docs/documentation-index.md`
- `implementation/current-status.md`
- `AGENTS.md`
- `../../canon/canon-brief.md`
- `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `../../08_Coordenacao_Agentes/Estado_Atual.md`
- `../../Projetos/README.md`
