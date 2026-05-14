# RPGMobile — Game Design Document

- Last Updated: `2026-05-14`
- Status: `P1_CONCEITO — rascunho inicial`
- Lore Canon: `../../../../canon/lore/shared-lore.md`, `../../../../canon/lore/human-factions.md`

---

## 1. Visão Geral

RPGMobile é um RPG de ação 2D, multiplataforma (Android e iOS), single player com sensação de MMORPG. O jogador habita um mundo aberto vivo, cheio de quests, eventos, dungeons e outros personagens — não percorre uma campanha linear e isolada.

O jogo se passa no universo compartilhado do estúdio: um futuro real da humanidade na Via Láctea, milênios após o apocalipse nuclear da Terra, onde facções humanas navegam o espaço e convivem com outros seres — alguns familiares, outros temidos.

---

## 2. Identidade do Jogo

**O que é:**
- RPG de ação 2D com câmera fixa
- Mundo aberto com quests principais e secundárias, dungeons e eventos
- Single player com sensação de MMORPG solo
- F2P com monetização sustentável e updates constantes
- Facção do jogador como identidade de classe

**O que não é:**
- Diablo ou action RPG no sentido de câmera dinâmica e câmaras procedurais
- Jogo de menus — o tempo do jogador é de gameplay ativa
- Pay-to-win
- Campanha linear e sequencial

---

## 3. Plataforma e Controles

**Plataformas:** Android e iOS, desde o lançamento.

**Câmera:** Fixa, top-down ligeiramente inclinada. Lê bem o campo de batalha e o mundo ao redor.

**Controles mobile:**
- Polegar esquerdo: joystick virtual de movimento
- Polegar direito: ataque básico, habilidade de movimento, habilidades ativas, itens de uso rápido

Referências de controle: Brawl Stars, MOBAs mobile. O jogador tem controle direto sobre o personagem em tempo real — não é auto-battle nem clique para mover.

---

## 4. Loop Principal

```
Entrar no mundo → Navegar zona ativa → Matar monstros / coletar loot
→ Completar quests → Entrar em dungeons → Derrotar chefes
→ Evoluir personagem → Acessar zona nova
```

O loop é deliberadamente direto. Sistemas de upgrade e progressão existem como camadas de profundidade, não como o foco principal da sessão. A regra é: **o jogador clica em menu o mínimo possível**.

---

## 5. Monetização

O modelo F2P tem quatro camadas, ordenadas do menos intrusivo ao mais engajado:

| Camada | Descrição | Regra |
|---|---|---|
| **Ads opcionais** | Mini prêmios por assistir anúncios | Nunca obrigatórios, sempre iniciados pelo jogador |
| **Upgrades pagos** | Aceleração de progressão | Não concedem poder exclusivo — apenas velocidade |
| **Battle Pass** | Conteúdo sazonal com recompensas por jogo | Jogadores free progridem também, porém mais devagar |
| **Cosméticos** | Visuais de personagem, nave, efeitos | Sem impacto mecânico, sempre |

**Regra geral:** nenhuma camada de monetização deve dar vantagem de poder que não seja alcançável jogando. O jogo deve ser satisfatório sem gastar dinheiro.

O Battle Pass e os updates constantes exigem que a arquitetura de conteúdo seja planejada desde o início para crescer sem acumular dívida de design. Ver Seção 10.

---

## 6. Facção como Classe

A facção do jogador é sua identidade de classe. Ela define:

- Estilo de combate e pool de habilidades
- Pool de equipamentos e itens compatíveis
- Perspectiva narrativa — de onde o jogador vê o mundo
- Ponto de entrada na história — sua zona inicial, seu planeta natal

Não existem classes genéricas separadas do lore. Escolher uma facção é escolher quem você é nesse universo.

**Escopo inicial:** uma facção jogável. Cada nova facção adicionada no futuro é equivalente a uma nova classe, com seu próprio early game completo e posterior convergência para o late game compartilhado.

**Especializações:** dentro de uma facção, especializações emergem pela progressão, não pela seleção inicial. O jogador descobre o tipo de combatente que quer ser ao jogar, não numa tela de criação de personagem.

---

## 7. Season 1 — O Planeta Natal

### Premissa

O jogador é um membro jovem de sua facção, no planeta natal dessa facção. A militarização é obrigatória na cultura dessa sociedade — ele é designado para o treinamento e começa sua vida como soldado.

### Estrutura do arco

A Season 1 é o equivalente à zona inicial de raça de um MMORPG — mas com profundidade de arco completo.

**Fase 1 — Treinamento e planeta**
O jogador aprende o jogo fazendo o que o exército da facção faz em seu território: missões locais, patrulhas, garantia de recursos, gestão de ameaças internas e externas próximas. Ele conhece a própria facção de dentro — seus valores, suas contradições, seus personagens.

**Fase 2 — Primeiras missões espaciais**
Pontualmente, o jogador começa a ser designado para operações fora do planeta — missões espaciais de curto prazo que expandem o horizonte sem soltar o personagem do planeta natal ainda. O mundo começa a parecer maior.

**Fase 3 — Saindo do planeta**
Perto do fim da Season 1, o personagem começa a operar com mais frequência fora do planeta natal. O mundo abre. Ele encontra outras facções, outros seres, situações que vão além do que o planeta podia oferecer.

**Conclusão — A nave**
A grande conquista de terminar a Season 1 é obter a própria nave. Não como item — como evento narrativo e mecânico. O jogador agora tem sua base móvel, sua identidade no espaço. Isso é o que abre o late game.

### Por que essa estrutura funciona

- Onboarding orgânico: o mundo é apresentado pelo ponto de vista de quem também está descobrindo
- A nave como recompensa é tangível e muda fundamentalmente a experiência de jogo
- O arco é completo em si mesmo — um jogador que para após a Season 1 teve uma experiência satisfatória
- Seasons futuras com novas facções replicam esse template com conteúdo completamente diferente

---

## 8. Late Game Compartilhado

O late game é o espaço onde jogadores de qualquer facção convergem. Ele é projetado para ser neutro em relação à origem do jogador.

### 8.1 A nave como hub

A nave do jogador é o hub persistente do late game. É um espaço físico navegável — não um menu — com:

- Tripulação recrutável (NPCs com quests e diálogos)
- Representantes de facções aliadas ou neutras
- Sistemas de upgrade da própria nave
- Interface de navegação (objeto físico no mundo, não botão de UI)
- Armazém, crafting, progressão

A nave tem sua própria curva de upgrade ao longo do tempo. Módulos novos desbloqueiam zonas mais distantes ou mais perigosas. O upgrade da nave é um dos eixos de grind do late game.

### 8.2 Território neutro

O late game acontece em zonas que não pertencem a nenhuma facção: regiões contestadas, planetas sem dono, campos de asteroides ricos em recursos, estações abandonadas, fronteiras inexploradas.

Isso garante que nenhuma facção tenha vantagem narrativa no late game. O jogador que veio de qualquer facção chega ao mesmo território sem que o mundo favoreça ninguém.

### 8.3 A ameaça Draxos como espinha dorsal

Os Draxos são a ameaça crescente que organiza a narrativa do late game e dá ao battle pass uma progressão temática clara por season.

- **Early game:** os Draxos são rumores — algo que soldados experientes mencionam com respeito
- **Mid game:** sinais, rastros, encontros indiretos, tensão crescente
- **Late game:** presença direta e confronto real se torna possível

Essa escalada funciona para qualquer facção porque os Draxos não distinguem. Eles ameaçam a todos. Isso cria uma razão compartilhada para o late game existir além de "mais loot".

### 8.4 Sistema de reputação inter-facções

O late game usa reputação como moeda de acesso horizontal.

O jogador da Facção A pode construir reputação com a Facção B através de missões, comércio ou ajuda em crises. Isso abre equipamentos específicos, quests e fragmentos narrativos daquela facção.

Benefícios do sistema:
- Mantém todas as facções relevantes no late game
- Cria engajamento de longo prazo sem forçar reroll
- Dá sensação de mundo com atores vivos, não corredor de conteúdo
- Adicionar uma nova facção no futuro automaticamente expande esse sistema

---

## 9. Mundo Aberto — Estrutura

O mundo não é um planeta único nem uma galáxia inteira disponível de início. Cresce em círculos concêntricos:

**Season 1:** o planeta natal é o mundo. É grande o suficiente para ter regiões variadas, dungeons, eventos e quests sem que o jogador sinta que está num corredor.

**Pós-Season 1:** a nave abre o acesso a zonas adjacentes — outros planetas, estações, campos. Cada zona é um mundo aberto próprio, não um mapa linear.

**Seasons futuras:** cada season adiciona pelo menos uma zona nova acessível pela nave. O conteúdo antigo permanece relevante como fonte de materiais e missões contínuas.

O jogador nunca precisa ir a um menu de seleção de mundo. A transição acontece dentro do jogo: vai até a cabine de navegação da nave, escolhe o destino, viaja.

---

## 10. Modelo de Seasons e Crescimento Sustentável

O F2P com battle pass exige updates constantes. A arquitetura de conteúdo precisa crescer sem acumular bagunça de sistemas sobrepostos.

**Cada season entrega exatamente:**

| Elemento | Descrição |
|---|---|
| Uma zona nova | Planeta, estação ou campo de asteroides acessível pela nave |
| Um arco narrativo | Contido na zona nova, com início, meio e fim |
| Uma camada Draxos | Aprofunda a ameaça com novos eventos ou revelações |
| Novos inimigos e chefes | Dentro da zona nova |
| Novos itens e equipamentos | Relevantes para a zona nova e para progressão geral |
| Conteúdo de battle pass | Cosméticos, missões sazonais, recompensas de engajamento |

**Regra de crescimento:** conteúdo antigo nunca é descartado — permanece relevante como fonte de materiais de upgrade de nave, de reputação com facções ou de missões contínuas. Seasons expandem, não substituem.

**Regra de sistemas:** nenhuma season cria um novo sistema de progressão maior sem arquivar ou integrar o anterior. O número de sistemas ativos e visíveis ao jogador deve permanecer legível.

---

## 11. Pilares de Produto

**Mundo vivo, não campanha**
O jogador existe em um mundo com múltiplos atores — facções, raças, eventos. Não está sendo conduzido por um corredor de história.

**Gameplay primeiro**
O tempo de sessão é dominado por combate e exploração. Sistemas de progressão são profundidade, não o foco.

**Identidade de facção**
Escolher uma facção é escolher quem você é. Isso tem peso narrativo e mecânico real.

**Crescimento tangível**
A nave, o upgrade de equipamento, as especializações — o jogador vê e sente o crescimento. Não são apenas números.

**Ameaça escalável**
Os Draxos como horizonte sempre presente garantem que o late game tenha sentido de urgência e progressão narrativa além do grind.

---

## 12. Restrições para Incubação

- Não definir a facção inicial sem antes documentar seu lore básico em `canon/lore/human-factions.md`
- Não começar implementação sem fechar o loop de sessão em protótipo
- Não desenhar sistemas de monetização detalhados antes de validar o loop de combat
- O late game compartilhado deve ser esboçado em design mesmo que não implementado na Season 1 — as decisões de Season 1 precisam apontar na direção certa
- Não usar loadout ou sistemas de combat do RPG Isométrico sem adaptação explícita para mobile e para o contexto de facções

---

## 13. Próximos Passos

- [ ] Definir e documentar a primeira facção jogável (lore, estrutura social, identidade de combate)
- [ ] Esboçar o planeta natal da Season 1 (zona, regiões, ameaças locais, tom)
- [ ] Definir o sistema de combate base (habilidades, recursos, loop de batalha)
- [ ] Prototipar o loop de sessão mínimo
- [ ] Esboçar o late game compartilhado em nível de design suficiente para guiar decisões da Season 1
