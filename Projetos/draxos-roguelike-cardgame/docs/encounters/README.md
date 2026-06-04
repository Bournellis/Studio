# Encontros - Indice

- Last Updated: `2026-05-27`
- Status: `Track 02 29-map route implemented and validated`
- Referencia: `../game-design-document.md`

## Proposito

Este diretorio registra notas de encontro. O estado vivo dos encontros esta no JSON (`data/definitions/slice_catalog.json`) e no contrato validado pela Track 02.

## Rota Atual

Track 02 usa uma rota linear fixa de 29 mapas:

- Terra: mapas 1-8.
- Gelo: mapas 9-15.
- Ar: mapas 16-22.
- Fogo: mapas 23-29.

Os modos cobertos sao `limpar_mesa`, `ondas`, `duelo`, `defesa_posicao`, `sobreviver_turnos`, `emboscada`, `escolta`, `invasao` e `chefe_summoner`.

Os formatos cobertos sao `padrao`, `assimetrico`, `nucleo_central`, `flanco`, `frente_retaguarda` e `abismo`.

Field effects e boss hooks fazem parte do contrato de encontro. Chefes nos mapas 8, 15, 22 e 29 possuem summons e intent/hook phases declarados.

## Validacao

A validacao local checa:

- 29 nos lineares com unlock encadeado;
- reward schedule de 29 mapas;
- cobertura de modos, formatos, field effects e boss hooks;
- smoke de rota completa pelo simulador compartilhado;
- Run Lab por classe/seed para comparacao de tuning.

## Material Historico

Arquivos individuais de encontros criados durante Track 01 podem conter mapas, valores e recompensas antigos. Use-os apenas como contexto historico ou comparativo quando estiverem marcados como tal.

## Proximo Passo

Playtest humano da rota Track 02 completa usando `../playtest-track-02.md`.
