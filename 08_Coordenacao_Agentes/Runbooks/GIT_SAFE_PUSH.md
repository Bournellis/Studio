# Git safe push

## Metadata

- status: `active`
- authority: `technical_runbook`
- last_verified: `2026-08-27`
- review_when: `origin, main branch, Git LFS, credentials or remote protection changes`
- supersedes: `manual GitHub Desktop synchronization policy`
- superseded_by: `none`
- push_owner: `Codex global coordinator`
- push_destination: `origin/main`
- push_url: `https://github.com/Bournellis/Studio.git`

This runbook delegates only the routine delivery of validated local commits on
`main` to the official `origin/main`. It does not authorize product publication,
release, deploy, backend mutation or any other Git ref or remote.

## Preconditions

Run from the canonical root `D:\Estudio` after local closure. Require:

- resolved root exactly `D:\Estudio`, branch exactly `main`, clean tracked and untracked state;
- upstream exactly `origin/main`, fetch URL and push URL exactly `push_url`;
- all intended work integrated and proportionally validated;
- no overlapping writer in the root and no unexpected worktree state.

## Preflight and validation

```powershell
$expectedRoot = (Resolve-Path -LiteralPath 'D:\Estudio').Path
$actualRoot = (Resolve-Path -LiteralPath (git rev-parse --show-toplevel)).Path
if ($actualRoot -ne $expectedRoot) { throw 'Unexpected repository root.' }
if ((git branch --show-current) -ne 'main') { throw 'Expected main.' }
if ((git rev-parse --abbrev-ref '@{upstream}') -ne 'origin/main') { throw 'Unexpected upstream.' }
if ((git remote get-url origin) -ne 'https://github.com/Bournellis/Studio.git') { throw 'Unexpected fetch URL.' }
if ((git remote get-url --push origin) -ne 'https://github.com/Bournellis/Studio.git') { throw 'Unexpected push URL.' }
if (@(git status --porcelain=v1).Count -ne 0) { throw 'Root is not clean.' }

git fetch --no-tags origin refs/heads/main:refs/remotes/origin/main
if ($LASTEXITCODE -ne 0) { throw 'Exact fetch failed.' }
git merge-base --is-ancestor origin/main main
if ($LASTEXITCODE -ne 0) { throw 'origin/main is not an ancestor of main.' }
$counts = @(git rev-list --left-right --count origin/main...main) -split '\s+'
if ([int]$counts[0] -ne 0) { throw 'Local main is behind origin/main.' }

.\tools\validate_estudio.ps1 -Profile DocsOnly -Project AllOfficial
if ($LASTEXITCODE -ne 0) { throw 'DocsOnly validation failed.' }
```

`pull` is never used. An unexpected remote advance, divergence or validation
failure stops the flow; do not reconcile it automatically.

## Git LFS gate

```powershell
$lfsAttributes = @(git grep -n -E 'filter[= ]lfs' main -- ':(glob)**/.gitattributes' 2>$null)
$lfsPointers = @(foreach ($commit in git rev-list origin/main..main) {
  git grep -l -F 'version https://git-lfs.github.com/spec/v1' $commit -- 2>$null
})
$requiresLfs = ($lfsAttributes.Count -gt 0) -or ($lfsPointers.Count -gt 0)
if ($requiresLfs) {
  git lfs version
  git lfs status
  $lfsHook = git rev-parse --git-path hooks/pre-push
  if (-not (Test-Path -LiteralPath $lfsHook) -or
      -not (Select-String -LiteralPath $lfsHook -SimpleMatch 'git lfs pre-push' -Quiet)) {
    throw 'Git LFS is required but the pre-push hook is unavailable.'
  }
}
```

LFS absence blocks only when attributes or outgoing pointers require it.

## Push and proof

```powershell
git -c push.followTags=false push --porcelain origin refs/heads/main:refs/heads/main
if ($LASTEXITCODE -ne 0) { throw 'Push failed.' }

$remoteOid = ((git ls-remote --exit-code --heads origin refs/heads/main) -split '\s+')[0]
$trackingOid = git rev-parse origin/main
$headOid = git rev-parse HEAD
if ($remoteOid -ne $trackingOid -or $remoteOid -ne $headOid) {
  throw 'Remote, tracking ref and HEAD do not match.'
}
```

If `main` has no commits ahead, skip the push and prove the same equality.
Record `git_sync_status: pushed_verified@<full-oid>` independently from product
publication.

## Stop conditions

Stop and preserve local commits on fetch, authentication, fast-forward,
validation, LFS/hook, push or verification failure. Never use `pull`, force,
force-with-lease, `--no-verify`, `--all`, `--tags`, `--mirror`, `--delete`,
credential changes, login/PAT, another branch/ref or another remote.
