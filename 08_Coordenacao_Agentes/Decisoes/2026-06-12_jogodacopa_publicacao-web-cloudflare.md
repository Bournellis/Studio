# Decisao: Publicar Copa Arena Futebol Na Web Antes Da Track 04F.3

## Metadata

- data: `2026-06-12`
- decisor: `Usuario`
- projeto: `jogodacopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`

## Contexto

A Track 04F.2 resolveu o bloqueio de publicacao (primeiro render Web `19.5s -> 4.23s`). Restou um residual de smoothness: hitch unico de ate `1.3s` no primeiro uso de confetti/VFX/audio por sessao (Track 04F.3 proposta). O evento da Copa esta acontecendo agora; cada dia sem link publico e audiencia perdida.

## Decision

- Publicar a build web publica ANTES de atacar a 04F.3. O hitch de primeiro uso por sessao e aceito e documentado como limitacao conhecida do release inicial.
- Plataforma: Cloudflare Pages, projeto novo `copa-arena-futebol`, publico, SEM Cloudflare Access (diferente do draxos-mobile, que e alpha fechado).
- Pipeline no padrao do estudo ja validado no mobile: script com `Mode Plan` default, `Mode Package` local, e modos remotos exigindo `-ConfirmRemoteMutation`. Esta decisao autoriza explicitamente a primeira publicacao remota da Track 05.
- `Track 04F.3 - VFX/Audio First-Use Warmup` fica adiada, registrada como proxima candidata pos-publicacao.

## Alternatives Considered

- Atacar 04F.3 antes: rejeitado; as 4 abordagens obvias ja falharam por medicao, o tempo de solucao e incerto e o evento e agora.
- itch.io: valido para alcance organico; fica como possivel segundo canal depois. Cloudflare venceu por pipeline ja dominado e URL propria imediata.

## Impact

O jogo ganha URL publica compartilhavel durante a Copa. O residual de VFX/audio vira backlog explicito em vez de bloqueio.

## Review When

Apos feedback dos primeiros jogadores, ou ao decidir a Track 04F.3, ou se a Copa terminar e o produto mudar de fase.
