.PHONY: validate lint test

validate: lint test

lint:
	shellcheck scripts/*.sh tests/*.sh
	actionlint

test:
	tests/changed-services.test.sh
