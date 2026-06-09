# Aprendizado: Drift Em Documentos De Agente

- Data: `2026-06-09`
- Area: coordenacao de agentes

## Problema

Guias antigos continuavam descrevendo projetos pausados como se fossem rotas ativas. Isso cria risco de um agente abrir contexto errado, selecionar projeto errado ou tratar historico como canon atual.

## Sinais De Alerta

- Root README com status antigo.
- Guias em `materiais/guides/` que contradizem `Prioridades_Estudio.md`.
- Templates que citam pacote antigo como "latest".
- Proximo passo antigo ainda aparecendo em `Estado_Atual.md` ou `Projetos/README.md`.

## Regra

A autoridade operacional do Estudio e:

1. `08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `AGENTS.md`
3. `Projetos/README.md`
4. `08_Coordenacao_Agentes/Estado_Atual.md`
5. docs locais do projeto permitido

Guias historicos devem apontar para guias atuais, nao competir com eles.

## Validacao Recomendada

Use `rg` para procurar nomes de pacotes antigos, decisoes antigas e frases como `latest`, `proximo passo`, `Projetos ativos` e `current`.
