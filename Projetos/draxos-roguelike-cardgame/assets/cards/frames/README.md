# Card Frames

Frames esperados no V1:

- `frame_arcano.png`
- `frame_invocador.png`
- `frame_necromante.png`
- `frame_elemental.png`
- `frame_neutral.png`

Formato esperado final: `512x768`, PNG com transparencia. O frame e aplicado como overlay sobre a carta somente quando `overlay_safe` estiver ativo no manifesto visual.

Divida visual V1:

- `frame_arcano.png` tem transparencia, mas ainda precisa ser normalizado para `512x768`.
- `frame_invocador.png` e `frame_necromante.png` nao tem alpha confiavel; a UI usa fallback de borda/cor ate os PNGs transparentes serem substituidos.
- `frame_elemental.png` e `frame_neutral.png` ainda precisam ser adicionados.
