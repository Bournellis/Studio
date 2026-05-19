# Track 00 - First Slice Foundation

- Last Updated: `2026-05-19`
- Track Status: `OPEN - preparacao documental concluida`
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
- `implementation-plan.md` - sequencia completa T00-P00 a T00-P11.
- `implementation-prompts.md` - prompts atomicos para agentes.

---

## Status Dos Passos

| Passo | Status | Saida |
|---|---|---|
| T00-P00 - Preparacao Documental | Completo | Docs, contratos, design pending e prompts definidos |
| T00-P01 - Inicializacao Godot | Pendente | `project.godot`, boot minimo, validate, GUT |
| T00-P02 - Supabase Base | Pendente | migrations minimas e healthcheck |
| T00-P03 - Conta Guest MVP | Pendente | convite + guest |
| T00-P04 - Battle Request MVP | Pendente | battle fixture server-authoritative |
| T00-P05 - Cliente MVP | Pendente | loop guest -> batalha -> resultado |
| T00-P06 a T00-P11 | Pendente | primeiro slice completo |

---

## Next

Executar T00-P01 conforme `implementation-prompts.md`.
