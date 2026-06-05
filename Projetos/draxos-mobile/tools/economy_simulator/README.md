# Economy Simulator

Baseline calibravel para a economia de seasons do DraxosMobile.

## Fonte De Verdade

- `economy_model.v1.json`: inputs versionados de recursos, seasons, perfis, fontes e custos.
- `generate.ts`: gerador Deno/TypeScript.

## Rodar

```powershell
cd D:\Estudio-worktrees\draxos-mobile--<agent>--<slug>\Projetos\draxos-mobile
npx -y deno run --allow-read --allow-write tools/economy_simulator/generate.ts
```

## Saidas

O gerador escreve em `docs/economy/generated/`:

- `season_economy_summary.json`
- `season_economy_daily.csv`
- `season_economy_profiles.csv`
- `season_economy_checks.csv`
- `draxos_mobile_economy_simulator.xlsx`

## Regras

- Edite o JSON, nao os arquivos gerados.
- Valores numericos sao `CALIBRAVEL_ALPHA`.
- O workbook e saida de leitura; ele pode ser aberto no Excel/LibreOffice para inspecao e discussao.
- Todos os levels sao permanentes e compartilham o cap configurado da season.
