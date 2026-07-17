# Provenance prospectiva de assets

## Metadata

- status: living
- authority: operational_contract
- last_verified: 2026-07-17
- review_when: requisitos de licenca, IA, storage ou publicacao mudar
- supersedes: none
- superseded_by: none

## Escopo

Este contrato vale prospectivamente para assets binarios ou gerados adicionados ao runtime depois de 2026-07-17. Ele nao exige migracao mecanica do acervo historico.

Quando um asset historico for substituido, relicenciado, modificado materialmente ou preparado para publicacao, a nova versao entra no contrato.

## Registro obrigatorio

O projeto receptor mantem um registro local por asset ou por familia indivisivel, baseado em `08_Coordenacao_Agentes/Templates/Asset_Provenance_TEMPLATE.md`.

O registro identifica:

- asset ID, project, path literal, tamanho e SHA-256;
- origem verificavel e responsavel pela incorporacao;
- ferramenta, modelo, versao e prompt ou referencia, quando aplicavel;
- transformacoes executadas entre fonte e runtime;
- licenca, termos, restricoes e evidencias locais;
- uso permitido separado para runtime, marketing, modificacao e publicacao;
- status tecnico, visual, de direitos e de publicacao;
- data, reviewer e proximo momento de revisao.

Uma URL e apenas referencia; ela nao substitui copia local dos termos ou recibo quando estes forem necessarios para provar uso permitido.

## Inventario prospectivo

O inventario local deve conseguir relacionar cada asset novo ao registro de provenance por `asset_id` e path. O hash identifica o arquivo observado, nao a intencao do asset.

Alteracao de bytes exige novo hash e descricao da transformacao. Substituicao silenciosa sob o mesmo path e proibida quando o asset ja sustenta evidencia, decisao ou candidato de release.

## Estados independentes

- `technical_status`: integracao e validacao local.
- `visual_status`: referencia, mockup, polish ou decisao humana.
- `rights_status`: `unknown`, `review_pending`, `allowed_for_scope` ou `rejected`.
- `publication_status`: inicia em `not_reviewed` e so muda por decisao humana identificavel.

Integracao tecnica nao concede direito de uso. Aprovacao visual nao concede publicacao. Uso interno nao implica uso comercial ou marketing.

## Hard stops

- origem ou termos incompatíveis com o uso pretendido;
- segredo, dado pessoal, watermark ou marca sem autorizacao;
- hash divergente da evidencia ou do recibo;
- arquivo fora do path previsto, binario ambiguo ou diff inesperado;
- pedido para inferir revisao legal, aprovacao final ou publicacao.

O asset pode permanecer como referencia interna com risco registrado somente quando isso for permitido e nao for confundido com arte publicavel.
