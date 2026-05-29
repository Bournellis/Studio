# DraxosMobile - Battle Preparation Complete v1

- Status: `PUBLICADO_INTERNAL_ALPHA`
- Data: `2026-05-29`
- Pacote anterior: `docs/battle-preparation-v1.md`

## Resumo

Battle Preparation Complete v1 transforma a Preparacao do Refugio de um painel explicativo em um editor real de loadout antes da batalha.

O jogador deve conseguir ver e alterar, antes de pedir uma batalha:

- Instrumento Ritual;
- Habilidades equipadas;
- Doutrina;
- Familiar;
- Pocao equipada;
- comportamento basico de pocao e habilidades.

## Escopo

O pacote implementa loadout real, com UI no cliente e contrato servidor, sem criar uma nova rota visual fora do Refugio.

Fica fora deste pacote:

- previsao de vitoria;
- recomendacao contra oponente;
- tuning numerico;
- economia nova;
- armas, spells, doutrinas, familiares ou pocoes novas;
- comportamento por inimigo;
- prioridades avancadas;
- thresholds customizados.

## Contratos

O endpoint `POST /build/equip`, ja documentado no contrato do primeiro slice, foi implementado para alterar o loadout do save ativo.

O cliente envia apenas intencao de equipamento. O servidor valida item, nivel, disponibilidade, duplicidade e recalcula o poder do jogador.

`GET /build/state` continua sendo o ponto de leitura da preparacao e passa a oferecer dados humanizados suficientes para a UI nao depender de ids crus.

Campos vivos no pacote:

- `weapon`: equipa Instrumento Ritual e qualidade quando enviada;
- `spell_slots`: equipa ou remove habilidades nas posicoes 1, 2 e 3;
- `passive_id`: equipa ou remove Doutrina;
- `pet_id`: equipa ou remove Familiar;
- `player.power` e `combat_build.power`: recalculados pelo servidor apos sucesso.

## UX

A Preparacao permanece dentro do Refugio pelo hotspot `Preparacao`.

O painel deve destacar:

- resumo `Pronto para batalha`;
- poder atual;
- item equipado em cada area;
- itens disponiveis;
- itens bloqueados por nivel;
- CTA de batalha perto do resumo.

Textos publicos devem usar `Instrumento Ritual`, `Habilidade`, `Doutrina`, `Familiar` e `Pocao`.

## Validacao Esperada

Validacao local/remota executada em 2026-05-29:

- `npx -y deno check server/functions/build/index.ts supabase/functions/build/index.ts server/tests/build_equip_smoke.ts`: PASS.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts`: PASS.
- `tools/validate.gd`: PASS, 121 testes client.
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `supabase functions deploy build`: PASS remoto.
- `server/tests/build_equip_smoke.ts`: PASS remoto contra Supabase Internal Alpha.
- `tools/smoke_foundation_surfaces.gd`: BLOQUEADO localmente sem Supabase local em `127.0.0.1:54321`.
- `git diff --check`: PASS.

## Publicacao

Publicacao Internal Alpha concluida em 2026-05-29.

- Release root: `internal-alpha/v0-battle-preparation-complete-v1-20260529`.
- Web preview publico verificado: `https://17ea0fa1.draxos-mobile-internal-alpha.pages.dev/web`.
- Stable Pages: `https://draxos-mobile-internal-alpha.pages.dev` continua atras de Cloudflare Access para checagens anonimas.
- Web asset root: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-complete-v1-20260529/web`.
- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-complete-v1-20260529/downloads/draxos-mobile-alpha.apk`.
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-complete-v1-20260529/downloads/draxos-mobile-alpha.zip`.

Observacoes de release:

- `assets/referenciaimagens/**` foi excluido dos presets exportados porque e moodboard/documentacao visual, nao runtime. Isso reduziu os artefatos para APK `31649813` bytes, PC ZIP `40118021` bytes e Web PCK `4247020` bytes, evitando o erro remoto `Payload too large`.
- O bucket `draxos-internal-alpha` e o bucket privado espelho tiveram `file_size_limit` ajustado para `209715200` bytes por configuracao remota de release.
- `publish_internal_alpha.ps1 -Mode DeployManifest` ficou bloqueado por falta de `SUPABASE_ACCESS_TOKEN`; o pacote Cloudflare publicado usa `portal/manifest.example.json` embutido com os links e hashes corretos.
- HEAD remoto passou para `index.pck`, `index.wasm`, APK e ZIP no release root versionado.
