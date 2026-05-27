# Track 03 - Internal Alpha v0

- Status: `COMPLETE - T03-P18_HANDOFF_READY`
- Projeto: `draxos-mobile`
- Objetivo: transformar o alpha local em uma build fechada, realista e multiplataforma para 2 testadores, com conta email/senha, saves compartilhados entre Android/PC/Web, backend remoto de baixo custo, base jogavel, social basico, ranking, loja proof-of-concept, batalha visual atual preservada e iteracao rapida de updates.

## Problema

Track 00 provou a fundacao tecnica, Track 01 endureceu o alpha local e Track 02 criou laboratorios de progressao/batalha. O projeto agora precisa deixar de ser apenas um conjunto de provas locais e passar a se comportar como um jogo fechado real:

- um jogador cria ou entra em uma conta;
- o mesmo progresso aparece em Android, PC e Web;
- o servidor remoto e autoritativo para progresso, recursos, batalha, base, social, ranking e loja;
- o Progression Lab continua disponivel para criar estados customizados, mas isolado do save normal;
- builds internas podem ser publicadas e atualizadas com frequencia sem destruir a organizacao do projeto;
- o teste fechado precisa gerar evidencia de estabilidade, clareza de fluxo e lacunas de design.

## Decisoes Confirmadas

- Conta: email + senha via Supabase Auth.
- Email confirmation: desativado no alpha interno para reduzir atrito.
- Acesso: link Web pode ser publico/unlisted, mas o jogo precisa exigir login e convite/flag alpha antes de expor save ou acoes.
- Saves: cada conta tem dois saves separados:
  - `normal`: progresso real do jogo interno.
  - `progression_lab`: estado custom para testes e cenarios avancados.
- Reset: cada save pode ser resetado separadamente.
- Progression Lab: ferramenta interna exportada/gated, aplicando somente no save `progression_lab`.
- Progressao normal: comeca free; a loja tera redeem de coins/Diamante/produtos alpha para testar niveis premium.
- Loja: proof-of-concept funcional, sem balance final e sem gateway real.
- Competicao: leaderboards basicas e bots podem contar pontos no alpha interno se isso ajudar a testar fluxo.
- Backend remoto: Supabase Free primeiro; upgrade apenas se pausas/limites atrapalharem o teste.
- Updates: Android, PC e Web devem receber updates na mesma cadencia.
- Distribuicao/updates: usar Supabase Storage para downloads binarios e host estatico externo para Portal/Web; manifest vive em Edge Function `release/manifest`.
- Android: usar keystore dedicada de Internal Alpha.
- Plataformas: Android nativo, PC executavel e PC browser. iOS e mobile browser seguem fora do escopo.

## Entregas

- Documentacao da fase, plano de implementacao, runbook e checklist de playtest.
- Auth email/senha com convite/flag alpha.
- Modelo de dois saves por conta, com reset separado e isolamento server-side.
- Progression Lab aplicado ao save `progression_lab`, sem contaminar ranking/social normal.
- Base Manager com predios do gameplay, upgrades, coleta, menus e estados suficientes para playtest.
- Social basico funcional: amigos, guilda, chat/polling e feedback de erro/sucesso.
- Competicao com matchmaking e leaderboards basicas visiveis.
- Loja proof-of-concept: redeem alpha, Battle Pass/premium alpha e pacotes de recursos/Diamante.
- Tela de update/version check consultando manifest remoto.
- Empacotamento de builds Android/PC/Web e instrucoes manuais para publicacao interna.
- Testes/smokes cobrindo auth/save, dual save, base, social, ranking, loja, batalha e manifest.
- Registros de portfolio atualizados para a nova fase.

## Fora Do Escopo

- Pagamento real.
- Ads reais.
- Anti-cheat completo de producao alem das regras server-authoritative ja definidas.
- Loja balanceada para publico.
- Arte final, animacoes finalizadas, VFX importado ou icones definitivos.
- Open World, Hero Defense, PVE pos-slice ou Cardgame Roguelike mobile.
- iOS.
- Mobile browser.
- Promessas de SLA, autoscaling ou observabilidade de producao.

## Principios

- O cliente Godot nunca calcula resultado de batalha, recursos finais, ranking ou recompensa.
- Toda mutacao economica passa por Edge Function com idempotencia e ledger.
- `service_role` nunca entra no cliente, export, Web build ou arquivo versionado.
- Web build pode ser acessivel por URL, mas conteudo de save e acoes exigem auth/alpha flag.
- Save `progression_lab` nunca deve afetar ranking publico, social normal ou economia do save normal.
- O alpha interno deve ser rapido de iterar, mas cada shortcut precisa estar documentado como alpha-only.
- Quando faltar decisao de produto/design, registrar em `docs/design-pending.md` antes de implementar.

## Criterios De Aceite

- Dois usuarios reais conseguem criar/login com email e senha em Android, PC e Web.
- O mesmo save `normal` aparece corretamente nas tres plataformas.
- O save `progression_lab` pode ser resetado/aplicado sem alterar o save `normal`.
- Base permite acessar predios, iniciar upgrade, concluir/coletar ou receber erro controlado conforme recursos.
- Social permite pelo menos amigo/guilda/chat em fluxo fechado de teste.
- Competicao mostra leaderboard basica e atualiza pontos de forma server-authoritative.
- Loja permite redeem alpha e estado premium/Diamante aparece no save correto.
- Batalha continua usando o mockup visual atual e `battle_log_v1` sem simulacao client-side.
- Web, PC e Android conseguem verificar uma versao remota e exibir quando ha update recomendado/obrigatorio.
- Checklist de playtest interno roda de ponta a ponta em pelo menos 2 contas.
- Worktree fica limpa e commits separados registram preparacao, implementacao e validacao.

## Sinais De Pronto Para Teste Fechado

- Supabase remoto com anon key publica configurada e service role apenas em ambiente seguro.
- Email confirmation desligado no projeto alpha.
- Convite/flag alpha criado para os dois testadores.
- Buckets de Storage para manifests/builds configurados conforme runbook.
- Keystore Android internal alpha criada e guardada fora do Git.
- Build Web publicada em URL conhecida, sem secrets privilegiados.
- PC zip e APK publicados no Storage ou canal interno definido.
- `docs/playtest-internal-alpha-v0.md` preenchido com commit/build testado.
