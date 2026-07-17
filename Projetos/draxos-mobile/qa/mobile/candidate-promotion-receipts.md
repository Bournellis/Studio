# Recibos imutáveis de candidato, qualificação e promoção

## Metadata

- status: `living`
- authority: `technical_contract`
- last_verified: `2026-07-17`
- review_when: `artifact, release plan, evidence or publication contracts change`
- supersedes: `artifact identity inferred from filename or build directory`
- superseded_by: `none`

Um candidato é o conteúdo de um artefato, identificado por SHA256, e não o nome do arquivo ou a pasta de build. Qualificação e promoção sempre referenciam esse conteúdo; nunca recompilam.

## Candidate receipt v1

O recibo `draxos_mobile_candidate_receipt_v1` é criado somente em uma tarefa `CandidatePrepare` autorizada, depois do artefato existir. Campos obrigatórios:

- `receipt_schema`, `created_at_utc`, `project`, `channel` e `source_sha`;
- `artifact.kind`, `artifact.relative_path`, `artifact.bytes` e `artifact.sha256`;
- `artifact.export_preset`, `artifact.export_mode` e `artifact.release_keystore_mode` sem segredo;
- `android.resolved_min_sdk`, `resolved_target_sdk`, `resolved_compile_sdk`, `architectures` e `orientation` quando o artefato for Android;
- `toolchain.godot_version` e versões locais relevantes;
- `validation` com IDs, resultados, report hashes e snapshot Git;
- `remote_mutation: false`, `published: false` e `human_product_gate_approved: false`.

`build/internal-alpha/release-artifacts.json` e `SHA256SUMS.txt` podem fornecer o hash inicial, mas o recibo rehasha o artefato. Um hash copiado sem arquivo presente é inválido. O schema é `schemas/candidate-receipt.schema.json`.

## Qualification receipt v1

O recibo `draxos_mobile_qualification_receipt_v1` registra `VisualCheck`, `AndroidCheck` ou `PhysicalGate` contra o candidato e o APK exatos. Ele contém:

- hash e path relativo do recibo de candidato;
- `artifact_sha256` e `artifact_reverified_sha256` idênticos;
- tipo, resultado, perfis, executor e evidências locais por hash;
- `rebuild_performed: false`, `publication_executed: false` e `remote_mutation: false`.

`PhysicalGate` exige a identidade de um tester humano; agentes e automação não podem emitir esse veredito. Evidência alterada invalida a verificação. O schema é `schemas/qualification-receipt.schema.json`.

## Promotion receipt v1

O recibo `draxos_mobile_promotion_receipt_v1` prepara uma decisão separada sem publicar. Campos obrigatórios:

- `receipt_schema`, `created_at_utc`, `candidate_receipt_sha256` e `artifact_sha256`;
- `artifact_reverified_sha256`, que deve ser igual a `artifact_sha256`;
- recibos `android_check` e `physical_gate` aprovados, ambos ligados ao mesmo candidato e artefato;
- `decision_reference`, `authorized_by`, `promotion_target` e status `recorded_local_only`;
- `rebuild_performed: false`, `publication_executed: false` e `remote_mutation: false`;
- `supersedes_receipt_sha256` somente quando um novo recibo corrige outro sem apagá-lo.

O autorizador deve ser o responsável humano pela decisão. O recibo não contém comando de build, URL assinada, token ou credencial. Ele é apenas um registro local e não promove release.

Uma publicação futura, se autorizada em outra tarefa, consome o mesmo hash e produz evidência própria. O schema é `schemas/promotion-receipt.schema.json`.

## Helper tipado e dry-run

`../../tools/mobile_candidate_receipts.py` valida os três schemas em runtime e rehasha todas as referências locais. Ele não chama subprocesso, rede, build, export, instalação ou publicação.

O padrão é dry-run; somente `--write` cria um recibo append-only.

```powershell
python tools/mobile_candidate_receipts.py candidate --help
python tools/mobile_candidate_receipts.py qualify --help
python tools/mobile_candidate_receipts.py promotion --help
python tools/mobile_candidate_receipts.py verify --help
```

`candidate` exige APK existente, source SHA, SDKs resolvidos, snapshot Git e reports verdes. `qualify` exige o mesmo APK e evidência por hash.

`promotion` exige decisão humana resolvida e recibos aprovados de Android e físico. `verify` percorre candidato, artefato, reports, qualificações e evidências sem escrever.

## Imutabilidade e armazenamento

- Durante preparação local, usar `build/qa/mobile/candidates/<artifact_sha256>/`, `qualifications/<artifact_sha256>/` e `promotions/<artifact_sha256>/<target>/`; esses outputs não são autoridade rastreada.
- Qualificações e promoções usam o SHA256 do próprio recibo no nome. Repetir conteúdo idêntico não escreve; conteúdo diferente nunca sobrescreve um path existente.
- Quando uma evidência precisar ser preservada, copiar o bundle para `qa/evidence/<task-id>/` com manifesto `estudio_evidence_v1`, conforme a governança global.
- Depois de referenciado, um recibo é append-only. Correção cria novo recibo e aponta `supersedes_receipt_sha256`; nunca sobrescreve o original.
- Paths no recibo são relativos ao projeto. Secrets, paths absolutos, serial de aparelho e dados pessoais são proibidos.

## Falhas bloqueantes

- artefato ausente ou hash divergente;
- source SHA desconhecido, worktree suja não declarada ou validação sem identidade;
- SDK/arquitetura/orientação Android não resolvidos no candidato;
- tentativa de rebuild entre candidato, AndroidCheck, PhysicalGate e preparação de promoção;
- promoção sem decisão humana exigida ou qualquer tentativa de remoto/publicação no mesmo passo documental.
