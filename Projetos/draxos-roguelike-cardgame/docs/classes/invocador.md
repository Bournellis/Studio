# Invocador

- Last Updated: `2026-05-07`
- Status: `design completo — deck mockup registrado — aguarda validação de mecânica`
- Índice: `README.md`

## Identidade

O Invocador domina a mesa através da qualidade e da sinergia das suas criaturas. Cada criatura que entra tem uma habilidade própria, e buffs aplicados a elas são permanentes durante a batalha — uma criatura melhorada no turno 2 ainda carrega esse buff no turno 8.

O plano é escalar criaturas boas em criaturas dominantes. O inimigo vai precisar de remoções específicas para lidar com um campo que fica progressivamente mais forte a cada turno.

## Passiva Inicial — Comandante de Campo

Sempre que o jogador invocar uma criatura, a criatura aliada com **maior ATK em campo** ganha **+1/+0 permanentemente**. Em caso de empate de ATK, o jogador escolhe qual recebe o buff.

O buff é permanente durante a batalha. Invocar qualquer criatura — mesmo a mais barata do deck — sempre fortalece a maior ameaça em campo. Isso recompensa ter criaturas estabelecidas antes de invocar novas e cria crescimento gradual que se acumula ao longo da batalha.

> Exemplo: Voadora 3/2 em campo. Jogador invoca Criatura Proteção 1/4. Voadora recebe +1/+0 → vira 4/2 permanentemente.

## Habilidade Ativa

**Nome:** TBD

**Custo:** 1 mana · Usável uma vez por turno

**Efeito:** Escolha uma criatura aliada. Ela ganha **+2/+0 permanentemente**.

O buff acumula a cada uso. Ao longo de vários turnos, uma criatura que recebeu a ativa múltiplas vezes se torna uma ameaça desproporcional ao custo investido. A tensão: ATK cresce rápido, mas HP permanece o original — o jogador precisa buffar HP com cartas do deck para proteger o investimento.

## Loop Central

**Turnos 1–3:** estabelecer criaturas com habilidades úteis. Aplicar spell de classe na criatura mais relevante. A passiva começa a acumular +1/+0 a cada nova invocação.

**Turnos 4–6:** criaturas de médio a alto custo entram em um campo já preparado. Buffs permanentes de turno anteriores tornam o campo difícil de limpar eficientemente. Spells de buff de área podem transformar um campo médio em dominante.

**Turnos 7+:** com mana escalado, o Invocador pode invocar criaturas grandes e ainda usar a spell de classe no mesmo turno. O campo inimigo raramente tem resposta eficiente para múltiplas criaturas grandes e buffadas.

## Ponto de Virada

Uma criatura grande em campo com buffs acumulados suficientes para exigir múltiplas respostas do inimigo. O Invocador dita o ritmo quando o inimigo gasta recursos reagindo ao campo em vez de executando o próprio plano.

## Ponto Fraco

Spells de remoção em massa que limpam o campo antes dos buffs acumularem valor. Um encontro com remoção constante de criaturas individuais no early-game impede o Invocador de chegar a um campo dominante. Encontros `sobreviver_turnos` com pressão de dano constante podem derrotar o Invocador antes de ele estabelecer a mesa.

## Tipos de Buff

Buffs do Invocador têm dois comportamentos:

- **Permanentes durante a batalha:** o efeito fica na criatura até o fim do encontro. A spell de classe e a passiva são sempre permanentes. Algumas spells do deck também são permanentes.
- **Temporários (até o fim do turno):** algumas spells aplicam buffs temporários de ATK alto para criar janelas de ataque pontual. Úteis para finalizações ou para superar um bloqueador forte naquele turno.

O deck inicial deve ter maioria de buffs permanentes e poucos temporários de alto impacto.

## Direção das Criaturas

Criaturas do Invocador têm habilidades únicas que criam sinergia entre si e com os buffs:

- **Proteção:** o inimigo precisa atacar esta criatura antes de qualquer outra. Ideal para proteger criaturas buffadas.
- **Voadora:** ignora bloqueadores terrestres. Importante para criaturas buffadas atingirem o herói inimigo.
- **Regeneração:** recupera HP no início do turno. Criaturas com Regeneração aproveitam bem buffs de ATK sem morrer por contra-ataque.
- **Efeito ao entrar:** "ao entrar: todas as criaturas aliadas ganham +1/+0 até o fim do turno" — sinergia com criaturas já buffadas.
- **Colosso:** criatura de alto custo com stats dominantes. O destino dos buffs acumulados nos turnos anteriores.

## Direção do Deck Inicial

- Mix de criaturas de custo médio (2–3) com habilidades únicas.
- 1–2 criaturas de custo alto (5+) como objetivos de late-game.
- Spells de buff permanente de criatura única.
- Uma spell de buff temporário de alto impacto para fechar encontros.
- Uma spell de buff de área (afeta todas as criaturas aliadas).
- Sem foco em spells de dano direto — o dano vem das criaturas.

## Deck de Teste — Mockup

> Cartas sem nome, arte ou lore definitivos. Existem para validar a mecânica de Comandante de Campo e buffs permanentes.
> Parâmetros de teste: mana inicial 3 · HP do Comandante 20 · deck 15 cartas.

| Papel | Custo | Qty | Stats | Efeito |
|---|---|---|---|---|
| Criatura Proteção | 1 | ×3 | 1/4 | **Proteção:** inimigo deve atacar esta criatura antes de outras. |
| Criatura Voadora | 1 | ×2 | 3/2 | **Voadora:** ignora bloqueadores terrestres. |
| Buff permanente — único | 1 | ×4 | — | Criatura aliada escolhida ganha +1/+1 permanente. |
| Buff temporário — único | 1 | ×2 | — | Criatura aliada escolhida ganha +3/+0 até o fim do turno. |
| Criatura Regeneração | 2 | ×2 | 2/3 | **Regeneração:** recupera 1 HP no início de cada turno. |
| Buff permanente — área | 2 | ×1 | — | Todas as criaturas aliadas ganham +1/+1 permanente. |
| Colosso | 3 | ×1 | 5/5 | Sem habilidade. |

Distribuição: 0-custo ×0 · 1-custo ×11 · 2-custo ×3 · 3-custo ×1

## Pendências de Design

- Nome da spell de classe.
- Definir se buffs permanentes acumulam ilimitadamente ou têm algum teto de segurança.
- Definir keywords oficiais com nomes temáticos Draxos.
- Nomes e lore definitivos de todas as cartas após validação de mecânica.
