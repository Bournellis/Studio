# Playtest Report - Track 04C Stadium Visual Upgrade V1

- Data: 2026-06-11
- Projeto: `Projetos/JogoDaCopa`
- Branch local: `codex/JogoDaCopa/track04c-stadium-visual-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04c-stadium-visual-v1`
- Build alvo: pre-release web publish, antes dos modos pos-lancamento

## Escopo Validado

- Arquibancadas profundas com 3+ aneis, recuo, altura, mureta frontal e corredores.
- Torcida usando as duas cores de kit da partida.
- Shader/material de torcida com `crowd_excitement` e metodo `set_crowd_excitement`.
- Teloes maiores e mais legiveis.
- Bandeiroes com nomes de paises.
- Mastros com bandeiras simples animadas por shader.
- Halos sutis nos refletores sem novas luzes.
- Skyline low-poly barato atras do vidro.
- Budget web sem luz nova com sombra.

## Evidencias Capturadas

- `docs/screenshots/track-04c-stadium-visual-v1/01-lateral-deep-stands.png` - lateral mostrando arquibancadas profundas.
- `docs/screenshots/track-04c-stadium-visual-v1/02-behind-goal-scoreboards.png` - atras do gol com teloes.
- `docs/screenshots/track-04c-stadium-visual-v1/03-high-diagonal-skyline.png` - alto diagonal com horizonte.
- `docs/screenshots/track-04c-stadium-visual-v1/04-field-level-crowd.png` - nivel do campo mostrando torcida.
- `docs/screenshots/track-04c-stadium-visual-v1/05-crowd-excitement-1.png` - torcida com `crowd_excitement=1.0`.
- `docs/screenshots/track-04c-stadium-visual-v1/06-uniform-edge-before-hard.png` - borda do uniforme antes do teste.
- `docs/screenshots/track-04c-stadium-visual-v1/07-uniform-edge-after-soft.png` - borda do uniforme durante teste local revertido.

## Resultado Visual

PASS com observacoes:

- A massa do estadio ficou mais profunda e presente sem aumentar custo de luz/sombra.
- A leitura da torcida melhora pelo uso das cores dos dois kits e pela variacao de fase por bloco.
- Os teloes estao maiores e o enquadramento atras do gol mostra melhor o placar.
- O skyline preenche o vazio atras do vidro com custo baixo.
- O frame de `crowd_excitement=1.0` registra o estado excitado, mas o ganho e mais perceptivel em movimento por causa da onda e emissive do shader.

## Suavizacao De Borda Do Uniforme

O teste opcional de suavizacao em `gameplay/avatar/avatar_uniform.gdshader` nao apresentou melhoria objetiva nas screenshots antes/depois. A alteracao foi revertida e a branch final nao altera o shader do avatar.

## Performance

Comando executado em janela 1080p:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --path . -s res://tools/performance_sample.gd --label=track04c-stadium-visual-v1
```

Resultado:

- Media: 728.8fps.
- Minimo aquecido instantaneo: 452.3fps.
- Frames abaixo de 60fps: 0/360.
- Display: Windows, windowed 1920x1080.

Budget web: PASS para o proxy desktop solicitado (`avg > 300fps`).

## Validacao Automatizada

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Resultado: PASS, 77 testes, 1128 asserts.

## Riscos E Integracao

- `football_root` nao foi editado por coexistir com a 04D. O root ainda precisa passar as cores reais dos kits e disparar o `crowd_excitement` em eventos de gol.
- O upgrade usa geometria barata e shaders/emissive; ainda assim, Fabio deve aprovar visualmente antes do merge.
- Nenhuma operacao remota de git foi feita.
