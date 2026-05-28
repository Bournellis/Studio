# DraxosMobile - Track 11 Manual Walkthrough

- Data: `2026-05-28`
- Objetivo: validar a experiencia real das builds publicadas antes de abrir feature nova.
- Plataformas: Android APK, PC Windows ZIP, Web via Cloudflare Access ou preview liberado.

## Preparacao

- Usar uma conta alpha por email/senha.
- Confirmar manifest remoto: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`.
- Se usar o dominio estavel do Cloudflare Pages, autenticar no Cloudflare Access antes de abrir Portal/Web.
- Registrar aparelho, resolucao, orientacao e plataforma em cada problema.

## Roteiro

1. Abrir Portal e conferir links de APK/PC/Web.
2. Abrir app em plataforma alvo.
3. Criar conta ou entrar com email/senha.
4. Confirmar que o save normal carrega sem erro.
5. No Refugio, verificar leitura de HUD, hotspots e popups/drawers.
6. Executar coleta/energia/Loja quando houver recurso suficiente.
7. Abrir Social e Competicao, confirmar estados vazios e ranking sem travar.
8. Iniciar batalha, assistir alguns segundos, usar `Pular batalha`.
9. No summary, conferir resultado minimo e abrir logs.
10. Voltar ao Refugio.
11. Abrir Conta, checar update gate e dados de sessao.
12. Alternar para Progression Lab somente para validar isolamento, sem esperar ranking.

## Criterios De Falha Bloqueante

- Nao consegue logar/criar conta.
- Save normal nao carrega.
- Refugio fica fora da tela ou sem acao principal.
- Batalha nao inicia, nao finaliza ou summary/logs quebram.
- APK/ZIP/Web publicados nao correspondem ao manifest.
- Web estavel falha sem deixar claro que e Cloudflare Access.

## Saida Esperada

Registrar feedback em backlog ou nova track com:

- plataforma;
- build/link usado;
- passos de reproducao;
- resultado esperado;
- resultado observado;
- screenshot/video quando possivel;
- severidade: bloqueante, alto, medio, baixo.
