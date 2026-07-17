# JogoDaCopa — linhagem única de releases

## Metadata

- status: `active`
- authority: `historical_record`
- last_verified: `2026-07-17`
- review_when: `ocorrer pacote, tentativa, rollback, supersessão, promoção ou aprovação humana de release`
- supersedes: `release-history cumulativo pré-Documentation Lite v2`
- superseded_by: `none`

Este é o único registro local de releases, release roots, tentativas, rollbacks e aprovações de `Copa Arena Futebol` / `Super Campeao`.

Estado técnico atual vive em `../implementation/current-status.md`. Processo de pacote vive em `publication-readiness.md`. Evidência bruta permanece em `playtest-reports/`.

## Estado preservado

- URL pública estável: `https://copa-arena-futebol.pages.dev/`.
- Baseline humana vigente: Track 10D, `Super Campeao v1.2.1+45da58b1`.
- Fallback humano anterior: Track 10A, `Super Campeao v1.2.1+fc3c72bb`.
- Fallbacks aprovados mais antigos: 09S, 09Q, 09P, 09N, 09I e 09H.
- Publicação, domínio, promoção e rollback continuam atos humanos; este documento apenas registra eventos já ocorridos.

## Convenções de resultado

- `HUMAN_APPROVED`: gates técnicos e reteste humano registrados.
- `REMOTE_GATES_PASS`: publicação validada por automação, sem inferir aprovação humana.
- `ROLLED_BACK`: tentativa retirada e fallback explicitamente restaurado.
- `SUPERSEDED_UNAPPROVED`: automação passou, mas outra release a substituiu antes de aprovação humana.
- `HISTORICAL_PUBLIC`: publicação real preservada sem evidência de aprovação humana explícita nas autoridades curadas.

## Linhagem cronológica

| Data | Candidato e release root | Resultado |
|---|---|---|
| 2026-06-12 | Web Publication V1 · `web/v1-copa-arena-futebol-20260612-31e23ea3` | `HISTORICAL_PUBLIC`; primeiro pacote Pages Brotli. |
| 2026-06-12 | 05A `v1.0.1+a850045a` · `web/v1-copa-arena-futebol-20260612-a850045a` | `HISTORICAL_PUBLIC`; stability hotfix. |
| 2026-06-12 | 05B `v1.0.2+ad82384b` · `web/v1-copa-arena-futebol-20260612-ad82384b` | `HISTORICAL_PUBLIC`; first-minute smoothness. |
| 2026-06-12 | 05B.1 `v1.0.3+ef9c5baa` · `web/v1-copa-arena-futebol-20260612-ef9c5baa` | `HISTORICAL_PUBLIC`; sensory feedback reintroduced. |
| 2026-06-13 | 06E `v1.1.0+ea15d5dd` · `web/v1-copa-arena-futebol-20260613-ea15d5dd` | `ROLLED_BACK` para 05B.1 após AudioWorklet e heap falharem. |
| 2026-06-13 | 06F `v1.1.0+22850c06` · `web/v1-copa-arena-futebol-20260613-22850c06` | `HISTORICAL_PUBLIC`; broadcast e áudio Web estabilizados. |
| 2026-06-13 | 06G `v1.1.0+be453dc3` · `web/v1-copa-arena-futebol-20260613-be453dc3` | `HISTORICAL_PUBLIC`; countdown e restart confirmado. |
| 2026-06-14 | 07 `v1.2.0+138cf4f7` · `web/v1-copa-arena-futebol-20260614-138cf4f7` | `ROLLED_BACK` para 06G por heap remoto `+10,34%`. |
| 2026-06-14 | 07B `v1.2.0+6de8d6b7` · `web/v1-copa-arena-futebol-20260614-6de8d6b7` | `ROLLED_BACK` para 06G por falha AudioWorklet. |
| 2026-06-14 | 07C `v1.2.0+fa82cb7d` · `web/v1-copa-arena-futebol-20260614-fa82cb7d` | `HISTORICAL_PUBLIC`; fallback de áudio seguro. |
| 2026-06-14 | 08 `v1.2.1+2f537628` · `web/v1-copa-arena-futebol-20260614-2f537628` | `ROLLED_BACK` para 07C. |
| 2026-06-14 | 08A `v1.2.1+6ef3074c` · `web/v1-copa-arena-futebol-20260614-6ef3074c` | `HISTORICAL_PUBLIC`; rebrand/hotfix de UI. |
| 2026-06-15 | 09A `v1.2.1+ff9cb389` · `web/v1-copa-arena-futebol-20260615-ff9cb389` | `HISTORICAL_PUBLIC`; primeira extração FootballRoot. |
| 2026-06-15 | 09F `v1.2.1+a75cfe57` · `web/v1-copa-arena-futebol-20260615-a75cfe57` | `REMOTE_GATES_PASS`; margem de heap apertada. |
| 2026-06-15 | 09G `v1.2.1+d1784ff9` · `web/v1-copa-arena-futebol-20260615-d1784ff9` | `ROLLED_BACK` para 09F após duas falhas de heap. |
| 2026-06-15 | 09H `v1.2.1+4a323fab` · `web/v1-copa-arena-futebol-20260615-4a323fab` | `HUMAN_APPROVED`; heap passou com margem estreita. |
| 2026-06-16 | 09I `v1.2.1+7995b06c` · `web/v1-copa-arena-futebol-20260616-7995b06c` | `HUMAN_APPROVED`; Kick/SUPER controller. |
| 2026-06-19 | 09J `v1.2.1+4678fbea` · `web/v1-copa-arena-futebol-20260619-4678fbea` | `ROLLED_BACK` para 09I após heap falhar duas vezes. |
| 2026-06-19 | 09K `v1.2.1+70a8ccd5` · `web/v1-copa-arena-futebol-20260619-70a8ccd5` | `ROLLED_BACK` para 09I após novo heap fail. |
| 2026-06-19 | 09N `v1.2.1+5c6520ba` · `web/v1-copa-arena-futebol-20260619-5c6520ba` | `HUMAN_APPROVED`; reteste Fabio/tester em 2026-06-19. |
| 2026-06-19 | 09P `v1.2.1+8863c5b9` · `web/v1-copa-arena-futebol-20260619-8863c5b9` | `HUMAN_APPROVED`; reteste Fabio/tester em 2026-06-19. |
| 2026-06-19 | 09Q `v1.2.1+bb604c77` · `web/v1-copa-arena-futebol-20260619-bb604c77` | `HUMAN_APPROVED`; fallback atrás de 09S. |
| 2026-06-20 | 09R `v1.2.1+33ba1a2b` · `web/v1-copa-arena-futebol-20260619-33ba1a2b` | `SUPERSEDED_UNAPPROVED` por 09S. |
| 2026-06-20 | 09S `v1.2.1+925f3b9f` · `web/v1-copa-arena-futebol-20260620-925f3b9f` | `HUMAN_APPROVED`; reteste em 2026-06-20. |
| 2026-06-20 | 10A `v1.2.1+fc3c72bb` · `web/v1-copa-arena-futebol-20260620-fc3c72bb` | `HUMAN_APPROVED`; fallback anterior vigente. |
| 2026-06-20 | 10B `v1.2.1+317999b0` · `web/v1-copa-arena-futebol-20260620-317999b0` | `ROLLED_BACK` para 10A após heap remoto `+13,85%`. |
| 2026-06-20 | 10C `v1.2.1+39054f31` · `web/v1-copa-arena-futebol-20260620-39054f31` | `SUPERSEDED_UNAPPROVED` por feedback humano fraco. |
| 2026-06-20 | 10D `v1.2.1+45da58b1` · `web/v1-copa-arena-futebol-20260620-45da58b1` | `HUMAN_APPROVED` em 2026-06-25; baseline vigente. |

## Correções dentro de uma mesma release

- O primeiro root 06G, identificado por `dff246ac`, foi substituído por `be453dc3` para adiar streams de UI Web até a ativação do navegador.
- 09F teve um primeiro stability run borderline; o rerun passou com heap retido `+9,88%`. Isso não removeu o gate obrigatório de cinco minutos.
- 09H passou o gate remoto em `+9,97%`, abaixo do limite estrito de `10%`; o risco histórico de margem apertada permaneceu registrado.
- 10D manteve o áudio de gol Web desativado e promoveu apenas o golden pop visual. PC preservou o feedback completo.

## Ledger de rollbacks e supersessões

| Candidato | Motivo | Destino seguro |
|---|---|---|
| 06E `ea15d5dd` | AudioWorklet e crescimento de heap. | 05B.1 `ef9c5baa`. |
| 07 `138cf4f7` | Heap remoto acima do teto. | 06G `be453dc3`. |
| 07B `6de8d6b7` | `AbortError` no AudioWorklet. | 06G `be453dc3`. |
| 08 `2f537628` | Gate remoto não sustentou promoção. | 07C `fa82cb7d`. |
| 09G `d1784ff9` | Heap remoto falhou duas vezes. | 09F `a75cfe57`. |
| 09J `4678fbea` | Heap remoto `+15,96%` e `+15,22%`. | 09I `7995b06c`. |
| 09K `70a8ccd5` | Hotfix ainda falhou heap remoto. | 09I `7995b06c`. |
| 09R `33ba1a2b` | Percepção residual de câmera A/D. | 09S, sem tratar 09R como aprovada. |
| 10B `317999b0` | Heap remoto `+13,85%`. | 10A `fc3c72bb`. |
| 10C `39054f31` | Feedback de gol quase imperceptível no teste humano. | 10D, sem tratar 10C como aprovada. |

## Cadeia de aprovações humanas

Cada promoção abaixo substituiu a anterior como baseline e preservou a anterior como fallback histórico:

`09H → 09I → 09N → 09P → 09Q → 09S → 10A → 10D`

Não há evidência curada para chamar 09R ou 10C de baseline humana. Gates remotos verdes não promovem uma release sem decisão humana registrada.

## Índice de evidência

- Primeira publicação e estabilidade: `playtest-reports/track-05-data/`, `track-05a-data/`, `track-05b-data/`, `track-05b1-data/`.
- Broadcast e restart: `playtest-reports/track-06e-data/`, `track-06f-data/`, `track-06g-data/`.
- Visual/Web/audio: `playtest-reports/track-07-data/`, `track-07b-data/`, `track-07c-data/`.
- Rebrand: `playtest-reports/track-08-data/`, `track-08a-data/`.
- Decomposição 09: subdiretórios `playtest-reports/track-09*-data/` e relatórios Markdown 09A–09S.
- Linha 10: `playtest-reports/track-10a-data/`, `track-10b-data/`, `track-10c-data/`, `track-10d-data/`.
- Aprovações humanas pré-cutover permanecem também nos cards globais até o cutover com receipt; esta linhagem é a autoridade retida local.

JSON e PNG são a evidência de hashes, release root, menu, primeiro minuto, estabilidade, luma, rollback e confirmação da URL estável. Este documento não duplica seus payloads.

## Limitações preservadas

- Web é desktop browser single-threaded; mobile browser nunca foi superfície oficialmente suportada.
- Áudio Web automatizado aguarda ativação do usuário para evitar falhas de worklet.
- O pacote pesado completo de gol não é default Web; 10D usa golden pop visual sem áudio de gol.
- Kits e branding são genéricos/inspirados; não há logos oficiais de FIFA, Copa, federações ou clubes.
- Feel, câmera, áudio, visual e publicação futura continuam gates humanos.
