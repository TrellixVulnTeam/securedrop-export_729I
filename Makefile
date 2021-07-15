.PHONY: safety
safety: ## Runs `safety check` to check python dependencies for vulnerabilities
	pip install --upgrade safety && \
		for req_file in `find . -type f -name '*requirements.txt'`; do \
			echo "Checking file $$req_file" \
			&& safety check --full-report -r $$req_file \
			&& echo -e '\n' \
			|| exit 1; \
		done

.PHONY: update-pip-requirements
update-pip-requirements: ## Updates all Python requirements files via pip-compile.
	pip-compile --verbose --rebuild --generate-hashes --annotate --allow-unsafe --output-file "requirements/test-requirements.txt" "requirements/requirements.in" "requirements/test-requirements.in"
	pip-compile --verbose --rebuild --generate-hashes --annotate --output-file "requirements/requirements.txt" "requirements/requirements.in"

.PHONY: check
check: lint test  ## Run linter and tests

TESTS ?= tests
.PHONY: test
test:  ## Run tests
	pytest -v --cov-report html --cov-report term-missing --cov=securedrop_export $$TESTS

.PHONY: lint
lint:  ## Run linter
	flake8 securedrop_export/ tests/

# Explaination of the below shell command should it ever break.
# 1. Set the field separator to ": ##" and any make targets that might appear between : and ##
# 2. Use sed-like syntax to remove the make targets
# 3. Format the split fields into $$1) the target name (in blue) and $$2) the target descrption
# 4. Pass this file as an arg to awk
# 5. Sort it alphabetically
# 6. Format columns with colon as delimiter.
.PHONY: help
help: ## Print this message and exit.
	@printf "Makefile for developing and testing the SecureDrop export code.\n"
	@printf "Subcommands:\n\n"
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {printf "\033[36m%s\033[0m : %s\n", $$1, $$2}' $(MAKEFILE_LIST) \
		| sort \
| column -s ':' -t
