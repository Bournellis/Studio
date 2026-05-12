# Classes — Índice

- Last Updated: `2026-05-12`
- Status: `design completo — decks iniciais pendentes de sessão dedicada`
- Referência: `../lore-campaign.md`, `../game-design-document.md`
- Autoridade de Lore: `Projetos/draxos-roguelike-cardgame/docs/classes/README.md`

## Decisão de Design

O jogador escolhe uma classe no início da campanha e mantém essa identidade até o fim. Recompensas são definidas pelos encontros, não pela classe — qualquer classe pode receber qualquer recompensa de campanha.

O jogador é sempre um **Comandante Draxos**. A classe define o estilo de combate, não a raça.

## As Três Classes

| Classe | Passiva Inicial | Hero Power | Mecânica Central |
|---|---|---|---|
| [Arcano](arcano.md) | **Fluxo Contínuo:** cada magia resolvida no turno gera 1 Fluxo; Fluxo concede +1 de dano mágico a magias e hero power neste turno; reseta no início do próximo turno | **Pulso Astral** (1 energia): causa 1 dano mágico (+Fluxo) a qualquer permanente ou herói; 1× por turno | Sequenciar magias baratas para amplificar o golpe final |
| [Invocador](invocador.md) | **Comandante de Campo:** ao invocar criatura, aliada com maior ATK em campo ganha +1/+0 permanente; empate: jogador escolhe | **Amplificar** (1 energia): criatura aliada escolhida ganha +2/+0 permanente; 1× por turno | Acumular buffs permanentes em criaturas posicionadas em rotas relevantes |
| [Necromante](necromante.md) | **Colheita Sombria:** qualquer criatura destruída em campo (aliada ou inimiga) gera 1 Cinza; Cinzas acumulam entre turnos | **Ritual das Sombras** (0 energia + Cinzas): Degrau I (2) debuff · Degrau II (4) reanima 1/1 do Memorial · Degrau III (6) reanima com stats originais; 1× por turno | Gerar Cinzas por mortes em campo e usar o Ritual no momento certo |

## Mecânicas Exclusivas por Classe

**Fluxo Contínuo (Arcano):** contador volátil por turno. Amplifica apenas dano de tipo `magico` originado pelo jogador — não afeta ATK de criaturas nem dano físico.

**Buffs permanentes (Invocador):** buffs aplicados em criaturas durante a batalha persistem até a criatura ser destruída. A passiva e o hero power são sempre permanentes. Algumas cartas do deck podem ter buffs temporários para janelas pontuais.

**Cinzas e Memorial de Batalha (Necromante):** Cinzas acumulam entre turnos durante o encontro e não resetam. O Memorial de Batalha é a lista de todas as criaturas destruídas no encontro atual — al