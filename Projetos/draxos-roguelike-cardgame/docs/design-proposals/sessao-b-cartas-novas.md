# Cartas Novas por Classe — Propostas de Design (Sessão B)

- Data: `2026-05-18`
- Status: `HISTORICO/PROMOVIDO - reward cards promovidas na Track 02`
- Sessão: Design Session B
- Dependência: `../design-proposals/sessao-a-keywords.md` (definições de keywords)
- Dependência: `../design-proposals/rota-29-mapas.md` (estrutura de recompensas)

> **Aviso:** Este documento registra a origem de design das reward cards. A Track
> 02 promoveu o pool de 8 cartas por classe; o JSON ativo, os docs de classe e os
> testes prevalecem sobre qualquer numero antigo desta proposta.

## Contexto

O pool atual tem 8 cartas de recompensa por classe, distribuidas em 4 elementos
ao longo da rota de 29 mapas. O jogador recebe o par Terra mais cedo e completa
os pares Gelo/Ar/Fogo conforme a agenda de recompensas declarada no JSON.

As cartas estão organizadas por **elemento temático** — o elemento do jogo em
que elas são desbloqueadas como recompensa. Isso alinha identidade mecânica e
identidade narrativa.

---

## Arcano — 6 Cartas Propostas

*Identidade atual:* spell damage via Choque/Tempestade, aura de poder de habilidade
via Fagulha/Barreira, splash via Bola de Fogo, aceleração de Fluxo via Acelerar.

*O que falta:* dano que usa Fluxo como escala direta; criatura que se sustenta
sob pressão; controle de timing inimigo; board clear para enxames.

### Terra — pool existente (referência)

| Carta | Custo | Tipo | Lvl 1 |
|---|---:|---|---|
| Bola de Fogo | 2 | Magia | Causa 1 de dano no alvo e 1 em cada slot adjacente. Fluxo e poder de habilidade amplificam todos os alvos. |
| Acelerar | 0 | Magia | Mesa aliada alvo recebe +1 poder de habilidade temporário até o fim do turno. |

### Gelo — par proposto

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Vórtice | 2 | — | Magia | Aplica Congelar em 1 criatura inimiga aleatória (não ataca no próximo ciclo). Gera 1 Fluxo. |
| Sentinela Arcana | 2 | 2/3 | Criatura | Escudo. Enquanto em campo: cada spell jogada neste turno restaura 1 HP nesta criatura (até o máximo). |

**Upgrades — Vórtice:**

| Versão | Efeito |
|---|---|
| Lvl 1 | Congela 1 criatura inimiga aleatória. Gera 1 Fluxo. |
| Lvl 2 | Congela até 2 criaturas inimigas aleatórias. Gera 1 Fluxo. |
| Lvl 3 | Congela todas as criaturas inimigas em campo. Custo 3 mana. |

**Upgrades — Sentinela Arcana:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 2/3. Escudo. Restaura 1 HP por spell jogada no turno. |
| Lvl 2 | 3/4. Escudo. Restaura 1 HP por spell. |
| Lvl 3 | 3/5. Escudo. Restaura 2 HP por spell. Quando o Escudo absorve dano, gera 1 Fluxo. |

### Ar — par proposto

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Amplificador | 1 | 1/2 | Criatura | Ecoar (ataca duas vezes por ciclo). Enquanto em campo: +2 poder de habilidade. |
| Canalizar | 1 | — | Magia | Causa dano igual ao Fluxo atual + 2 a uma criatura ou herói inimigo válido. Gera 1 Fluxo ao resolver. |

**Upgrades — Amplificador:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 1/2. Ecoar. +2 poder de habilidade. |
| Lvl 2 | 2/3. Ecoar. +2 poder de habilidade. |
| Lvl 3 | 2/4. Ecoar. +3 poder de habilidade. Quando o Ecoar dispara, gera 1 Fluxo. |

**Upgrades — Canalizar:**

| Versão | Efeito |
|---|---|
| Lvl 1 | Fluxo atual + 2 de dano. Gera 1 Fluxo ao resolver. |
| Lvl 2 | Fluxo atual + 4 de dano. Gera 1 Fluxo. |
| Lvl 3 | Custa 0. Fluxo atual + 4 de dano. Gera 1 Fluxo. |

### Fogo — par proposto

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Espelho Arcano | 2 | 0/4 | Criatura | Espinhos 2. Enquanto em campo: +1 poder de habilidade. |
| Descarga | 3 | — | Magia | Causa 2 de dano a cada criatura inimiga em campo. Fluxo e poder de habilidade amplificam cada alvo individualmente. |

**Upgrades — Espelho Arcano:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 0/4. Espinhos 2. +1 poder de habilidade. |
| Lvl 2 | 0/6. Espinhos 3. +1 poder de habilidade. |
| Lvl 3 | 0/8. Espinhos 4. +2 poder de habilidade. |

**Upgrades — Descarga:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 2 de dano a cada criatura inimiga. Amplificado por Fluxo e poder de habilidade. |
| Lvl 2 | 3 de dano a cada criatura inimiga. Amplificado. |
| Lvl 3 | 3 de dano a cada inimiga. Custo reduzido para 2 mana. |

---

## Invocador — 6 Cartas Propostas

*Identidade atual:* soldado genérico (Soldado), pressão rápida (Batedor), buff
flexível (Promover), tanque (Guardião), buff temporário (Atacar), tanque pesado (Golem).

*O que falta:* geração de tokens/presença numérica; Atropelar para linha de frente
agressiva; multiplicador de campo por posicionamento (Inspirar); algo de alto
risco/recompensa; sinergia horizontal entre criaturas.

### Terra — pool existente (referência)

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Atacar | 2 | — | Magia | Mesa aliada alvo recebe +1/+1 até o final do turno. |
| Golem | 3 | 4/5 | Criatura | Defensor. |

### Gelo — par proposto

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Capitão de Campo | 2 | 2/4 | Criatura | Inspirar +1: criaturas aliadas adjacentes ganham +1 ATK por ciclo de combate enquanto o Capitão estiver em campo. |
| Parede de Escudos | 2 | — | Magia | Todas as criaturas aliadas em campo ganham Escudo até o fim do próximo ciclo de combate. |

**Upgrades — Capitão de Campo:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 2/4. Inspirar +1 (adjacentes +1 ATK por ciclo). |
| Lvl 2 | 3/4. Inspirar +1. |
| Lvl 3 | 3/5. Inspirar +2. |

**Upgrades — Parede de Escudos:**

| Versão | Efeito |
|---|---|
| Lvl 1 | Todas aliadas em campo ganham Escudo. |
| Lvl 2 | Todas aliadas ganham Escudo. Criaturas com Escudo ativo ao entrar em campo neste turno ganham +1/+0. |
| Lvl 3 | Todas aliadas ganham Escudo. +1/+0 por Escudo ativo. Custo reduzido para 1 mana. |

### Ar — par proposto

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Cavaleiro Arcano | 2 | 3/3 | Criatura | Atropelar. |
| Berserker | 1 | 3/1 | Criatura | Atropelar. Fúria: ganha +1 ATK permanente cada vez que sofre dano e sobrevive ao ciclo. |

**Upgrades — Cavaleiro Arcano:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 3/3. Atropelar. |
| Lvl 2 | 4/3. Atropelar. |
| Lvl 3 | 5/3. Atropelar. Ao causar dano excedente, a criatura aliada de maior ATK ganha +1/+0 permanente. |

**Upgrades — Berserker:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 3/1. Atropelar. Fúria. |
| Lvl 2 | 4/1. Atropelar. Fúria. |
| Lvl 3 | 4/2. Atropelar. Fúria. Ao matar uma criatura, o Cavaleiro aliado mais próximo ganha +1/+0 permanente. |

### Fogo — par proposto

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Arauto | 1 | 1/2 | Criatura | Entrar: cria um token Recruta (1/1, sem keywords) no slot aliado vazio mais próximo. |
| Titã Geminal | 3 | 4/5 | Criatura | Pacto: enquanto outro aliado com Pacto estiver em campo, ambos ganham +2/+2. O bônus desaparece se o parceiro morrer. |

**Upgrades — Arauto:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 1/2. Entrar: 1 Recruta 1/1 em slot vazio. |
| Lvl 2 | 2/2. Entrar: 1 Recruta 1/1. |
| Lvl 3 | 2/3. Entrar: 2 Recrutas 1/1 em slots vazios. |

**Upgrades — Titã Geminal:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 4/5. Pacto (+2/+2 enquanto par vivo). |
| Lvl 2 | 5/6. Pacto (+2/+2). |
| Lvl 3 | 5/6. Pacto (+3/+3). Ao perder o parceiro Pacto, ganha Fúria permanentemente. |

---

## Necromante — 6 Cartas Propostas

*Identidade atual:* fodder de reviver (Esqueleto), efeito ao morrer (Morto-vivo/Zumbi),
controle (Prender), crescimento por morte de outros (Carniceiro), suicida (Diabrete).

*O que falta:* ameaça que funciona sem depender de mortes (o efeito Frio Intenso do
mapa 14 anula o kit atual completamente); spell de dano direto do deck; Veneno como
vetor de DoT; criatura de alto custo que justifique o investimento; plano B para
quando morrer é proibido.

### Terra — pool existente (referência)

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Carniceiro | 2 | 2/2 | Criatura | Carnica 1. |
| Diabrete | 1 | 2/1 | Criatura | Suicida 1. |

### Gelo — par proposto

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Revenant | 2 | 2/4 | Criatura | Ressurgir: ao morrer, retorna uma vez com 1/2 e sem keywords. |
| Flagelo | 1 | 1/2 | Criatura | Entrar: aplica Veneno 1 em criatura inimiga aleatória. Ao morrer: aplica Veneno 1 em criatura inimiga aleatória. |

> **Nota de design:** Ressurgir é uma qualidade intrínseca da criatura, não um
> trigger de deathrattle. A intenção é que funcione mesmo sob o efeito de campo
> Frio Intenso (mapa 14), que bloqueia efeitos ao morrer mas não retornos
> inatos. Confirmar na implementação se essa distinção é sustentável no engine.

**Upgrades — Revenant:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 2/4. Ressurgir (volta 1/2 sem keywords). |
| Lvl 2 | 3/4. Ressurgir (volta 1/2 sem keywords). |
| Lvl 3 | 3/5. Ressurgir (volta 2/3 sem keywords). Ao retornar, aplica Enfraquecer 1 em criatura inimiga aleatória. |

**Upgrades — Flagelo:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 1/2. Entrar: Veneno 1. Ao morrer: Veneno 1. |
| Lvl 2 | 2/2. Entrar e ao morrer: Veneno 1. |
| Lvl 3 | 2/3. Entrar: Veneno 2. Ao morrer: Veneno 2. |

### Ar — par proposto

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Arauto das Sombras | 2 | 1/3 | Criatura | Entrar: reanima a última criatura aliada morta nesta batalha com 1/1 sem keywords. Sem efeito se não houver mortas. |
| Colheita das Almas | 0 | — | Magia | Gera 2 Cinzas. Para cada criatura morta nesta batalha (aliada ou inimiga, cumulativo desde o início do combate), gera +1 Cinzas adicional. |

**Upgrades — Arauto das Sombras:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 1/3. Entrar: reanima última aliada morta como 1/1. |
| Lvl 2 | 2/4. Entrar: reanima como 2/2. |
| Lvl 3 | 2/5. Entrar: reanima como 2/2 com keywords originais intactas. |

**Upgrades — Colheita das Almas:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 2 Cinzas + 1 por cada morte na batalha. |
| Lvl 2 | 2 Cinzas + 1 por cada morte na batalha. |
| Lvl 3 | 3 Cinzas + 1 por cada morte. Se o total gerado for ≥ 6, compra 1 carta. |

### Fogo — par proposto

| Carta | Custo | Stats | Tipo | Lvl 1 |
|---|---:|---|---|---|
| Lich | 3 | 3/5 | Criatura | Imune (não pode ser alvo de Prender, Enfraquecer, Congelar ou Remover Keywords). Crescer +1: ganha +1 ATK no início de cada turno. |
| Praga | 2 | — | Magia | Aplica Veneno 1 em todas as criaturas inimigas em campo. Segunda aplicação acumula +1 em vez de substituir. |

**Upgrades — Lich:**

| Versão | Efeito |
|---|---|
| Lvl 1 | 3/5. Imune. Crescer +1 ATK por turno. |
| Lvl 2 | 4/6. Imune. Crescer +1. |
| Lvl 3 | 4/7. Imune. Crescer +2. Ao morrer: gera 3 Cinzas. |

**Upgrades — Praga:**

| Versão | Efeito |
|---|---|
| Lvl 1 | Veneno 1 em todas inimigas. Segunda aplicação acumula. |
| Lvl 2 | Veneno 2 em todas inimigas. |
| Lvl 3 | Veneno 2 em todas inimigas. Gera 1 Cinzas por criatura que já tinha Veneno ao resolver. |

---

## Estrutura de Recompensas na Rota de 29 Mapas

Cada elemento desbloqueia um par de cartas novas por classe. O jogador sempre
recebe ambas do par ao longo do elemento: escolhe uma num mapa, recebe a outra
num mapa posterior. Com 4 elementos e 2 cartas por elemento, o pool completo é
de 8 cartas novas por classe.

| Mapa | Evento | Arcano | Invocador | Necromante |
|---|---|---|---|---|
| 7 | Escolha 1 de 2 (Terra) | Bola de Fogo **ou** Acelerar | Atacar **ou** Golem | Carniceiro **ou** Diabrete |
| 11 | Recebe a restante (Terra) | a não escolhida | a não escolhida | a não escolhida |
| 13 | Escolha 1 de 2 (Gelo) | Vórtice **ou** Sentinela Arcana | Capitão de Campo **ou** Parede de Escudos | Revenant **ou** Flagelo |
| 17 | Escolha 1 de 2 (Ar) | Amplificador **ou** Canalizar | Cavaleiro Arcano **ou** Berserker | Arauto das Sombras **ou** Colheita das Almas |
| 20 | Recebe a restante (Ar) | a não escolhida | a não escolhida | a não escolhida |
| 24 | Escolha 1 de 2 (Fogo) | Espelho Arcano **ou** Descarga | Arauto **ou** Titã Geminal | Lich **ou** Praga |
| 26 | Recebe a restante (Fogo) | a não escolhida | a não escolhida | a não escolhida |

Decisões de build por run: 3 escolhas reais (Gelo, Ar, Fogo). O par Terra segue
o comportamento atual (escolha no mapa 7, restante no mapa 11).

---

## Notas de Rebalanceamento de Cartas Existentes

> Estas são observações levantadas em sessão de design, não confirmadas por playtest.
> Avaliar após testar a rota completa de 29 mapas com as novas cartas.

**Fagulha Arcana Lvl 3** (atual: +4 poder de habilidade) — com dois Fagulha Lvl 3
em campo, o bônus acumulado é +8 poder de habilidade. Com Fluxo de 3 cartas, um
Choque causa 11 de dano. Considerar reduzir Lvl 3 para +3 por instância.

**Golem (Invocador) Lvl 3** (atual: 6/10 Defensor Regeneracao 4) — com as novas
cartas de sinergia do Invocador, o Golem Lvl 3 pode ser excessivamente durável.
Considerar reduzir para Regeneracao 3 ou HP para 8.

**Barreira Arcana Lvl 3** (atual: 2/9 +2 poder de habilidade) — 2/9 é muito HP
para uma criatura Arcana. Considerar 1/8 ou 2/8 no Lvl 3.

**Promover Lvl 3** (atual: aplica +1/+1 + Iniciativa + Defensor) — funciona bem;
monitorar após adição do Capitão de Campo e Parede de Escudos para verificar
acúmulo excessivo de bônus.
