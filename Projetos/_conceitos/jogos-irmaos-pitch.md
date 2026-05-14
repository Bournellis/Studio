# Jogos Irmãos — BattleMobile & RPGMobile

**Status**: Incubação Conceitual  
**Data**: 2026-05-14  
**Universo**: Draxos  
**Plataforma alvo**: Android + iOS (Godot, export multiplataforma)

---

## O Conceito de Jogos Irmãos

BattleMobile e RPGMobile são dois apps independentes que habitam o mesmo universo Draxos.
Eles servem públicos e momentos diferentes, mas compartilham lore, personagens, e a estética
do universo — de modo que um jogador que conheça um reconheça o outro imediatamente.

**Não são o mesmo jogo com dois modos.** Não compartilham conta nem progressão (por ora).
São irmãos no espírito: mesma mãe, personalidades distintas.

| Dimensão | BattleMobile | RPGMobile |
|---|---|---|
| Sessão | Curta (3–7 min) | Média (10–20 min) |
| Público | Casual a intermediário, gosta de ação rápida | Intermediário a engajado, gosta de crescimento |
| Frequência | Várias vezes por dia | 1–2 vezes por dia |
| Horizonte | Dias/semanas | Meses |
| Modo social | Competitivo / assíncrono | Solo primeiro |
| Risco de canibalismo | Baixo — perfis complementares | Baixo — perfis complementares |

---

## RPGMobile — "O Herói que Você Constrói"

### Fantasia Central

> Você é um Imortal no universo Draxos. Você começa fraco, desconhecido, e ao longo de semanas
> cresce em poder, forma sua identidade de herói, e descobre o papel do seu personagem dentro
> de uma história maior.

O jogador sente que **está construindo algo que é seu** — um herói com nome, raça, habilidades
e visual únicos que evoluem visivelmente ao longo do tempo.

### Loop Principal

```
Sessão diária (10–20 min)
  → Missão PvE (combate por turnos ou estratégico)
  → Recompensas (materiais, fragmentos de habilidade, lore)
  → Upgrade de herói (nível, skills, equipamento)
  → Desbloqueio de próximo capítulo de história
```

### Pilares de Produto

1. **Identidade do Herói** — Raça Draxos, classe, loadout visual. Cada herói é reconhecível.
2. **Progressão de Longo Prazo** — Curva de meses. O jogador vê o herói crescer semana a semana.
3. **História no Universo Draxos** — Narrativa fragmentada entregue pela progressão. Missões têm contexto.
4. **Coleção Significativa** — Skills, itens, companheiros. Coletar tem propósito, não é só completismo.

### Posicionamento de Mercado

Referências próximas: RPG em camadas com progressão de herói (ex.: AFK Arena sem idle puro,
Raid Shadow Legends sem pay-to-win agressivo). Diferencial: o universo Draxos original
e narrativa com decisões morais — jogador faz escolhas que afetam a história do seu herói.

### Restrições para Incubação

- Não decidir monetização antes de fechar o loop de sessão.
- Não assumir online-first: o loop deve funcionar 100% offline.
- Não usar o sistema de loadout do RPG Isométrico sem adaptação explícita para mobile.

---

## BattleMobile — "A Batalha que Você Domina"

### Status da Fantasia Central

**Ainda em exploração.** Três direções foram identificadas para discussão:

---

### Opção A — "Invasão" (Perspectiva Draxos)

> Você comanda uma força Draxos invadindo um planeta inimigo.
> Cada partida é uma batalha de 3–5 minutos: você deploia unidades por lanes,
> avança pelo mapa e captura o núcleo do planeta.

- **Sessão**: curta, offline
- **Perspectiva**: você é o agressor — fantasia de conquista e domínio
- **Mecânica**: deployment tático por lanes (próximo ao que já existe no Draxos roguelike),
  sem deck de cartas — foco em unidades com habilidades diretas
- **Diferencial do irmão**: BattleMobile é ofensivo, rápido, externo (conquista);
  RPGMobile é interno (crescimento pessoal)
- **Risco**: pode solapar mecânicas do Draxos roguelike se não diferenciado claramente

---

### Opção B — "Arena dos Imortais" (Duelos PvP)

> Você escolhe 3 Imortais da sua coleção e enfrenta outro jogador.
> Batalha tática de 5–7 minutos, assíncrona ou em tempo real.

- **Sessão**: curta a média, requer conexão para PvP
- **Perspectiva**: você é um treinador / comandante de heróis
- **Mecânica**: formação de time, sinergias entre heróis, counter-picks
- **Diferencial do irmão**: BattleMobile = competição social (quem tem o time melhor);
  RPGMobile = evolução solo (quem tem o herói mais desenvolvido)
- **Sinergia potencial**: heróis criados no RPGMobile poderiam ser usados no BattleMobile
  (sinergia de IP, não necessariamente de dados)
- **Risco**: PvP exige balanceamento contínuo — custo de live ops alto para solo dev

---

### Opção C — "Frente de Guerra" (Estratégia de Campo)

> Você comanda um esquadrão Draxos em missões táticas rápidas.
> Posiciona unidades no campo antes da batalha, depois assiste e intervém com habilidades.

- **Sessão**: média (7–12 min), funciona offline
- **Perspectiva**: general tático, não combatente direto
- **Mecânica**: posicionamento pré-batalha + habilidades ativas durante combate
  (auto-battle com intervenção tática)
- **Diferencial do irmão**: BattleMobile = macro estratégico (mover exércitos);
  RPGMobile = micro pessoal (evoluir um herói)
- **Risco**: sessão mais longa pode reduzir o diferencial de "partida rápida" do mobile

---

### Próximo Passo para BattleMobile

Escolher uma das três direções (ou propor variante) para então definir:
1. Fantasia central finalizada
2. Loop de sessão detalhado
3. Pilares de produto
4. Posicionamento de mercado

---

## Conexão entre os Jogos Irmãos

### O que compartilham (sempre)

- Universo Draxos — lore, facções, locais, bestiário
- Estética visual — paleta, tipografia, identidade de marca
- Personagens icônicos — Imortais reconhecíveis aparecem nos dois
- Nome do estúdio / publisher

### O que podem compartilhar (decisão futura)

- Universo de coleção (herói criado em RPGMobile aparece em BattleMobile como skin)
- Cross-promotion in-game (desbloqueie item no BattleMobile ao atingir nível X no RPGMobile)
- Conta unificada (requer backend — decisão a tomar quando ambos saírem de conceito)

### O que NÃO compartilham (por design)

- Progressão de poder (evitar que um jogo dê vantagem no outro)
- Mecânicas de core loop (cada um tem seu loop próprio)
- Godot project (repositórios separados)

---

## Próximos Passos do Incubatório

- [ ] Escolher fantasia central do BattleMobile (Opção A, B, C ou variante)
- [ ] Fechar pitch completo do BattleMobile após escolha
- [ ] Definir monetização candidata para RPGMobile
- [ ] Definir monetização candidata para BattleMobile
- [ ] Criar `design/` local em cada projeto com GDD inicial
- [ ] Avaliar se os projetos estão prontos para sair de `P1_CONCEITO` para implementação

---

*Este documento é produto de incubação conceitual. Não criar código, cenas ou assets de
implementação sem pedido explícito do usuário e mudança formal de status no portfólio.*
