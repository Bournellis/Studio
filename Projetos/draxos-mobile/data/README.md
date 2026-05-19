# data/

Definicoes de conteudo em JSON e resources Godot gerados.

- `definitions/` - fonte autorada dos contratos de conteudo.
- `generated/` - resources Godot produzidos por ferramentas locais, nao editar manualmente.
- `resources/` - scripts de Resource usados pelo catalogo gerado.

Fluxo atual:

```text
definitions/*.json -> tools/content_generator.gd -> generated/draxos_mobile_catalog.tres
```

Fixtures `MVP_ONLY` sao tecnicas e nao representam balanceamento final.
