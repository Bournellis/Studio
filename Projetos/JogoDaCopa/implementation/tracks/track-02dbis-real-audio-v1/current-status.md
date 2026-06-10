# Track 02D-bis - Real Audio V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_02DBIS_REAL_AUDIO_V1_COMPLETE`

## Goal

Substituir os tons sinteticos genericos do feedback por sons reais baixados manualmente por Fabio, mantendo apito sintetico como excecao controlada e preservando performance.

## Delivered

- `default_bus_layout.tres` com buses `SFX`, `UI` e `Ambience`, apontado em `project.godot`.
- `FpsFeedbackController` carrega streams reais de Kenney/Pixabay, cria pools de `AudioStreamPlayer3D` e `AudioStreamPlayer`, e inicia loop de estadio.
- Sons reais ligados a chute, chute forte, quique, vidro, pickup, jump pad, countdown, gol, torcida, jingle de vitoria/derrota e confetti.
- Menu principal ganhou sliders separados para Master, SFX, UI e Ambiente, com sons reais de navegacao.
- Ambiencia faz ducking durante intro/menu e boost temporario em gol.
- Apito continua sintetico, isolado em `play_referee_whistle()` e contabilizado por debug.

## Validation

- `tools/validate.gd` PASS: 48 tests, 459 asserts.
- Performance sample Windows/Forward+ headless: average `145.4fps`, min warmed instant `124.0fps`, `0/360` frames below 60.

## Notes

- Os arquivos `.import` seguem ignorados pela regra atual do projeto; o import headless/editor recria a cache local.
- Licencas e origem dos packs usados em runtime foram registradas em `docs/asset-licenses.md`.
