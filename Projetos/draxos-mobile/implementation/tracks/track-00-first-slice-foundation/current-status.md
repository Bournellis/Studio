# Track 00 - First Slice Foundation

- Last Updated: `2026-05-20`
- Track Status: `OPEN - T00-P01, T00-P02A, T00-P02B, T00-P03, T00-P04, T00-P05, T00-P06, T00-P07 e T00-P08 concluidos; T00-P09 em andamento`
- Goal: montar o primeiro slice completo do DraxosMobile, iniciando pelo MVP tecnico minimo

---

## Escopo

Track 00 tem dois niveis:

1. **MVP tecnico minimo:** provar arquitetura Godot 4.6.2 + Supabase com guest, battle fixture server-authoritative e log animavel placeholder.
2. **Primeiro slice completo:** entregar PVP autobattler, base manager, social, ranking, bots, conta, economia, Battle Pass/Diamante, validacao e exports Android/PC/browser.

Detalhes em `scope.md` e `mvp-technical-definition.md`.

---

## Documentos Da Track

- `scope.md` - escopo, fora de escopo e criterios de aceite.
- `mvp-technical-definition.md` - primeira entrega implementavel.
- `implementation-plan.md` - sequencia completa T00-P00 a T00-P13.
- `implementation-prompts.md` - prompts atomicos para agentes.
- `../../../docs/reuse-map.md` - mapa de reuso conservador entre projetos.

---

## Status Dos Passos

| Passo | Status | Saida |
|---|---|---|
| T00-P00 - Preparacao Documental | Completo | Docs, contratos, design pending e prompts definidos |
| T00-P01 - Inicializacao Godot | Completo | `project.godot`, boot minimo, validate, GUT |
| T00-P02A - Supabase Base Standalone | Completo | migration MVP, healthcheck, Deno standalone verde |
| T00-P02B - Supabase Runtime Local | Completo | Docker Desktop local, Supabase CLI via `npx` 2.100.1, Deno via `npx` 2.7.14 |
| T00-P03 - Fundacao Reutilizavel Do Cliente | Completo | `.gutconfig`, autoloads, content generator, validate integrado |
| T00-P04 - Fixtures MVP E Catalogo Gerado | Completo | `data/definitions/*.json`, `mvp_training_battle`, catalogo `.tres` |
| T00-P05 - Conta Guest MVP | Completo | `account/guest`, `account/state`, convite `ALPHA-TEST`, RPC idempotente e estado inicial server-authoritative |
| T00-P06 - Cliente Account/Session Shell | Completo | HTTP client, `SessionStore`, token/cache local nao autoritativo e tela minima de conta |
| T00-P07 - Battle Request MVP | Completo | battle fixture server-authoritative, `battle_log_v1`, recompensa e idempotencia |
| T00-P08 - Battle Replay Client MVP | Completo | loop guest -> batalha -> resultado com replay placeholder e skip |
| T00-P09 - Gate De Design Do Primeiro Slice | Em andamento | DMOB-D001, D002, D016, D017, D024, D025 e D026 resolvidos; economia/season baseline e simulador criados |
| T00-P10 - Conteudo Real E Simulador Completo | Pendente | conteudo real e simulador completo server-side |
| T00-P11 - Base Manager E Economia | Pendente | estruturas, recursos, ledger e coleta offline |
| T00-P12 - Social, Matchmaking, Bots E Ranking | Pendente | amigos, guilda, bots, matchmaking e ranking |
| T00-P13 - Monetizacao Funcional E Alpha | Pendente | battle pass, diamante, rewards e exports smoke |

---

## Validacao Atual

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
```

Resultado local: passou com GUT integrado, `14/14` testes e `52` asserts.

Smoke client:

- Boot scene carrega em headless.
- Smoke P06 via Godot HTTPRequest: Auth anonimo -> `account/guest` -> `account/state` passou no Supabase local com player guest e build `varinha_magica`.
- Smoke P07: `battle/request` exige auth, retorna `battle_log_v1`, `battle/latest` recupera o log e repetir `request_id` nao duplica XP/Ossos.
- Smoke P08: Godot solicita batalha, formata timeline placeholder, recupera `battle/latest` e nao calcula resultado/recompensa no cliente.

Server/Supabase local:

- `npx -y deno task check`: passou em `supabase/functions` e `server/functions`.
- `npx -y deno task lint`: passou em `supabase/functions` e `server/functions`.
- `npx -y supabase db reset`: passou aplicando `202605190001_mvp_foundation.sql` e `202605190002_guest_account_mvp.sql`.
- `GET /functions/v1/healthcheck`: passou.
- `POST /functions/v1/account/guest`: convite invalido retorna `INVALID_INVITE`; convite valido cria conta; repeticao do mesmo `request_id` retorna o mesmo player.
- `GET /functions/v1/account/state`: passou e recuperou player/resources/build.
- Insert direto em `public.players` com JWT anonimo: bloqueado com `403`.

---

## Next

1. Continuar `T00-P09 - Gate De Design Do Primeiro Slice`.
2. Usar `docs/economy/README.md` e `tools/economy_simulator/` para calibrar valores de base/economia, missoes/onboarding e monetizacao antes de implementar custos/recompensas reais.
3. Resolver ou adiar as pendencias `PRIMEIRO_SLICE` restantes antes de iniciar `T00-P10`: guilda/ajudas, ranking, summons/maestria/stats/varinha, cosmeticos, chat, anuncios e conquistas.
4. Quando nao houver pendencia `PRIMEIRO_SLICE` bloqueante, iniciar `T00-P10 - Conteudo Real E Simulador Completo`.
