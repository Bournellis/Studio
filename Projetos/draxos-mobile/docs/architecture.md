# DraxosMobile - Architecture

- Ultima atualizacao: `2026-05-19`

---

## Stack

| Camada | Tecnologia |
|---|---|
| Client | Godot `4.6.2-stable` (GDScript) |
| Backend | Supabase Auth, Postgres, Edge Functions, Realtime |
| Comunicacao | REST via HTTPRequest do Godot |
| Autenticacao | JWT Supabase + Google OAuth2 |
| Testes client | GUT `9.6.0` |
| Testes server | Deno/TypeScript tests para Edge Functions |

---

## Contratos

Antes de criar codigo ou migrations, consulte:

- `contracts/api-endpoints.md`
- `contracts/battle-event-log.md`
- `contracts/database-schema.md`
- `contracts/content-definitions.md`

Quando `server/schema/` e `server/functions/` existirem, eles viram a fonte tecnica viva, mas os contratos continuam explicando intencao e compatibilidade.

---

## Plataformas E Exports

| Plataforma | Export Godot | Notas |
|---|---|---|
| Android | Android APK | App nativo - unico canal mobile |
| PC Windows/Linux | Executavel nativo | `.zip` |
| PC Browser | HTML5/WebAssembly | Godot web export |
| Mobile browser | - | Fora do escopo |
| iOS | - | Futuro |

Input adaptado por plataforma: `InputEventScreenTouch` para Android e `InputEventMouseButton` para PC/browser.

---

## Arquitetura De Conta

Fluxo completo do primeiro slice:

```text
Boot
  -> Tem token salvo?
       -> Sim: validar token e entrar
       -> Nao: tela de entrada
            -> Jogar como guest com codigo de convite
            -> Login email/senha
            -> Google Sign-In
```

Guest pode migrar para conta registrada sem perder progresso.

MVP tecnico implementa apenas guest com codigo de convite.

---

## Arquitetura De Batalha

O cliente Godot nunca simula batalha.

```text
Cliente
  -> POST /battle/request
Servidor
  -> seleciona oponente
  -> simula batalha completa
  -> grava resultado e recompensa
  -> retorna battle_log_v1
Cliente
  -> anima log recebido
```

Desconexao durante batalha nao altera resultado, porque o resultado ja foi gravado antes do cliente animar.

Contrato do log: `contracts/battle-event-log.md`.

---

## Dados Autoritativos No Servidor

| Dado | Onde vive |
|---|---|
| Recursos | Postgres, mutado so por Edge Functions |
| Level, XP e build | Postgres |
| Resultado de batalhas e ranking | Postgres, calculado no servidor |
| Dados de guilda e social | Postgres |
| Pool de oponentes | Postgres |
| Preferencias de UI e cache visual | Local, sem impacto em progressao |
| Producao da base | Calculada no servidor na reconexao |

RLS deve impedir acesso indevido. Mutacoes economicas devem usar idempotencia e ledger.

---

## Matchmaking E Ranking

MVP tecnico usa bot fixture `mvp_training_bot`.

Primeiro slice completo:

- Calcula poder do solicitante.
- Filtra pool por faixa de poder.
- Sorteia oponente real ou bot simulado.
- Bots simulados nao aparecem em ranking.
- Ranking usa pontos de arena por season e snapshot no encerramento.

Formula final e faixa inicial estao registradas em `design-pending.md`.

---

## Politica Offline

| Situacao | Comportamento |
|---|---|
| Sem internet | Estado cacheado exibido, batalha e chat desabilitados |
| Producao da base offline | Servidor calcula delta na reconexao |
| Desconexao durante batalha | Cliente busca log gravado |
| Coleta offline | Servidor acumula respeitando armazenamento |

---

## Anti-Cheat

| Vetor | Mitigacao |
|---|---|
| Forjar resultado | Batalha 100% servidor |
| Injetar recursos | Edge Functions validam toda mutacao |
| Escolher oponente facil | Servidor controla matchmaking |
| Farm abusivo | Rate limiting no endpoint de batalha |
| Acesso a dados alheios | RLS do Supabase |
| Duplicar recompensa | Idempotencia por `request_id` e ledger |
| Engenharia reversa do oponente | Log retorna eventos animaveis, nao build completa |

---

## Estrutura De Pastas - Codigo

```text
draxos-mobile/
|-- server/
|   |-- schema/
|   `-- functions/
|       |-- battle/
|       |-- account/
|       |-- base/
|       `-- social/
|-- core/
|-- data/
|   |-- definitions/
|   `-- generated/
|-- modes/
|-- ui/
|-- social/
|-- tools/
`-- tests/
```

---

## Pendencias Arquiteturais

Pendencias vivas:

- Chat: politica de retencao/delecao/moderacao (`DMOB-D023`).
- Telemetria minima (`DMOB-D024`).
- Schema de build para spells desbloqueadas/equipadas (`DMOB-D026`).
