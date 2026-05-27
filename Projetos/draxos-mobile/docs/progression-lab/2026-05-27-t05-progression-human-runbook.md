# Progression Lab - T05 Human Review Runbook

- Data: 2026-05-27
- Track: `Track 05 - Foundation Stabilization And Asset/Service Readiness`
- Pacote: `T05-F Progression Human Pack`
- Status: `READY_TO_RUN`

Este runbook prepara a rodada humana do Progression Lab antes de qualquer tuning numerico. Ele cobre os perfis `free_100_rewards`, `freemium_basic`, `spender_light` e `max_spender` nos milestones `2h`, `5h`, `10h`, `15h` e `20h`.

## Guardrails

- Nao alterar numeros de economia, poder, bots, loja, recompensas, recursos ou combate durante esta rodada.
- Usar somente o save `progression_lab`; nunca aplicar healthy save no save `normal`.
- Nao publicar remoto, nao rodar migration e nao mudar manifest remoto.
- Se a rodada indicar ajuste, abrir tarefa separada de tuning com before/after, Battle Lab e Progression Lab.

## Artefatos De Entrada

Ler ou regenerar antes da rodada:

- `docs/progression-lab/generated/progression_report.html`
- `docs/progression-lab/generated/milestone_profiles.csv`
- `docs/progression-lab/generated/premium_gap.csv`
- `docs/progression-lab/generated/reward_scaling_checks.csv`
- `docs/progression-lab/generated/power_recommendations.csv`
- `docs/progression-lab/generated/bot_pool.csv`

Comandos seguros:

```powershell
cd D:\Estudio-worktrees\draxos-mobile--codex--t05-progression-human-pack\Projetos\draxos-mobile
npx -y deno test tools/progression_lab
npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts
npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-progression-human-pack\Projetos\draxos-mobile -s res://tools/smoke_dev_labs.gd
```

## Casos Obrigatorios De Foco

Rodar estes casos mesmo se a rodada for curta:

| Caso | Alerta de entrada | Pergunta humana |
|---|---|---|
| `spender_light_10h` | Premium gap `39.53%` vs `free_100_rewards_10h` | Gasto leve parece conforto ou poder obrigatorio cedo demais? |
| `max_spender_10h` | Premium gap `52.14%` vs `free_100_rewards_10h` | Teto pago aos `10h` quebra expectativa de justica? |
| `max_spender_20h` | Premium gap `38.8%`, `+2` levels vs free ativo | Teto pago aos `20h` fica acelerado mas ainda pareavel? |
| `free_100_rewards_20h` | Level `17` contra janela alvo `18-36` | Free ativo parece abaixo da janela ou ainda com objetivo claro? |
| `freemium_basic_20h` | Level `17` contra janela alvo `18-36` | Passe + segunda fila melhoram conforto sem resolver XP direto? |

## Matriz Completa

| Caso | Baseline | Status tecnico | Foco da observacao |
|---|---|---|---|
| `free_100_rewards_2h` | L8 / P738 | `PASS` | Primeiro ritmo free ativo, clareza de proximo objetivo. |
| `free_100_rewards_5h` | L11 / P1459 | `PASS` | Se a progressao free ja mostra build/base com direcao. |
| `free_100_rewards_10h` | L14 / P1943 | `PASS` | Referencia para gaps premium de `10h`. |
| `free_100_rewards_15h` | L16 / P2609 | `PASS` | Ponte para leitura da janela `20h`. |
| `free_100_rewards_20h` | L17 / P2786 | `REVIEW` | Caso obrigatorio: aceitar L17 ou exigir L18. |
| `freemium_basic_2h` | L9 / P809 | `PASS` | Passe e segunda fila devem parecer conforto, nao obrigacao. |
| `freemium_basic_5h` | L11 / P1483 | `PASS` | Verificar se energia/base nao apertam cedo. |
| `freemium_basic_10h` | L14 / P2083 | `PASS` | Comparar com free ativo sem gasto leve extra. |
| `freemium_basic_15h` | L16 / P2751 | `PASS` | Conferir se segunda fila ainda e beneficio liquido. |
| `freemium_basic_20h` | L17 / P2969 | `REVIEW` | Caso obrigatorio: janela `20h` e pressao de energia. |
| `spender_light_2h` | L9 / P877 | `PASS` | Gasto leve nao deve virar atalho obrigatorio de inicio. |
| `spender_light_5h` | L12 / P1715 | `PASS` | Checar se loja acelera com objetivo claro. |
| `spender_light_10h` | L15 / P2711 | `PASS` com gap `REVIEW` | Caso obrigatorio: premium gap de `10h`. |
| `spender_light_15h` | L16 / P2928 | `PASS` | Se o gap volta a parecer saudavel. |
| `spender_light_20h` | L18 / P3325 | `PASS` | Comparar com free/freemium em L17. |
| `max_spender_2h` | L9 / P995 | `PASS` | Stress inicial: nao deve invalidar free. |
| `max_spender_5h` | L12 / P1857 | `PASS` | Teto pago ainda precisa de pareamento plausivel. |
| `max_spender_10h` | L15 / P2956 | `PASS` com gap `REVIEW` | Caso obrigatorio: maior alerta premium. |
| `max_spender_15h` | L17 / P3453 | `PASS` | Aceleracao alta, mas sem alerta tecnico. |
| `max_spender_20h` | L19 / P3867 | `PASS` com gap `REVIEW` | Caso obrigatorio: teto de `20h` e qualidade de arma. |

Guardrail opcional se houver tempo: `free_50_rewards_15h` e `free_50_rewards_20h`, apenas para separar free casual de free ativo.

## Ordem Recomendada

1. Rodada de calibracao curta: `free_100_rewards_2h`, `freemium_basic_2h`, `spender_light_2h`, `max_spender_2h`.
2. Rodada de ritmo inicial: todos os perfis em `5h`.
3. Rodada premium obrigatoria: `free_100_rewards_10h`, `freemium_basic_10h`, `spender_light_10h`, `max_spender_10h`.
4. Rodada ponte: todos os perfis em `15h`.
5. Rodada de janela final: todos os perfis em `20h`, com foco em free/freemium e max.

Se houver pouco tempo, executar primeiro os cinco casos obrigatorios e depois completar as linhas restantes.

## Checklist Por Caso

Para cada caso da matriz:

1. Abrir o app em ambiente local/dev.
2. Entrar com conta guest ou email/senha local de teste.
3. Alternar para o save `Progression Lab`.
4. Abrir `Refugio -> Progression Lab Dev`.
5. Selecionar `profile_id` e `milestone_id` do caso.
6. Usar `Aplicar no Save Lab` quando houver sessao real local, ou `Preparar Save Local` somente para inspecao read-only.
7. Confirmar que o Hub mostra profile/milestone corretos, level e poder proximos ao baseline da matriz.
8. Abrir Batalha e rodar uma batalha `FIRST_SLICE_SIM`.
9. Registrar se a batalha parece facil, justa, dificil ou opressiva para o poder exibido.
10. Abrir Base e conferir se o proximo upgrade e claro, desejavel e compreensivel.
11. Abrir Loja/Passe e registrar se premium parece conforto, pressao ou obrigacao.
12. Abrir Competicao ou preview de matchmaking quando disponivel e observar se existe oponente plausivel.
13. Registrar gargalo principal: XP, energia, almas, sangue, cristais, ossos, diamante, fila, poder, bot ou clareza.
14. Dar nota humana: `PASS`, `REVIEW` ou `BLOCKED`.

## Ficha De Registro

Copiar uma linha por caso:

| Campo | Valor |
|---|---|
| Caso | `<profile_id>_<milestone_id>` |
| Ambiente | local / local-only cache / Supabase local |
| Aplicacao do save | server-backed / local-only |
| Level/poder visto | `L? / P?` |
| Batalha | facil / justa / dificil / opressiva |
| Proximo upgrade | claro / confuso / sem objetivo |
| Recursos | confortaveis / apertados / bloqueados |
| Premium | conforto / pressao / obrigacao / nao aplicavel |
| Bots/matchmaking | bom / salto de banda / sem ponte |
| Vontade de continuar | alta / media / baixa |
| Status humano | `PASS` / `REVIEW` / `BLOCKED` |
| Nota curta | texto livre |

## Criterios De Decisao

### Premium Gap

Usar `premium_gap.csv` como gatilho tecnico, mas decidir pela sensacao humana.

Aceitar sem tuning se:

- `spender_light_10h` parece acelerar conforto sem invalidar `free_100_rewards_10h`;
- `max_spender_10h` e `max_spender_20h` exigem pareamento mais alto, mas nao parecem invenciveis contra bots/players de poder proximo;
- a Loja/Passe comunica valor como tempo, previsibilidade ou conveniencia, nao poder exclusivo acima do cap.

Abrir tarefa de tuning se:

- dois revisores ou duas repeticoes marcarem `spender_light_10h` ou `max_spender_10h` como `BLOCKED` por pay-to-win;
- o teto pago nao encontra oponente plausivel sem destruir a leitura de poder;
- free ativo em `10h` parece obsoleto logo apos comparar com premium.

Possivel decisao intermediaria:

- manter numeros e exigir regra de pareamento/bots por banda antes de mexer em economia.

### Janela 20h

Entrada tecnica atual: `free_100_rewards_20h` e `freemium_basic_20h` chegam a L17, um level abaixo da janela alvo L18.

Aceitar L17 se:

- o jogador entende o proximo objetivo;
- ha upgrade desejavel em Base/build;
- a batalha ainda parece justa;
- a sensacao e de "quase L18" e nao de estagnacao.

Abrir tarefa de tuning ou revisao de target se:

- ambos os casos free/freemium `20h` parecem travados;
- L18 for confirmado como requisito de produto para `20h`;
- a falta de level reduz claramente acesso a build, bot pool ou satisfacao.

Se L17 for aceitavel, ajustar o target do lab em tarefa separada e preservar este runbook como evidencia historica.

### Bots Ponte

Entrada tecnica atual: bots usam offsets aproximados `-12%`, `0%` e `+12%`, com transicao sensivel entre `band_004` e `band_005` nos milestones medios.

Aceitar pool atual se:

- cada caso de foco encontra pelo menos um oponente facil/justo e um desafio compreensivel;
- a mudanca `band_004` -> `band_005` nao parece um salto abrupto;
- bots continuam fora da leaderboard publica e fora do save `progression_lab`.

Abrir tarefa de bots ponte se:

- `spender_light_10h`, `max_spender_10h` ou `max_spender_20h` nao tiverem oponente plausivel;
- o bot de `0%` parece longe demais na pratica;
- a solucao mais simples for preencher limite de banda em vez de alterar pesos de poder.

Nao alterar formula de poder antes de testar bots ponte quando o problema for pareamento.

### Recursos

Entrada tecnica atual: `resource_debt` esta `PASS` com `0` em todos os saves.

Aceitar recursos se:

- o proximo upgrade e visivel e desejavel;
- segunda fila em `freemium_basic` e `spender_light` parece conforto liquido;
- `max_spender_20h` com qualidade de arma `1` ainda tem objetivo futuro claro.

Abrir tarefa de tuning se:

- energia vira punicao por usar segunda fila;
- o jogador tem recursos sobrando mas sem objetivo claro;
- ossos/qualidade de arma em `max_spender_20h` parecem sink sem recompensa legivel;
- free/freemium `20h` sentem atraso por recurso, nao por escolha.

### Pesos De Poder

Entrada tecnica atual: todos os componentes de poder estao `PASS`.

Manter pesos se:

- lutas de poder proximo parecem proximas no Godot;
- builds Familiar/Funeral em `10h-20h` parecem equivalentes em leitura;
- Battle Lab continua concordando com o Progression Lab.

Abrir tarefa de tuning de pesos se:

- o mesmo poder exibido gera diferenca grande de dificuldade entre arquetipos;
- `spell_level` domina a sensacao alem do que o Battle Lab aceita;
- pet/familiar, defesa ou status mental parecem subavaliados em matchups de poder proximo.

Qualquer mudanca de peso exige nova rodada Battle Lab + Progression Lab, com comparacao before/after.

## Resultado Esperado Do Handoff

Ao fim da rodada, entregar:

- status humano por caso da matriz;
- decisao de premium gap: `KEEP`, `MATCHMAKING_FIRST` ou `TUNING_NEEDED`;
- decisao de janela `20h`: `ACCEPT_L17`, `REQUIRE_L18` ou `REVISE_TARGET`;
- decisao de bots: `KEEP_POOL` ou `ADD_BRIDGE_BOTS`;
- decisao de recursos: `KEEP_RESOURCES` ou `TUNING_NEEDED`;
- decisao de poder: `KEEP_WEIGHTS` ou `BATTLE_LAB_POWER_REVIEW`;
- lista de tarefas numericas separadas, se houver.

Sem esse handoff, nao iniciar tuning numerico.
