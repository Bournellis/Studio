# DraxosMobile - Internal Alpha v0 Playtest Checklist

- Ultima atualizacao: `2026-05-26`
- Alvo: Android + PC executavel + PC browser com backend remoto.
- Testadores: Fabio + 1 amigo.

## Pre-Flight

- Commit/build registrado.
- Supabase remoto ativo.
- Email confirmation desligado.
- Convites/flags alpha prontos.
- Web URL publicada.
- APK e PC build disponiveis.
- Manifest remoto publicado.
- Duas contas de teste criadas ou prontas para cadastro.
- `service_role` nao aparece no cliente/export.
- Keystore Android internal alpha guardada fora do Git.

## Roteiro Principal

1. Abrir Web e criar/login com email + senha.
2. Confirmar que o save `normal` foi criado.
3. Fechar Web e abrir PC com a mesma conta.
4. Confirmar que o mesmo save aparece.
5. Abrir Android com a mesma conta.
6. Confirmar que o mesmo save aparece.
7. Solicitar batalha e assistir replay ate o fim ou pular.
8. Conferir recompensa/resultado no servidor via UI.
9. Abrir Base.
10. Selecionar predios no mapa, conferir tooltip/detalhe, comprar Energia alpha se necessario, iniciar upgrade e verificar feedback.
11. Abrir Loja.
12. Usar um redeem alpha e confirmar recurso/premium.
13. Abrir Competicao.
14. Ver matchmaking, iniciar batalha e conferir leaderboard.
15. Abrir Social.
16. Adicionar o outro testador, criar/entrar em guilda e enviar mensagem.
17. Alternar para save `progression_lab`.
18. Aplicar ou carregar um estado de Progression Lab.
19. Confirmar que o save `normal` nao mudou.
20. Resetar apenas `progression_lab`.
21. Confirmar que o save `normal` continua intacto.
22. Testar manifest de update com versao atual.
23. Simular versao desatualizada quando ferramenta existir.

## Teste De Erros

- Senha errada.
- Convite invalido.
- Rede offline.
- Upgrade sem recurso.
- Fila cheia.
- Chat sem guilda.
- Redeem ja usado ou invalido.
- Batalha com servidor indisponivel.
- Save lab tentando acao bloqueada.

## Feedback Por Sistema

```text
Data:
Commit/build:
Plataforma:
Conta:
Save testado: normal/progression_lab

Conta/login:
- Funcionou?
- Alguma mensagem confusa?

Cross-platform:
- O save apareceu igual?
- Alguma diferenca entre Web/PC/Android?

Batalha:
- Replay claro?
- Cooldowns/tooltips/dano entendiveis?
- Resultado/recompensa confiavel?

Base:
- Predios claros?
- Foi facil entender custo, tempo, producao e motivo de bloqueio?
- Upgrade/coleta funcionaram?
- Erros foram objetivos?

Social:
- Amigo/guilda/chat funcionaram?
- Algo parece inseguro ou confuso?

Competicao:
- Leaderboard clara?
- Pontos fizeram sentido?
- Bots apareceram como esperado?

Loja:
- Redeem funcionou?
- Premium/recursos ficaram claros?
- Algum risco de parecer compra real?

Progression Lab:
- Ficou claro que era save separado?
- Reset isolado funcionou?

Update:
- Manifest foi lido?
- Mensagem de update clara?

Bugs:
1.
2.
3.

Prioridade da proxima correcao:
```

## Criterio De Sucesso Do Playtest

- Dois testadores entram em pelo menos duas plataformas cada.
- Uma batalha real e uma acao de base funcionam por conta.
- Social e leaderboard sao acessados pelos dois testadores.
- Loja redeem altera somente o save esperado.
- Progression Lab nao contamina save normal.
- Nenhum erro exige apagar arquivos manualmente para continuar.
