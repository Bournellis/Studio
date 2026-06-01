# DraxosMobile - Alpha Playtest Checklist

- Ultima atualizacao: `2026-05-31`
- Alvo Track 19: Internal Alpha com Arena PVE inicial e Supabase local/remoto aprovado para teste.

## Pre-Flight

- Supabase local esta rodando em `http://127.0.0.1:54321`.
- Funcoes Edge estao servidas localmente.
- Banco foi resetado para baseline alpha quando necessario.
- Godot abre o projeto em `4.6.2-stable`.
- O testador sabe usar `ALPHA-TEST` como convite guest.

## Roteiro Do Playtest

1. Abrir o jogo no PC local.
2. Entrar como guest usando `ALPHA-TEST`.
3. Conferir se o Refugio mostra conta, recursos e `session_id` local.
4. Usar `Sincronizar sessao` e confirmar que o estado volta sem duplicar progresso.
5. Abrir Arena PVE e conferir se a lista vem do servidor, com arenas liberadas e bloqueadas.
6. Iniciar o tutorial de 1 duelo, confirmar loadout travado e resolver o duelo.
7. Assistir o replay por alguns eventos e testar `Pular replay`.
8. Confirmar o resumo da tentativa, lembrando que a recompensa ja foi aplicada no ultimo duelo.
9. Iniciar a arena curta de 3 duelos, escolher buff entre duelos e testar preparacao/comportamento antes do proximo inimigo.
10. Conferir consumo de Pocao de Vida quando equipada e com estoque disponivel.
11. Voltar para o Refugio, abrir Base, coletar Base e tentar upgrade inicial.
12. Abrir Social, Loja e Competicao apenas como modos secundarios/dev, sem tratar PVP como loop inicial.
13. Testar indisponibilidade de rede/Supabase e confirmar erro claro sem travar UI.
14. Usar `Resetar sessao local` apenas para recuperar o ambiente de teste.

## Template De Feedback

```text
Data:
Build/commit:
Plataforma:
Supabase resetado antes do teste? sim/nao

Fluxo testado:
- Guest:
- Arena PVE/replay:
- Pocao/preparacao:
- Base:
- Social/guilda/chat:
- Competicao/ranking:
- Loja/rewards:
- Reset local:

Problemas encontrados:
1.
2.
3.

Momentos confusos:
1.
2.

Erros/offline:
- Mensagem exibida:
- Acao que causou:
- Recuperou sem reiniciar? sim/nao

Sensacao geral:
- Ritmo:
- Clareza:
- Estabilidade:
- Prioridade para corrigir:
```

## Notas De Escopo

- Nao calibrar XP, Energia, poder, combate, guilda ou Diamante diretamente a partir de um unico relato.
- Nao adicionar novos modos durante o playtest Track 01.
- Itens `POS_SLICE` e expansoes de plataforma devem abrir sessao de design antes de qualquer codigo.
