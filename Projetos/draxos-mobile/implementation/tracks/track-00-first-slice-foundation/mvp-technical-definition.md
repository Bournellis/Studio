# MVP Tecnico Minimo

- Ultima atualizacao: `2026-05-19`
- Track: `Track 00 - First Slice Foundation`
- Objetivo: provar arquitetura antes de implementar o primeiro slice completo

## Resultado Esperado

Ao fim do MVP tecnico, o usuario consegue abrir o cliente Godot, entrar como guest usando codigo de convite, solicitar uma batalha contra bot fixture, ver um log animavel placeholder e reabrir o cliente recuperando o estado salvo no servidor.

## Regras Fixas

- Godot: `4.6.2-stable`.
- GUT: `9.6.0`.
- Cliente usa GDScript e HTTPRequest.
- Servidor usa Supabase Auth, Postgres e Edge Functions.
- Cliente nao calcula resultado de batalha.
- Toda recompensa e mutacao de recurso acontece no servidor.
- Conteudo MVP usa fixtures marcadas como `MVP_ONLY`.

## Conteudo Fixture

| Item | Valor |
|---|---|
| Jogador | Draxos level 1 |
| Arma | Varinha Magica |
| Spell | Raio Cosmico |
| Pet | Nenhum |
| Passiva | Nenhuma |
| Oponente | Bot basico `mvp_training_bot` |
| Recompensa | Fixture tecnica `MVP_ONLY`, sem representar economia final |

## Funcionalidades

1. Tela inicial minima:
   - `Entrar como guest`
   - `Solicitar batalha`
   - `Ver resultado`
2. Conta:
   - Recebe codigo de convite.
   - Cria player guest servidor-side.
   - Salva token local seguro o suficiente para alpha tecnico.
3. Batalha:
   - `battle/request` escolhe bot fixture.
   - Simula com seed deterministica.
   - Grava `battles`.
   - Retorna envelope de log `battle_log_v1`.
4. Cliente:
   - Exibe eventos em ordem de tempo.
   - Nao reprocessa dano, vitoria ou recompensa.
5. Recuperacao:
   - Ao reabrir, cliente chama estado atual e ultima batalha.

## Criterios De Aceite

- Conta guest criada somente com convite valido.
- Convite invalido retorna erro controlado.
- `battle/request` exige autenticacao.
- Cada batalha retorna `battle_id`, `schema_version`, `seed`, `result` e `events`.
- Resultado e recompensa fixture sao gravados uma unica vez.
- Repetir consulta da ultima batalha nao duplica recompensa.
- Validacao documentada roda sem depender de editor aberto.

## Nao Objetivos

- Nao implementar balanceamento real.
- Nao implementar social, guilda, chat, ranking, Battle Pass ou loja.
- Nao implementar todos os tipos de dano.
- Nao implementar arte final.
- Nao configurar iOS ou mobile browser.
