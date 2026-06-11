# Code Review - Track 03L Arena Seal & Character Facing V2

- Date: `2026-06-11`
- Reviewer: Claude (Fable 5)
- Scope: commits `9e24da7..2160d8b`. Incidente de fechamento #6 (truncamento) tratado no ritual; worktree limpo. Commit `4bf4906` preservou os docs de Claude - regra anti-perda funcionando.

## Arena - APROVADA com evidencia forte

- **TDD duplo com numeros**: teste de estanqueidade capturou `7014 raycasts escapando` antes do fix (amostras em y=7.25 - exatamente o vao 7.2->8.8) e o teste de tunneling capturou a bola a 34 m/s atravessando os paineis novos e parando FORA da arena (z=+-29.1) antes do CCD. Ambos vermelhos documentados, ambos PASS agora. Guardas permanentes: grade 0.25m em todas as faces + 20 lancamentos de tunneling.
- **Rampas/rodape**: zero ocorrencias de `_add_corner_ramps`/`_add_ramp_box` - removidas por completo.
- **CCD**: `continuous_cd = true` (excecao de fisica autorizada por Fabio; massa/bounce/drag intactos).
- **Screenshots verificados por Claude**: (1) perimetro superior selado - vidro continuo ate o teto com frame emissivo na juncao; (2) painel frontal acima da travessa instalado - o "caixote" virou parede de vidro emoldurada da trave ao teto; (3) canto simples sem rampa, com quina limpa de vidro. Os tres batem com o especificado.

## Facing - implementacao correta, EVIDENCIA INCOMPLETA

- Codigo verificado: `update_visual_movement_facing` gira o no VISUAL (`part_root`) por `lerp_angle` para o yaw da velocidade em espaco de mundo, compensando o yaw logico do pai (`target_world_yaw - logical_parent_yaw`) - exatamente o design pedido; mira/camera/chute intactos (regressao de chute PASS); threshold de velocidade e toggle presentes.
- **Lacunas**: (a) NAO ha teste automatizado de facing (mover +X -> yaw do avatar a +-15 graus, e o caso "costas para a camera"); (b) a FASE de Gameplay Evidence foi cumprida PELA METADE: faltam a sequencia de 4 frames da corrida em curva, o frame "costas para a camera" e o rebote no antigo vao; (c) `docs/playtest-reports/track-03l-arena.md` NAO foi criado.
- A metade ausente da evidencia e justamente a do item que Fabio reportou (facing). Sem ela, a aprovacao do facing depende 100% do playtest manual - o que o protocolo novo existe para evitar.

## Verdict

**Arena: aprovada. Facing: aprovacao condicionada a evidencia complementar.** Necessaria mini-track 03L.1 (captura + teste, SEM tocar gameplay).

## Adendo 03L.1 - Facing Evidence (2026-06-11): FACING APROVADO

- Teste automatizado novo: `test_avatar_visual_movement_facing_tracks_velocity_axes_and_stopped_forward_pose` (eixos +X/-Z e pose parada).
- Sequencia de 4 frames da corrida em curva ANALISADA POR CLAUDE: o corpo vira progressivamente acompanhando a trajetoria (perfil -> transicao -> perfil oposto -> costas/lateral), com passada de corrida viva em todos os frames; em nenhum momento o personagem corre "olhando para a camera".
- Frame parado pos-movimento: personagem claramente DE COSTAS para a camera, de frente para o gol - criterio de orientacao base atendido.
- Rebote no antigo vao e playtest-report (`docs/playtest-reports/track-03l-arena.md`) entregues.
- **Nota estetica N2 (nao bloqueia, validar no playtest)**: nos frames, o torso do personagem le como "sem camisa" - o tint de kit sobre a textura parece fraco demais para comunicar o uniforme do pais. Candidata a proxima leva de polish (reforcar saturacao/peso do tint na regiao de roupa do traje).

**Veredito final da 03L + 03L.1: APROVADA INTEGRALMENTE.** Fila de bugs conhecidos: VAZIA (exceto L1 da defesa aerea, registrado). Proximo: playtest de confirmacao geral de Fabio -> decisao das portas (docs/next-series-options.md) + Track 03J (Quality Gates no AGENTS) quando quiser.
