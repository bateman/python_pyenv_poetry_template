# Shell config
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Make config
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Project variables -- change as needed before running make install
# override the defaults by setting the variables in a makefile.env file
-include makefile.env
PROJECT_NAME ?= $(shell basename $(CURDIR))
# make sure the project name is lowercase and has no spaces
PROJECT_NAME := $(shell echo $(PROJECT_NAME) | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
PROJECT_REPO ?= $(shell url=$$(git config --get remote.origin.url); echo $${url%.git})
PROJECT_VERSION ?= $(shell poetry version -s 2>/dev/null || echo 0.1.0)
PROJECT_DESCRIPTION ?= 'A short description of the project'
PROJECT_LICENSE ?= MIT
PYTHON_VERSION ?= 3.12.1
PYENV_VIRTUALENV_NAME ?= venv-$(shell echo "$(PROJECT_NAME)")
PRECOMMIT_CONF ?= .pre-commit-config.yaml
DOCKER_COMPOSE_FILE ?= docker-compose.yml
DOCKER_IMAGE_NAME ?= $(PROJECT_NAME)
DOCKER_CONTAINER_NAME ?= $(PROJECT_NAME)

# Executables
MAKE_VERSION := $(shell make --version | head -n 1 2> /dev/null)
POETRY := $(shell command -v poetry 2> /dev/null)
PYENV := $(shell command -v pyenv 2> /dev/null)
PYENV_ROOT := $(shell pyenv root)
GIT := $(shell command -v git 2> /dev/null)
GIT_VERSION := $(shell $(GIT) --version 2> /dev/null || echo -e "\033[31mnot installed\033[0m")
DOCKER := $(shell command -v docker 2> /dev/null)
DOCKER_VERSION := $(shell if [ -n "$(DOCKER)" ]; then $(DOCKER) --version 2> /dev/null; fi)
DOCKER_FILE := Dockerfile
DOCKER_COMPOSE := $(shell if [ -n "$(DOCKER)" ]; then command -v docker-compose 2> /dev/null || echo "$(DOCKER) compose"; fi)
DOCKER_COMPOSE_VERSION := $(shell if [ -n "$(DOCKER_COMPOSE)" ]; then $(DOCKER_COMPOSE) version 2> /dev/null; fi )

# Stamp files
INSTALL_STAMP := .install.stamp
INIT_STAMP := .init.stamp
UPDATE_STAMP := .update.stamp
PRODUCTION_STAMP := .production.stamp
DEPS_EXPORT_STAMP := .deps-export.stamp
BUILD_STAMP := .build.stamp
DOCS_STAMP := .docs.stamp
STAMP_FILES := $(wildcard .*.stamp)

# Dirs
SRC := $(PROJECT_NAME)
TESTS := tests
BUILD := dist
DOCS := docs
CACHE := $(wildcard .*_cache)

# Colors
RESET := \033[0m
RED := \033[0;31m
GREEN := \033[0;32m
ORANGE := \033[0;33m
MAGENTA := \033[0;35m
CYAN := \033[0;36m

#-- System

.DEFAULT_GOAL := help
.PHONY: help
help:  ## Show this help message
	@echo -e "\nUsage: make [target]\n"
	@grep -E '^[0-9a-zA-Z_-]+(/?[0-9a-zA-Z_-]*)*:.*?## .*$$|(^#--)' $(firstword $(MAKEFILE_LIST)) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m %-21s\033[0m %s\n", $$1, $$2}' \
	| sed -e 's/\[36m #-- /\[35m/'

.PHONY: info
info: ## Show development box info
	@echo -e "$(MAGENTA)\nSystem info:$(RESET)"
	@echo -e "  $(CYAN)OS:$(RESET) $(shell uname -s)"
	@echo -e "  $(CYAN)Shell:$(RESET) $(SHELL) - $(shell $(SHELL) --version | head -n 1)"
	@echo -e "  $(CYAN)Make:$(RESET) $(MAKE_VERSION)"
	@echo -e "  $(CYAN)Git:$(RESET) $(GIT_VERSION)"
	@echo -e "$(MAGENTA)Project info:$(RESET)"
	@echo -e "  $(CYAN)Project name:$(RESET) $(PROJECT_NAME)"
	@echo -e "  $(CYAN)Project directory:$(RESET) $(CURDIR)"
	@echo -e "  $(CYAN)Project version:$(RESET) $(PROJECT_VERSION)"
	@echo -e "  $(CYAN)Project license:$(RESET) $(PROJECT_LICENSE)"
	@echo -e "  $(CYAN)Project description:$(RESET) $(PROJECT_DESCRIPTION)"
	@echo -e "$(MAGENTA)Python info:$(RESET)"
	@echo -e "  $(CYAN)Python version:$(RESET) $(PYTHON_VERSION)"
	@echo -e "  $(CYAN)Pyenv version:$(RESET) $(shell $(PYENV) --version || echo "$(RED)not installed $(RESET)")"
	@echo -e "  $(CYAN)Pyenv root:$(RESET) $(PYENV_ROOT)"
	@echo -e "  $(CYAN)Pyenv virtualenv name:$(RESET) $(PYENV_VIRTUALENV_NAME)"
	@echo -e "  $(CYAN)Poetry version:$(RESET) $(shell $(POETRY) --version || echo "$(RED)not installed $(RESET)")"
	@echo -e "$(MAGENTA)Dokcer info:$(RESET)"
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

.PHONY: clean
clean:  ## Clean the project - removes all cache dirs and stamp files
	@echo -e "$(ORANGE)\nCleaning the project...$(RESET)"
	@find . -type d -name "__pycache__" | xargs rm -rf {};
	@rm -rf $(STAMP_FILES) $(CACHE) $(BUILD) $(DOCS) .coverage
	@echo -e "$(GREEN)Project cleaned.$(RESET)"

.PHONY: reset
reset:  ## Reset the project - cleans plus removes the virtual enviroment)
	@echo -e "$(RED)\nAre you sure you want to proceed with the reset (this involves wiping also the virual enviroment)? [y/N]: $(RESET)"
	@read -r answer; \
	if [ "$$answer" != "y" ]; then \
		echo -e "$(ORANGE)Project reset aborted.$(RESET)"; \
		exit 0; \
	else \
		$(MAKE) clean; \
		echo -e "$(ORANGE)Resetting the project...$(RESET)"; \
		rm -f .python-version > /dev/null || true ; \
		rm -f poetry.lock > /dev/null || true ; \
		pyenv virtualenv-delete -f $(PYENV_VIRTUALENV_NAME) ; \
		echo -e "$(GREEN)Project reset.$(RESET)" ; \
	fi

python:  ## Check if python is installed - install it if not
	@if ! $(PYENV) versions | grep $(PYTHON_VERSION) > /dev/null ; then \
		echo -e "$(ORANGE)\nPython version $(PYTHON_VERSION) not installed. Installing it via pyenv...$(RESET)"; \
		$(PYENV) install $(PYTHON_VERSION) || exit 1; \
		echo -e "$(GREEN)Python version $(PYTHON_VERSION) installed.$(RESET)"; \
	else \
		echo -e "$(CYAN)\nPython version $(PYTHON_VERSION) already installed.$(RESET)"; \
	fi

virtualenv: python  ## Check if virtualenv exists - create and activate it if not
	@if ! $(PYENV) virtualenvs | grep $(PYENV_VIRTUALENV_NAME) > /dev/null ; then \
		echo -e "$(ORANGE)\nLocal virtualenv not found. Creating it...$(RESET)"; \
		$(PYENV) virtualenv $(PYTHON_VERSION) $(PYENV_VIRTUALENV_NAME) || exit 1; \
		echo -e "$(GREEN)Virtualenv created.$(RESET)"; \
	else \
		echo -e "$(CYAN)\nVirtualenv already created.$(RESET)"; \
	fi
	@$(PYENV) local $(PYENV_VIRTUALENV_NAME)
	@echo -e "$(GREEN)Virtualenv activated.$(RESET)"

poetry/install: python  ## Check if Poetry is installed - install it if not
	@if [ -z $(POETRY) ]; then \
		echo -e "$(ORANGE)\nPoetry not found. Installing it...$(RESET)"; \
		curl -sSL https://install.python-poetry.org | python3 -; \
		@$(POETRY) self add poetry-plugin-export; \
		echo -e "$(GREEN)Poetry installed.$(RESET)"; \
	else \
		echo -e "$(CYAN)\n$(shell $(POETRY) --version) already installed.$(RESET)"; \
	fi
	@$(POETRY) check

.PHONY:
poetry/update: poetry/install  ## Update Poetry
	@echo -e "$(CYAN)\nUpgrading Poetry...$(RESET)"
	@$(POETRY) self update
	@echo -e "$(GREEN)Poetry upgraded.$(RESET)"

#-- Project

project/all: project/install project/build project/docs  ## Install, build and generate the documentation

project/install: poetry/install $(INSTALL_STAMP) ## Install the project for development
$(INSTALL_STAMP): pyproject.toml
	@if [ ! -f .python-version ]; then \
		echo -e "$(RED)\nVirtual enviroment missing. Please run 'make virtualenv' first.$(RESET)"; \
	else \
		echo -e "$(CYAN)\nInstalling the project...$(RESET)"; \
		$(POETRY) install; \
		$(POETRY) lock; \
		$(POETRY) run pre-commit install; \
		if [ ! -f $(INIT_STAMP) ]; then \
			echo -e "$(CYAN)\nInitializing the project dependencies [v$(PROJECT_VERSION)]...$(RESET)"; \
			python .toml.py --name $(PROJECT_NAME) --ver $(PROJECT_VERSION) --desc $(PROJECT_DESCRIPTION) --repo $(PROJECT_REPO)  --lic $(PROJECT_LICENSE) ; \
			mkdir -p $(SRC) $(TESTS) $(DOCS) $(BUILD) || true ; \
			touch $(SRC)/__init__.py $(SRC)/main.py ; \
			echo -e "$(GREEN)Project initialized.$(RESET)"; \
			touch $(INIT_STAMP); \
		else \
			echo -e "$(ORANGE)Project already initialized.$(RESET)"; \
		fi; \
		touch $(INSTALL_STAMP); \
		echo -e "$(GREEN)Project installed for development.$(RESET)"; \
	fi

project/update: $(UPDATE_STAMP)  ## Update the project
$(UPDATE_STAMP): pyproject.toml
	@echo -e "$(CYAN)\nUpdating the project...$(RESET)"
	@$(POETRY) update
	$(POETRY) lock
	@$(POETRY) run pre-commit autoupdate
	@touch $(UPDATE_STAMP)
	@echo -e "$(GREEN)Project updated.$(RESET)"

project/production: $(PRODUCTION_STAMP)  ## Install the project for production
$(PRODUCTION_STAMP): pyproject.toml
	@echo -e "$(CYAN)\Install project for production...$(RESET)"
	@$(POETRY) install --only main --no-interaction
	@touch $(PRODUCTION_STAMP)
	@echo -e "$(GREEN)Project installed for production.$(RESET)"

project/deps-export: project/update $(DEPS_EXPORT_STAMP) ## Export the project's dependencies
$(DEPS_EXPORT_STAMP): pyproject.toml
	@echo -e "$(CYAN)\nExporting the project...$(RESET)"
	@$(POETRY) export -f requirements.txt --output requirements.txt --without-hashes --only main
	@$(POETRY) export -f requirements.txt --output requirements-dev.txt --without-hashes --with dev --without docs
	@$(POETRY) export -f requirements.txt --output requirements-docs.txt --without-hashes --only docs
	@touch $(DEPS_EXPORT_STAMP)
	@echo -e "$(GREEN)Project exported.$(RESET)"

project/build: $(BUILD_STAMP)  ## Build the project as a package
$(BUILD_STAMP): pyproject.toml
	@echo -e "$(CYAN)\nBuilding the project...$(RESET)"
	@rm -rf $(BUILD)
	@$(POETRY) build
	@touch $(BUILD_STAMP)
	@echo -e "$(GREEN)Project built.$(RESET)"

project/docs: $(DOCS_STAMP) project/deps-export ## Generate the project documentation
$(DOCS_STAMP): requirements-docs.txt mkdocs.yml
	@echo -e "$(CYAN)\nGenerating the project documentation...$(RESET)"
	@$(POETRY) run mkdocs build
	@touch $(DOCS_STAMP)
	@echo -e "$(GREEN)Project documentation generated.$(RESET)"

#-- Run

.PHONY: run/project
run/project: $(INSTALL_STAMP)  ## Run the project
	@python -m $(SRC)

.PHONY: run/tests
run/tests: $(INSTALL_STAMP)  ## Run the tests
	@echo -e "$(CYAN)\nRunning the tests...$(RESET)"
	@$(POETRY) run pytest $(TESTS)
	@echo -e "$(GREEN)Tests passed.$(RESET)"

#-- Release

.PHONY: dep/git
dep/git:
	@which $(GIT) > /dev/null || (echo -e "$(RED)Git not found.$(RESET)" && exit 1)

.PHONY: release/patch
release/patch: dep/git project/install  ## Tag a new patch version release
	@echo -e "$(CYAN)\nReleasing a new patch version...$(RESET)"
	@$(POETRY) version patch
	@$(GIT) tag -a v$(shell poetry version -s) -m "Release v$(shell poetry version -s)"
	@echo -e "$(GREEN)New patch version released.$(RESET)"

.PHONY: release/minor
release/minor: dep/git project/install  ## Tag a new minor version release
	@echo -e "$(CYAN)\nReleasing a new minor version...$(RESET)"
	@$(POETRY) version minor
	@$(GIT) tag -a v$(shell poetry version -s) -m "Release v$(shell poetry version -s)"
	@echo -e "$(GREEN)New minor version released.$(RESET)"

.PHONY: release/major
release/major: dep/git project/install  ## Tag a new major version release
	@echo -e "$(CYAN)\nReleasing a new major version...$(RESET)"
	@$(POETRY) version major
	@$(GIT) tag -a v$(shell poetry version -s) -m "Release v$(shell poetry version -s)"
	@echo -e "$(GREEN)New major version released.$(RESET)"

.PHONY: release/push
release/push: dep/git project/install  ## Push the release
	@$(eval TAG=$(shell git describe --tags --abbrev=0))
	@echo -e "$(CYAN)\nPushing release v$(TAG)...$(RESET)"
	@$(GIT) push origin $(TAG)
	@echo -e "$(GREEN)Release v$(TAG) pushed.$(RESET)"

#-- Check

.PHONY: check/precommit
check/precommit: $(INSTALL_STAMP) $(PRECOMMIT_CONF)  ## Run the pre-commit checks
	@echo -e "$(CYAN)\nRunning the pre-commit checks...$(RESET)"
	@$(POETRY) run pre-commit run --all-files
	@echo -e "$(GREEN)Pre-commit checks completed.$(RESET)"

.PHONY: check/format
check/format: $(INSTALL_STAMP)  ## Format the code
	@echo -e "$(CYAN)\nFormatting the code...$(RESET)"
	@ruff format $(SRC) $(TESTS)
	@echo -e "$(GREEN)Code formatted.$(RESET)"

.PHONY: check/lint
check/lint: $(INSTALL_STAMP)  ## Lint the code
	@echo -e "$(CYAN)\nLinting the code...$(RESET)"
	@ruff check $(SRC) $(TESTS)
	@echo -e "$(GREEN)Code linted.$(RESET)"

#-- Docker

.PHONY: dep/docker
dep/docker:
	@if [ -z "$(DOCKER)" ]; then echo -e "$(RED)Docker not found.$(RESET)" && exit 1; fi

.PHONY: dep/docker-compose
dep/docker-compose:
	@if [ -z "$(DOCKER_COMPOSE)" ]; then echo -e"$(RED)Docker Compose not found.$(RESET)" && exit 1; fi

.PHONY: docker/build $(INSTALL_STAMP)
docker/build: dep/docker dep/docker-compose project/deps-export  ## Build the Docker image
	@echo -e "$(CYAN)\nBuilding the Docker image...$(RESET)"
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) DOCKER_CONTAINER_NAME=$(DOCKER_CONTAINER_NAME) $(DOCKER_COMPOSE) build
	@echo -e "$(GREEN)Docker image built.$(RESET)"

.PHONY: docker/run $(INSTALL_STAMP)
docker/run: dep/docker dep/docker-compose  docker/build  ## Run the Docker container
	@echo -e "$(CYAN)\nRunning the Docker container...$(RESET)"
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) DOCKER_CONTAINER_NAME=$(DOCKER_CONTAINER_NAME) $(DOCKER_COMPOSE) up
	@echo -e "$(GREEN)Docker container running.$(RESET)"

.PHONY: docker/all
docker/all: docker/build docker/run  ## Build and run the Docker container

.PHONY: docker/stop
docker/stop: dep/docker dep/docker-compose  ## Stop the Docker container
	@echo -e "$(CYAN)\nStopping the Docker container...$(RESET)"
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) DOCKER_CONTAINER_NAME=$(DOCKER_CONTAINER_NAME) $(DOCKER_COMPOSE) down
	@echo -e "$(GREEN)Docker container stopped.$(RESET)"

.PHONY: docker/clean
docker/clean: dep/docker dep/docker-compose  ## Clean the Docker container
	@echo -e "$(CYAN)\nCleaning the Docker container...$(RESET)"
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) DOCKER_CONTAINER_NAME=$(DOCKER_CONTAINER_NAME) $(DOCKER_COMPOSE) down -v
	@echo -e "$(GREEN)Docker container cleaned.$(RESET)"

.PHONY: docker/remove
docker/remove: dep/docker dep/docker-compose  ## Clean the Docker container and remove the image
	@echo -e "$(CYAN)\nRemoving the Docker image...$(RESET)"
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE_NAME) DOCKER_CONTAINER_NAME=$(DOCKER_CONTAINER_NAME) $(DOCKER_COMPOSE) down -v --rmi all
	@echo -e "$(GREEN)Docker image removed.$(RESET)"
