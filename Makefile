# Shell config
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Make config
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Executables
MAKE_VERSION := $(shell make --version | head -n 1 2> /dev/null)
SED := $(shell command -v sed 2> /dev/null)
SED_INPLACE := $(shell if $(SED) --version >/dev/null 2>&1; then echo "$(SED) -i"; else echo "$(SED) -i ''"; fi)
AWK := $(shell command -v awk 2> /dev/null)
POETRY := $(shell command -v poetry 2> /dev/null)
PYENV := $(shell command -v pyenv 2> /dev/null)
PYTHON := $(shell command -v python 2> /dev/null)
PYENV_ROOT := $(shell pyenv root)
GIT := $(shell command -v git 2> /dev/null)
GIT_VERSION := $(shell $(GIT) --version 2> /dev/null || echo -e "\033[31mnot installed\033[0m")
DOCKER := $(shell command -v docker 2> /dev/null)
DOCKER_VERSION := $(shell if [ -n "$(DOCKER)" ]; then $(DOCKER) --version 2> /dev/null; fi)
DOCKER_FILE := Dockerfile
DOCKER_COMPOSE := $(shell if [ -n "$(DOCKER)" ]; then command -v docker-compose 2> /dev/null || echo "$(DOCKER) compose"; fi)
DOCKER_COMPOSE_VERSION := $(shell if [ -n "$(DOCKER_COMPOSE)" ]; then $(DOCKER_COMPOSE) version 2> /dev/null; fi )

# Project variables -- change as needed before running make install
# override the defaults by setting the variables in a makefile.env file
-include Makefile.env
PROJECT_NAME ?= $(shell basename $(CURDIR))
# make sure the project name is lowercase and has no spaces
PROJECT_NAME := $(shell echo $(PROJECT_NAME) | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
PROJECT_REPO ?= $(shell url=$$($(GIT) config --get remote.origin.url); echo $${url%.git})
GITHUB_USER_NAME ?= $(shell echo $(PROJECT_REPO) | $(AWK) -F/ 'NF>=4{print $$4}')
GITHUB_USER_EMAIL ?= $(shell $(GIT) config --get user.email || echo '')
PROJECT_VERSION ?= $(shell $(POETRY) version -s 2>/dev/null || echo 0.1.0)
PROJECT_DESCRIPTION ?= 'A short description of the project'
PROJECT_LICENSE ?= MIT
PYTHON_VERSION ?= 3.12.1
PYENV_VIRTUALENV_NAME ?= venv-$(shell echo "$(PROJECT_NAME)")
PRECOMMIT_CONF ?= .pre-commit-config.yaml
DOCKER_COMPOSE_FILE ?= docker-compose.yml
DOCKER_IMAGE_NAME ?= $(PROJECT_NAME)
DOCKER_CONTAINER_NAME ?= $(PROJECT_NAME)

# Stamp files
INSTALL_STAMP := .install.stamp
PRODUCTION_STAMP := .production.stamp
DEPS_EXPORT_STAMP := .deps-export.stamp
BUILD_STAMP := .build.stamp
DOCKER_BUILD_STAMP := .docker-build.stamp
DOCS_STAMP := .docs.stamp
RELEASE_STAMP := .release.stamp
STAGING_STAMP := .staging.stamp
STAMP_FILES := $(wildcard .*.stamp)

# Dirs
SRC := $(PROJECT_NAME)
TESTS := tests
BUILD := dist
DOCS := docs
DOCS_SITE := site
CACHE_DIRS := $(wildcard .*_cache)
COVERAGE := .coverage $(wildcard coverage.*)

# Files
PY_FILES := $(shell find . -type f -name '*.py')
PROJECT_INIT := .project-init
DOCKER_FILES_TO_UPDATE := $(DOCKER_FILE) $(DOCKER_COMPOSE_FILE) entrypoint.sh
PY_FILES_TO_UPDATE := $(SRC)/__main__.py $(TESTS)/test_main.py
DOCS_FILES_TO_RESET := README.md $(DOCS)/index.md $(DOCS)/about.md

# Colors
RESET := \033[0m
RED := \033[0;31m
GREEN := \033[0;32m
ORANGE := \033[0;33m
MAGENTA := \033[0;35m
CYAN := \033[0;36m

# Intentionally left empty
ARGS ?=

#-- Info

.DEFAULT_GOAL := help
.PHONY: help
help:  ## Show this help message
	@echo -e "\n$(MAGENTA)$(PROJECT_NAME) v$(PROJECT_VERSION) Makefile$(RESET)"
	@echo -e "\n$(MAGENTA)Usage:\n$(RESET) make $(CYAN)[target]$(RESET)\n"
	@grep -E '^[0-9a-zA-Z_-]+(/?[0-9a-zA-Z_-]*)*:.*?## .*$$|(^#--)' $(firstword $(MAKEFILE_LIST)) \
	| $(AWK) 'BEGIN {FS = ":.*?## "}; {printf "\033[36m %-21s\033[0m %s\n", $$1, $$2}' \
	| $(SED) -e 's/\[36m #-- /\[35m/'

.PHONY: info
info:  ## Show development environment info
	@echo -e "$(MAGENTA)\nSystem:$(RESET)"
	@echo -e "  $(CYAN)OS:$(RESET) $(shell uname -s)"
	@echo -e "  $(CYAN)Shell:$(RESET) $(SHELL) - $(shell $(SHELL) --version | head -n 1)"
	@echo -e "  $(CYAN)Make:$(RESET) $(MAKE_VERSION)"
	@echo -e "  $(CYAN)Git:$(RESET) $(GIT_VERSION)"
	@echo -e "$(MAGENTA)Project:$(RESET)"
	@echo -e "  $(CYAN)Project name:$(RESET) $(PROJECT_NAME)"
	@echo -e "  $(CYAN)Project directory:$(RESET) $(CURDIR)"
	@echo -e "  $(CYAN)Project author:$(RESET) $(GITHUB_USER_NAME) <$(GITHUB_USER_EMAIL)>"
	@echo -e "  $(CYAN)Project repository:$(RESET) $(PROJECT_REPO)"
	@echo -e "  $(CYAN)Project version:$(RESET) $(PROJECT_VERSION)"
	@echo -e "  $(CYAN)Project license:$(RESET) $(PROJECT_LICENSE)"
	@echo -e "  $(CYAN)Project description:$(RESET) $(PROJECT_DESCRIPTION)"
	@echo -e "$(MAGENTA)Python:$(RESET)"
	@echo -e "  $(CYAN)Python version:$(RESET) $(PYTHON_VERSION)"
	@echo -e "  $(CYAN)Pyenv version:$(RESET) $(shell $(PYENV) --version || echo "$(RED)not installed $(RESET)")"
	@echo -e "  $(CYAN)Pyenv root:$(RESET) $(PYENV_ROOT)"
	@echo -e "  $(CYAN)Pyenv virtualenv name:$(RESET) $(PYENV_VIRTUALENV_NAME)"
	@echo -e "  $(CYAN)Poetry version:$(RESET) $(shell $(POETRY) --version || echo "$(RED)not installed $(RESET)")"
	@echo -e "$(MAGENTA)Docker:$(RESET)"
	@if [ -n "$(DOCKER_VERSION)" ]; then \
		echo -e "  $(CYAN)Docker:$(RESET) $(DOCKER_VERSION)"; \
	else \
		echo -e "  $(CYAN)Docker:$(RESET) $(RED)not installed $(RESET)"; \
	fi
	@if [ -n "$(DOCKER_COMPOSE_VERSION)" ]; then \
		echo -e "  $(CYAN)Docker Compose:$(RESET) $(DOCKER_COMPOSE_VERSION)"; \
	else \
		echo -e "  $(CYAN)Docker Compose:$(RESET) $(RED)not installed $(RESET)"; \
	fi
	@echo -e "  $(CYAN)Docker image name:$(RESET) $(DOCKER_IMAGE_NAME)"
	@echo -e "  $(CYAN)Docker container name:$(RESET) $(DOCKER_CONTAINER_NAME)"

# Dependencies

.PHONY: dep/git
dep/git:
	@if [ -z "$(GIT)" ]; then echo -e "$(RED)Git not found.$(RESET)" && exit 1; fi

.PHONY: dep/pyenv
dep/pyenv:
	@if [ -z "$(PYENV)" ]; then echo -e "$(RED)Pyenv not found.$(RESET)" && exit 1; fi

.PHONY: dep/python
dep/python: dep/pyenv
	@if [ -z "$(PYTHON)" ]; then echo -e "$(RED)Python not found.$(RESET)" && exit 1; fi

.PHONY: dep/poetry
dep/poetry: dep/python
	@if [ -z "$(POETRY)" ]; then echo -e "$(RED)Poetry not found.$(RESET)" && exit 1; fi

.PHONY: dep/docker
dep/docker:
	@if [ -z "$(DOCKER)" ]; then echo -e "$(RED)Docker not found.$(RESET)" && exit 1; fi

.PHONY: dep/docker-compose
dep/docker-compose:
	@if [ -z "$(DOCKER_COMPOSE)" ]; then echo -e"$(RED)Docker Compose not found.$(RESET)" && exit 1; fi

#-- System

.PHONY: clean
clean:  ## Clean the project - removes all cache dirs and stamp files
	@echo -e "$(ORANGE)\nCleaning the project...$(RESET)"
	@find . -type d -name "__pycache__" | xargs rm -rf {};
	@rm -rf $(STAMP_FILES) $(CACHE_DIRS) $(BUILD) $(DOCS_SITE) $(COVERAGE) || true
	@echo -e "$(GREEN)Project cleaned.$(RESET)"

.PHONY: reset
reset:  ## Cleans plus removes the virtual environment (use ARGS="hard" to re-initialize the project)
	@echo -e "$(RED)\nAre you sure you want to proceed with the reset (this involves wiping also the virual environment)? [y/N]: $(RESET)"
	@read -r answer; \
	case $$answer in \
		[Yy]* ) \
			$(MAKE) clean; \
			echo -e "$(ORANGE)Resetting the project...$(RESET)"; \
			rm -f .python-version > /dev/null || true ; \
			$(GIT) checkout poetry.lock > /dev/null || true ; \
			$(PYENV) virtualenv-delete -f $(PYENV_VIRTUALENV_NAME) ; \
			if [ "$(ARGS)" = "hard" ]; then \
				rm -f $(PROJECT_INIT) > /dev/null || true ; \
			fi; \
			echo -e "$(GREEN)Project reset.$(RESET)" ;; \
		* ) \
			echo -e "$(ORANGE)Project reset aborted.$(RESET)"; \
			exit 0 ;; \
	esac

.PHONY: python
python: | dep/pyenv  ## Check if Python is installed
	@if ! $(PYENV) versions | grep $(PYTHON_VERSION) > /dev/null ; then \
		echo -e "$(RED)Python version $(PYTHON_VERSION) not installed.$(RESET)"; \
		echo -e "$(RED)To install it, run '$(PYENV) install $(PYTHON_VERSION)'.$(RESET)"; \
		echo -e "$(RED)Then, re-run 'make virtualenv'.$(RESET)"; \
		exit 1 ; \
	else \
		echo -e "$(CYAN)\nPython version $(PYTHON_VERSION) available.$(RESET)"; \
	fi

.PHONY: virtualenv
virtualenv: | python  ## Check if virtualenv exists and activate it - create it if not
	@if ! $(PYENV) virtualenvs | grep $(PYENV_VIRTUALENV_NAME) > /dev/null ; then \
		echo -e "$(ORANGE)\nLocal virtualenv not found. Creating it...$(RESET)"; \
		$(PYENV) virtualenv $(PYTHON_VERSION) $(PYENV_VIRTUALENV_NAME) || exit 1; \
		echo -e "$(GREEN)Virtualenv created.$(RESET)"; \
	else \
		echo -e "$(CYAN)\nVirtualenv already created.$(RESET)"; \
	fi
	@$(PYENV) local $(PYENV_VIRTUALENV_NAME)
	@echo -e "$(GREEN)Virtualenv activated.$(RESET)"

.PHONY: poetry
poetry: | dep/poetry  ## Check if Poetry is installed
	@echo -e "$(CYAN)\n$(shell $(POETRY) --version) available.$(RESET)"

.PHONY: poetry-update
poetry-update: | dep/poetry  ## Update Poetry
	@echo -e "$(CYAN)\nUpgrading Poetry...$(RESET)"
	@$(POETRY) self update
	@echo -e "$(GREEN)Poetry upgraded.$(RESET)"

#-- Project

.PHONY: project/all
project/all: project/install project/build docs/build  ## Install and build the project, generate the documentation

.PHONY: project/install
project/install: dep/poetry $(INSTALL_STAMP)  ## Install the project for development
$(INSTALL_STAMP): pyproject.toml
	@if [ ! -f .python-version ]; then \
		echo -e "$(RED)\nVirtual environment missing. Please run 'make virtualenv' first.$(RESET)"; \
	else \
		echo -e "$(CYAN)\nInstalling project $(PROJECT_NAME)...$(RESET)"; \
		mkdir -p $(SRC) $(TESTS) $(DOCS) $(BUILD) || true ; \
		$(POETRY) install; \
		$(POETRY) lock; \
		$(POETRY) run pre-commit install; \
		if [ ! -f $(PROJECT_INIT) ]; then \
			echo -e "$(CYAN)Updating project $(PROJECT_NAME) information...$(RESET)"; \
			$(PYTHON) toml.py --name $(PROJECT_NAME) --ver $(PROJECT_VERSION) --desc $(PROJECT_DESCRIPTION) --repo $(PROJECT_REPO)  --lic $(PROJECT_LICENSE) ; \
			echo -e "$(CYAN)Creating $(PROJECT_NAME) package module...$(RESET)"; \
			mv python_pyenv_poetry_template/* $(SRC)/ ; \
			rm -rf python_pyenv_poetry_template ; \
			echo -e "$(CYAN)Updating files...$(RESET)"; \
			$(SED_INPLACE) "s/python_pyenv_poetry_template/$(PROJECT_NAME)/g" $(DOCKER_FILES_TO_UPDATE) ; \
			$(SED_INPLACE) "s/python_pyenv_poetry_template/$(PROJECT_NAME)/g" $(PY_FILES_TO_UPDATE) ; \
			$(SED_INPLACE) "s/python_pyenv_poetry_template/$(PROJECT_NAME)/g" $(DOCS)/module.md ; \
			NEW_TEXT="#$(PROJECT_NAME)\n\n$(subst ",,$(subst ',,$(PROJECT_DESCRIPTION)))"; \
			for file in $(DOCS_FILES_TO_RESET); do \
				echo -e $$NEW_TEXT > $$file; \
			done; \
			$(SED_INPLACE) "1s/.*/$$NEW_TEXT/" $(DOCS)/module.md ; \
			$(SED_INPLACE) 's|copyright: MIT License 2024|copyright: $(PROJECT_LICENSE)|g' mkdocs.yml ; \
			$(SED_INPLACE) 's|site_name: python_pyenv_poetry_template|site_name: $(PROJECT_NAME)|g' mkdocs.yml ; \
			$(SED_INPLACE) 's|site_url: https://github.com/bateman/python_pyenv_poetry_template|site_url: https:\/\/$(GITHUB_USER_NAME)\.github\.io\/$(PROJECT_NAME)|g' mkdocs.yml ; \
			$(SED_INPLACE) 's|site_description: A Python Pyenv Poetry template project.|site_description: $(subst ",,$(subst ',,$(PROJECT_DESCRIPTION)))|g' mkdocs.yml ; \
			$(SED_INPLACE) 's|site_author: Fabio Calefato <fcalefato@gmail.com>|site_author: $(GITHUB_USER_NAME) <$(GITHUB_USER_EMAIL)>|g' mkdocs.yml ; \
			$(SED_INPLACE) 's|repo_url: https://github.com/bateman/python_pyenv_poetry_template|repo_url: $(PROJECT_REPO)|g' mkdocs.yml ; \
			$(SED_INPLACE) 's|repo_name: bateman/python_pyenv_poetry_template|repo_name: $(GITHUB_USER_NAME)\/$(PROJECT_NAME)|g' mkdocs.yml ; \
			echo -e "$(GREEN)Project $(PROJECT_NAME) initialized.$(RESET)"; \
			touch $(PROJECT_INIT); \
		else \
			echo -e "$(ORANGE)Project $(PROJECT_NAME) already initialized.$(RESET)"; \
		fi; \
		echo -e "$(GREEN)Project $(PROJECT_NAME) installed for development.$(RESET)"; \
		touch $(INSTALL_STAMP); \
	fi

.PHONY: project/update
project/update: | dep/poetry project/install  ## Update the project
	@echo -e "$(CYAN)\nUpdating the project...$(RESET)"
	@$(POETRY) update
	$(POETRY) lock
	@$(POETRY) run pre-commit autoupdate
	@echo -e "$(GREEN)Project updated.$(RESET)"

.PHONY: project/run
project/run: dep/python $(INSTALL_STAMP)  ## Run the project (pass arguments with ARGS="...")
	@$(PYTHON) -m $(SRC) $(ARGS)

.PHONY: project/tests
project/tests: dep/poetry $(INSTALL_STAMP)  ## Run the tests (pass arguments with ARGS="...")
	@echo -e "$(CYAN)\nRunning the tests...$(RESET)"
	@$(POETRY) run pytest --cov $(TESTS) $(ARGS)
	@echo -e "$(GREEN)Tests passed.$(RESET)"

.PHONY: project/production
project/production: dep/poetry $(PRODUCTION_STAMP)  ## Install the project for production
$(PRODUCTION_STAMP): $(INSTALL_STAMP) $(UPDATE_STAMP)
	@echo -e "$(CYAN)\Install project for production...$(RESET)"
	@$(POETRY) install --only main --no-interaction
	@touch $(PRODUCTION_STAMP)
	@echo -e "$(GREEN)Project installed for production.$(RESET)"

.PHONY: project/deps-export
project/deps-export: dep/poetry $(DEPS_EXPORT_STAMP)  ## Export the project's dependencies
$(DEPS_EXPORT_STAMP): pyproject.toml
	@echo -e "$(CYAN)\nExporting the project dependencies...$(RESET)"
	@$(POETRY) export -f requirements.txt --output requirements.txt --without-hashes --only main
	@$(POETRY) export -f requirements.txt --output requirements-dev.txt --without-hashes --with dev --without docs
	@$(POETRY) export -f requirements.txt --output requirements-docs.txt --without-hashes --only docs
	@echo -e "$(GREEN)Dependencies exported.$(RESET)"
	@touch $(DEPS_EXPORT_STAMP)

.PHONY: project/build
project/build: dep/poetry $(BUILD_STAMP)  ## Build the project as a package
$(BUILD_STAMP): pyproject.toml
	@echo -e "$(CYAN)\nBuilding the project...$(RESET)"
	@rm -rf $(BUILD)
	@$(POETRY) build
	@echo -e "$(GREEN)Project built.$(RESET)"
	@touch $(BUILD_STAMP)

#-- Check

.PHONY: check/precommit
check/precommit: $(INSTALL_STAMP) $(PRECOMMIT_CONF)  ## Run the pre-commit checks
	@echo -e "$(CYAN)\nRunning the pre-commit checks...$(RESET)"
	@$(POETRY) run pre-commit run --all-files
	@echo -e "$(GREEN)Pre-commit checks completed.$(RESET)"

.PHONY: check/format
check/format: $(INSTALL_STAMP)  ## Format the code
	@echo -e "$(CYAN)\nFormatting the code...$(RESET)"
	@ruff format $(PY_FILES)
	@echo -e "$(GREEN)Code formatted.$(RESET)"

.PHONY: check/lint
check/lint: $(INSTALL_STAMP)  ## Lint the code
	@echo -e "$(CYAN)\nLinting the code...$(RESET)"
	@ruff check $(PY_FILES)
	@echo -e "$(GREEN)Code linted.$(RESET)"

#-- Docker

.PHONY: docker/build
docker/build: dep/docker dep/docker-compose $(INSTALL_STAMP) $(DEPS_EXPORT_STAMP) $(DOCKER_BUILD_STAMP)  ## Build the Docker image
$(DOCKER_BUILD_STAMP): $(DOCKER_FILE) $(DOCKER_COMPOSE_FILE)
	@echo -e "$(CYAN)\nBuilding the Docker image...$(RESET)"
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) DOCKER_CONTAINER_NAME=$(DOCKER_CONTAINER_NAME) $(DOCKER_COMPOSE) build
	@echo -e "$(GREEN)Docker image built.$(RESET)"
	@touch $(DOCKER_BUILD_STAMP)

.PHONY: docker/run
docker/run: dep/docker $(DOCKER_BUILD_STAMP)  ## Run the Docker container
	@echo -e "$(CYAN)\nRunning the Docker container...$(RESET)"
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) DOCKER_CONTAINER_NAME=$(DOCKER_CONTAINER_NAME) ARGS="$(ARGS)" $(DOCKER_COMPOSE) up
	@echo -e "$(GREEN)Docker container executed.$(RESET)"

.PHONY: docker/all
docker/all: docker/build docker/run  ## Build and run the Docker container

.PHONY: docker/stop
docker/stop: | dep/docker dep/docker-compose  ## Stop the Docker container
	@echo -e "$(CYAN)\nStopping the Docker container...$(RESET)"
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) DOCKER_CONTAINER_NAME=$(DOCKER_CONTAINER_NAME) $(DOCKER_COMPOSE) down
	@echo -e "$(GREEN)Docker container stopped.$(RESET)"

.PHONY: docker/remove
docker/remove: | dep/docker dep/docker-compose  ## Remove the Docker image, container, and volumes
	@echo -e "$(CYAN)\nRemoving the Docker image...$(RESET)"
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) DOCKER_CONTAINER_NAME=$(DOCKER_CONTAINER_NAME) $(DOCKER_COMPOSE) down -v --rmi all
	@rm -f $(DOCKER_BUILD_STAMP)
	@echo -e "$(GREEN)Docker image removed.$(RESET)"

#-- Tag

.PHONY: tag
tag: | dep/git
	@$(eval TAG := $(shell $(GIT) describe --tags --abbrev=0))
	@$(eval BEHIND_AHEAD := $(shell $(GIT) rev-list --left-right --count $(TAG)...origin/main))
	@$(shell if [ "$(BEHIND_AHEAD)" = "0	0" ]; then echo "false" > $(RELEASE_STAMP); else echo "true" > $(RELEASE_STAMP); fi)
	@echo -e "$(CYAN)\nChecking if a new release is needed...$(RESET)"
	@echo -e "  $(CYAN)Current tag:$(RESET) $(TAG)"
	@echo -e "  $(CYAN)Commits behind/ahead:$(RESET) $(shell echo ${BEHIND_AHEAD} | tr '[:space:]' '/' | $(SED) 's/\/$$//')"
	@echo -e "  $(CYAN)Needs release:$(RESET) $(shell cat $(RELEASE_STAMP))"

.PHONY: staging
staging: | dep/git
	@if $(GIT) diff --cached --quiet; then \
		echo "true" > $(STAGING_STAMP); \
	else \
		echo "false" > $(STAGING_STAMP); \
	fi; \
	echo -e "$(CYAN)\nChecking the staging area...$(RESET)"; \
	echo -e "  $(CYAN)Staging area empty:$(RESET) $$(cat $(STAGING_STAMP))"

.PHONY: tag/patch
tag/patch: | tag staging  ## Tag a new patch version release
	@NEEDS_RELEASE=$$(cat $(RELEASE_STAMP)); \
	if [ "$$NEEDS_RELEASE" = "true" ]; then \
		$(eval TAG := $(shell $(GIT) describe --tags --abbrev=0)) \
		$(eval NEW_TAG := $(shell $(POETRY) version patch > /dev/null && $(POETRY) version -s)) \
		$(GIT) add pyproject.toml; \
		$(GIT) commit -m "Bump version to $(NEW_TAG)"; \
		echo -e "$(CYAN)\nTagging a new patch version... [$(TAG)->$(NEW_TAG)]$(RESET)"; \
		$(GIT) tag $(NEW_TAG); \
		echo -e "$(GREEN)New patch version tagged.$(RESET)"; \
	fi

.PHONY: tag/minor
tag/minor: | tag staging  ## Tag a new minor version release
	@NEEDS_RELEASE=$$(cat $(RELEASE_STAMP)); \
	if [ "$$NEEDS_RELEASE" = "true" ]; then \
		$(eval TAG := $(shell $(GIT) describe --tags --abbrev=0)) \
		$(eval NEW_TAG := $(shell $(POETRY) version minor > /dev/null && $(POETRY) version -s)) \
		$(GIT) add pyproject.toml; \
		$(GIT) commit -m "Bump version to $(NEW_TAG)"; \
		echo -e "$(CYAN)\nTagging a new minor version... [$(TAG)->$(NEW_TAG)]$(RESET)"; \
		$(GIT) tag $(NEW_TAG); \
		echo -e "$(GREEN)New minor version tagged.$(RESET)"; \
	fi

.PHONY: tag/major
tag/major: | tag  staging  ## Tag a new major version release
	@NEEDS_RELEASE=$$(cat $(RELEASE_STAMP)); \
	if [ "$$NEEDS_RELEASE" = "true" ]; then \
		$(eval TAG := $(shell $(GIT) describe --tags --abbrev=0)) \
		$(eval NEW_TAG := $(shell $(POETRY) version major > /dev/null && $(POETRY) version -s)) \
		$(GIT) add pyproject.toml; \
		$(GIT) commit -m "Bump version to $(NEW_TAG)"; \
		echo -e "$(CYAN)\nTagging a new major version... [$(TAG)->$(NEW_TAG)]$(RESET)"; \
		$(GIT) tag $(NEW_TAG); \
		echo -e "$(GREEN)New major version tagged.$(RESET)"; \
	fi

.PHONY: tag/push
tag/push: | dep/git  ## Push the tag to origin - triggers the release action
	@$(eval TAG := $(shell $(GIT) describe --tags --abbrev=0))
	@$(eval REMOTE_TAGS := $(shell $(GIT) ls-remote --tags origin | $(AWK) '{print $$2}'))
	@if echo $(REMOTE_TAGS) | grep -q $(TAG); then \
		echo -e "$(ORANGE)\nNothing to push: tag $(TAG) already exists on origin.$(RESET)"; \
	else \
		echo -e "$(CYAN)\nPushing new release $(TAG)...$(RESET)"; \
		$(GIT) push origin; \
		$(GIT) push origin $(TAG); \
		echo -e "$(GREEN)Release $(TAG) pushed.$(RESET)"; \
	fi

#-- Documentation

.PHONY: docs/build
docs/build: dep/poetry $(DOCS_STAMP)  ## Generate the project documentation
$(DOCS_STAMP): $(DEPS_EXPORT_STAMP) mkdocs.yml
	@echo -e "$(CYAN)\nGenerating the project documentation...$(RESET)"
	@$(POETRY) run mkdocs build
	@echo -e "$(GREEN)Project documentation generated.$(RESET)"
	@touch $(DOCS_STAMP)

.PHONY: docs/serve
docs/serve: dep/poetry $(DOCS_STAMP)  ## Serve the project documentation
	@echo -e "$(CYAN)\nServing the project documentation...$(RESET)"
	@$(POETRY) run mkdocs serve

.PHONY: docs/deploy
docs/deploy: dep/poetry $(DOCS_STAMP)  ## Deploy the project documentation
	@echo -e "$(CYAN)\nDeploying the project documentation...$(RESET)"
	@$(POETRY) run mkdocs gh-deploy
	@echo -e "$(GREEN)Project documentation deployed at http://$(GITHUB_USER_NAME).github.io/$(PROJECT_NAME) $(RESET)"
