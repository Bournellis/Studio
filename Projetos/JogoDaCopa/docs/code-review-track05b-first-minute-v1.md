# Code Review PRE-MERGE - Track 05B First-Minute Smoothness V1

- Date: `2026-06-12`
- Reviewer: Claude (Fable 5)
- Branch: `codex/jogodacopa/track05b-first-minute-v1`
- Veredito tecnico: **APROVADA**. Veredito de produto: **CONDICIONADO A DECISAO DE FABIO** sobre o corte de feedback sensorial no Web (ja publicado na v1.0.2).

## Tecnica: red -> green exemplar

- RED reproduzido de verdade (lacuna da 05A fechada): 10-18 hitches > 100ms no primeiro minuto, max `2194.8ms`, maioria colada em `web_warmup.chunk` (vidro/estandes/torcida/banners) rodando DEPOIS do overlay sair - exatamente o relato humano de "partes aparecendo uma por uma".
- Hipotese nova confirmada: warmup util no Web exige render/emissao real dentro do frustum com camera ativa, coberto por overlay opaco (C8-C11 da 04F.2 nao foram repetidos).
- Overlay agora so sai apos: warmup incremental completo (incl. sombras/decorativos) + first-use feedback warmup + janela de estabilizacao < 33ms.
- Descoberta extra relevante: `AudioStreamPlayer3D` era a origem dos erros `PositionWorklet` no Chrome - caminho Web nao cria mais pool 3D (audio 3D fora do Web; 2D permanece).
- Resultado por evento (chute forte, gol+confetti, SUPER+fireball, jump pad, result, rematch): RED com hitches -> `0/0` local E remoto.
- Gates: primeiro minuto local/remoto PASS (0 hitches, 0 runtime errors), estabilidade 5min local/remoto PASS, luminancia PASS (58.8-75.4 < 90), validate 86/1272 PASS, export PASS, publicacao v1.0.2 PASS (`web/v1-copa-arena-futebol-20260612-ad82384b`).

## DECISAO DE PRODUTO PENDENTE (Fabio)

Para zerar os hitches, o Web publico PERDEU nesta release o feedback transiente de: chute, gol (CONFETTI), jump pad, result, countdown e APITO. Permanecem: arena, sombras, gameplay, bola, fireball/trail, HUD, musica/jingles/ambience. O jogo esta mais estavel E mais seco sensorialmente - trade-off tomado pelo Codex documentado com transparencia, mas que excede o mandato tecnico da track e ja esta em producao. Opcoes mapeadas no chat; recomendacao da review: manter v1.0.2 estavel e reintroduzir efeitos um a um (apito e confetti primeiro) em follow-up 05B.1 com budget por efeito e gate de 0 hitches mantido.

## Observacoes

- O1: teto de loading local primeira visita FAIL (13.5-13.7s vs 8s) - POREM o remoto/producao real ficou em 5.2s PASS; o caso local-frio nao representa o jogador da URL publica. Aceitavel com registro.
- O2: anomalia local pior que remoto provavelmente por cache de shader/ambiente do harness - nao investigada a fundo; nao bloqueia.
- O3: duracao do thread (~10h) explicada pelos artefatos: `pass19`/`pass3` denunciam ~19+ iteracoes do gate de primeiro minuto + multiplos gates de 5min + 2 smokes remotos longos + publicacao. Custo legitimo de tentativa-e-erro com gates caros. REGRA DE PROCESSO NOVA recomendada: iterar com gate curto (60s) e rodar gates longos apenas na validacao final; checkpoint a cada 10 iteracoes sem verde (parar e reportar hipoteses ao humano).

## Pos-decisao

Merge local + card Done + PUSH PENDENTE independem da decisao (o ar ja e v1.0.2). Se Fabio escolher reintroduzir efeitos: Track 05B.1 - Sensory Feedback Re-Introduction (um efeito por vez, budget medido, gate 0 hitches, republicacao).
