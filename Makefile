SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

RESET := \033[0m
RED := \033[0;31m
GREEN := \033[0;32m
ORANGE := \033[0;33m
MAGENTA := \033[0;35m
CYAN := \033[0;36m

#-- Help

.DEFAULT_GOAL := help
.PHONY: help
help:  ## Show this help message
	@echo -e "\nUsage: make [target]\n"
	@grep -E '^[0-9a-zA-Z_-]+(/?[0-9a-zA-Z_-]*)*:.*?## .*$$|(^#--)' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m %-15s\033[0m %s\n", $$1, $$2}' \
	| sed -e 's/\[36m #-- /\[35m/'
