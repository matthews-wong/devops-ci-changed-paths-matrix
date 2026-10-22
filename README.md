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
