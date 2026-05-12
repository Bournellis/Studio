# Arcano

- Last Updated: `2026-05-12`
- Status: `design completo — deck inicial pendente de sessão dedicada`
- Índice: `README.md`
- Autoridade de Lore: `Projetos/draxos-roguelike-cardgame/docs/classes/arcano.md`

## Identidade

O Arcano vence através de feitiços amplificados pela sequência. Cada magia resolvida no turno torna a próxima mais poderosa. Criaturas existem para proteger o Arcano e sustentar o ritmo de energia enquanto a mão cicla em feitiços.

O Arcano não fecha jogos com criaturas. O dano vem das magias. O turno decisivo é aquele em que o Arcano encadeia várias magias baratas antes de soltar o golpe final com Fluxo alto.

## Passiva — Fluxo Contínuo

Cada magia resolvida no turno do jogador gera **1 Fluxo**. Cada ponto de Fluxo concede **+1 de dano mágico** a toda fonte de dano mágico do jogador neste turno: magias e hero power. Não afeta ATK de criaturas.

Fluxo reseta no início do próximo turno do jogador.

> Exemplo: o jogador resolve 3 magias antes de usar o hero power. Com 3 de Fluxo, o hero power que causa 1 de dano causa 1+3 = **4 de dano**.

## Hero Power — Pulso Astral

**Custo:** 1 energia · Normal · 1× no próprio turno

*Causa 1 de dano mágico a qualquer permanente ou herói. Amplificado pelo Fluxo atual.*

Sempre útil: elimina criatura pequena bloqueando rota, finaliza permanente danificado, vai no herói inimigo no modo `duelo`. Dá destino para a energia sobrando depois de ciclar magias baratas.

## Loop Central

**Turnos 1–3:** cobrir rotas com criaturas defensivas. Resolver magias baratas para sentir o Fluxo. O dano já chega amplificado mesmo com pouco Fluxo.

**Turnos 4–6:** com energia escalando, é possível resolver mais magias antes do hero power no mesmo turno. Fluxo de 4–6 transforma o Pulso Astral em ameaça real ao herói inimigo ou elimina permanentes grandes.

**Turnos 7+:** sequências longas com energia máxima. Um turno com 5+ Fluxo pode limpar campo e pressionar o herói ao mesmo tempo.

## Ponto de Virada

Ter energia suficiente para resolver várias magias antes do hero power no mesmo turno. A partir desse ponto o Arcano concentra dano alto num único alvo sem precisar de múltiplas magias caras.

## Ponto Fraco

Pressão de campo que força gasto de energia em respostas antes de construir Fluxo. Encontros com criaturas `rapido` nos primeiros turnos reduzem o espaço para encadear feitiços. `ondas` com pressão constante podem bloquear completamente qualquer sequência de Fluxo alto.

## Direção de Cartas

**Criaturas do Arcano** são de suporte, não ofensivas:
- `defensor` com HP alto para cobrir rotas e proteger o Arcano enquanto ele cicla.
- Geradoras de energia: ao entrar ou enquanto em campo, concedem energia extra para sustentar sequências longas.
- Sem criaturas com `rapido` ou perfil agressivo.

**Magias do Arcano:**
- **Custo 1 — combustível de Fluxo:** a maioria das magias baratas. Efeito secundário útil: 1 de dano, `enjoo` em criatura, `queimando` em slot, ou remoção de dano baixo.
- **Custo 2–3 — finalizadoras:** magias de dano médio a alto que chegam amplificadas depois de uma sequência de magias baratas.
- **`magia_de_tabuleiro`:** efeito de área ou controle; conta como 1 Fluxo como qualquer outra magia.

O deck não deve ter criaturas com `rapido` ou perfil ofensivo. O Arcano atrasa, controla e explode num turno decisivo.

## Deck Inicial

Composição aproximada (design final em sessão dedicada):

| Papel | Tipo | Custo | Qtd |
|---|---|---|---|
| Criatura defensora (defensor, HP alto) | criatura | 1–2 | ×4 |
| Criatura geradora de energia | criatura | 1–2 | ×3 |
| Magia de Fluxo barata (dano 1 ou efeito menor) | magia | 1 | ×6 |
| Magia finalizadora (dano 3–4) | magia | 2–3 | ×4 |
| Magia de tabuleiro (controle ou dano de área) | magia_de_tabuleiro | 3–4 | ×2 |
| Criatura grande defensiva (fallback) | criatura | 4 | ×1 |

Total: 20 cartas. Nomes e stats definitivos pendentes.

## Requisitos de Engine Novos

**Contador de Fluxo por turno (volátil):**
Incrementa a cada magia resolvida no turno do jogador; reseta no início do turno seguinte do jogador. Baixa complexidade — estrutura idêntica a qualquer contador de estado volátil por turno.

**Amplificação de dano mágico pelo Fluxo:**
Ao calcular dano de tipo `magico` originado pelo jogador (magias e hero power), somar o valor atual de Fluxo ao dano base. Não afeta `fisico_melee`, `fisico_alcance`, nem dano de criaturas. Baixa complexidade — modificação pontual no pipeline de resolução de dano mágico.
