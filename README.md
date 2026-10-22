# devops-ci-changed-paths-matrix

A GitHub Actions setup for small monorepos: work out which `services/*`
directories a push or pull request touched, and run CI only for those.

The detection lives in a plain shell script (`scripts/changed-services.sh`) so
it can be tested locally without Actions.

## Layout

```
services/<name>/Makefile   # each service exposes a `test` target
scripts/changed-services.sh
tests/changed-services.test.sh
.github/workflows/ci.yml
```

## Usage

```bash
scripts/changed-services.sh origin/main HEAD
# ["api","worker"]
```

The output is a compact JSON array, ready for `fromJSON` in a job matrix.

## How the workflow decides what to run

| Event | Diff base |
| --- | --- |
| `pull_request` | the PR base sha |
| `push` | `github.event.before` |
| first push to a branch | none, so every service is tested |

The `detect` job needs `fetch-depth: 0` because the three-dot diff looks up the
merge base. Event values are passed through `env:` rather than interpolated
into the shell, so branch names and shas cannot inject commands.

When no service changed the `test` job is skipped. Skipped jobs report as
passing to branch protection, but matrix jobs get per-service names, so
require `scripts` and `detect` rather than `test`.

## Validate

```bash
make validate   # needs shellcheck and actionlint on PATH
```

Actions are pinned by full commit sha, permissions default to read-only, and
a new push cancels the stale pull request run.
