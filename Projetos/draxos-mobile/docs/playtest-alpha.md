# DraxosMobile - Alpha Playtest Checklist

- Ultima atualizacao: `2026-05-20`
- Alvo Track 01: PC local com Supabase local.

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
5. Solicitar uma batalha `FIRST_SLICE_SIM`.
6. Assistir o replay por alguns eventos e testar `Pular replay`.
7. Voltar para o Refugio e abrir Base.
8. Coletar Base e tentar upgrade inicial, observando erro controlado se faltar Energia.
9. Abrir Social, criar guilda alpha e enviar mensagem de guilda.
10. Abrir Competicao, consultar matchmaking e ranking.
11. Abrir Loja, consultar Battle Pass, coletar recompensa disponivel e testar compra alpha quando aplicavel.
12. Testar indisponibilidade de rede/Supabase e confirmar erro claro sem travar UI.
13. Usar `Resetar sessao local` apenas para recuperar o ambiente de teste.

## Template De Feedback

```text
Data:
Build/commit:
Plataforma:
Supabase resetado antes do teste? sim/nao

Fluxo testado:
- Guest:
- Batalha/replay:
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
