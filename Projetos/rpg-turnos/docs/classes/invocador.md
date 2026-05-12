# Invocador

- Last Updated: `2026-05-12`
- Status: `design completo — deck inicial pendente de sessão dedicada`
- Índice: `README.md`
- Autoridade de Lore: `Projetos/draxos-roguelike-cardgame/docs/classes/invocador.md`

## Identidade

O Invocador domina o campo através da qualidade e da sinergia das criaturas. Cada criatura invocada fortalece permanentemente a maior ameaça já em campo. Buffs não desaparecem — uma criatura fortalecida no turno 2 ainda carrega esse crescimento no turno 8.

No sistema de rotas do RPG Turnos, uma criatura com ATK alto num slot de rota favorável se torna uma ameaça que exige resposta imediata. O Invocador força o inimigo a gastar recursos reagindo ao campo em vez de executar o próprio plano.

## Passiva — Comandante de Campo

Sempre que o jogador invocar uma criatura, a aliada com **maior ATK em campo** ganha **+1/+0 permanente**. Em empate de ATK, o jogador escolhe qual recebe o buff.

O buff é permanente até a criatura ser destruída. Invocar qualquer criatura — mesmo a mais barata — sempre fortalece a maior ameaça em campo.

> Exemplo: Criatura Voadora 3/2 em campo. Jogador invoca Criatura Defensora 1/4. Voadora recebe +1/+0 → vira 4/2 permanentemente.

## Hero Power — Amplificar

**Custo:** 1 energia · Normal · 1× no próprio turno

*Criatura aliada escolhida ganha +2/+0 permanente.*

O buff acumula a cada uso. Uma criatura que recebeu o hero power múltiplas vezes se torna desproporcional ao investimento. A tensão: ATK cresce rápido, mas HP permanece original — o jogador precisa proteger o investimento com `defensor` ou spells de buff de HP.

## Loop Central

**Turnos 1–3:** estabelecer criaturas em rotas relevantes. Usar hero power na criatura mais ameaçadora. A passiva começa a acumular +1/+0 a cada nova invocação.

**Turnos 4–6:** criaturas de médio a alto custo chegam a um campo já fortalecido. Buffs de turnos anteriores tornam o campo difícil de limpar. O inimigo precisa gastar remoções específicas para conter o crescimento.

**Turnos 7+:** com energia máxima, o Invocador invoca criaturas grandes e ainda usa o hero power no mesmo turno. O campo se torna progressivamente mais dominante a cada turno passado.

## Ponto de Virada

Uma criatura em rota favorável com buffs suficientes para exigir múltiplas respostas do inimigo. Quando o inimigo gasta recursos reagindo ao campo em vez de executar o próprio plano, o Invocador está no controle.

## Ponto Fraco

Magias de remoção em massa que limpam o campo antes dos buffs acumularem valor. Encontros com remoção constante de criaturas individuais no early-game impedem o Invocador de estabelecer uma base. `defesa` com pressão de dano constante pode derrotar o Invocador antes de ele construir campo dominante.

## Direção de Cartas

**Criaturas do Invocador** têm keywords que criam sinergia com rotas e buffs:
- `defensor`: protege criaturas buffadas de serem contornadas por rotas alternativas.
- `voadora`: ignora criaturas de rota intermediária — criatura buffada com voadora atinge o herói inimigo diretamente.
- `alcance`: cobre múltiplas rotas — criatura buffada com alcance pressiona vários slots ao mesmo tempo.
- **Efeito ao entrar:** fortalece o campo imediatamente, sinergiza com a passiva.
- **Criatura de alto custo e HP alto:** destino natural dos buffs acumulados.

**Magias do Invocador:**
- **Buff permanente de criatura única:** +1/+1 ou +2/+0 permanente.
- **Buff temporário de alto impacto:** +3/+0 ou +4/+0 até o fim do turno, para fechar encontros num momento decisivo.
- **Buff de área:** afeta todas as criaturas aliadas — transforma campo médio em dominante num turno.
- Sem foco em magias de dano direto. O dano vem das criaturas buffadas.

## Deck Inicial

Composição aproximada (design final em sessão dedicada):

| Papel | Tipo | Custo | Qtd |
|---|---|---|---|
| Criatura com defensor (protege criaturas buffadas) | criatura | 1 | ×3 |
| Criatura voadora (rota direta ao herói) | criatura | 1–2 | ×3 |
| Criatura com alcance (pressão multirrota) | criatura | 2 | ×2 |
| Criatura de alto custo (alvo de buffs) | criatura | 4–5 | ×2 |
| Buff permanente — criatura única | magia | 1 | ×4 |
| Buff temporário de alto impacto | magia | 1–2 | ×2 |
| Buff permanente — área | magia | 2–3 | ×2 |
| Criatura com efeito ao entrar | criatura | 2 | ×2 |

Total: 20 cartas. Nomes e stats definitivos pendentes.

## Requisitos de Engine Novos

**Nenhum requisito de engine novo.**

A passiva Comandante de Campo é um trigger de invocação que modifica ATK de uma criatura em campo. Identificar a criatura aliada com maior ATK já é derivável do estado de campo existente. O buff de ATK permanente já é o comportamento padrão de qualquer modificação de stat persistente no sistema atual.

O hero power Amplificar é equivalente a uma magia de buff permanente sobre criatura aliada — mesma categoria de efeito já coberta pelo pipeline existente.
