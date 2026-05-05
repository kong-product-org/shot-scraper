# Path to the developer.konghq.com repo where screenshots are written.
# Default assumes this repo is cloned as a sibling of developer.konghq.com.
# Override if your layout differs: make screenshot ... DOCS_DIR=..
DOCS_DIR ?= ../developer.konghq.com

# Absolute path to this Makefile's directory, used to reference macros and YAML configs.
SELF_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Auto-detect Chrome profile path based on OS.
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
CHROME_PROFILE_DEFAULT := $(HOME)/Library/Application Support/Google/Chrome/Default
else
CHROME_PROFILE_DEFAULT := $(HOME)/.config/google-chrome/Default
endif

# Use SHOT_SCRAPER_CHROME_PROFILE from the environment if set, otherwise use the detected path.
SHOT_SCRAPER_CHROME_PROFILE ?= $(CHROME_PROFILE_DEFAULT)

# Install Python dependencies and the Chromium browser.
install:
	uv sync
	uv run playwright install chromium

# Print the export command for SHOT_SCRAPER_CHROME_PROFILE — add it to your shell profile.
set-env:
	@echo "Add this to your shell profile (~/.zshrc or ~/.bashrc):"
	@echo ""
	@printf 'export SHOT_SCRAPER_CHROME_PROFILE="%s"\n' "$(CHROME_PROFILE_DEFAULT)"

# Open a browser to log in to Konnect and save the session to auth.json.
auth:
	SHOT_SCRAPER_CHROME_PROFILE='$(SHOT_SCRAPER_CHROME_PROFILE)' uv run shot-scraper auth https://cloud.konghq.com auth.json

# Capture the second word of the make invocation as the target YAML file.
# e.g. `make screenshot konnect/platform/overview.yaml` → FILE=konnect/platform/overview.yaml
FILE := $(word 2,$(MAKECMDGOALS))

# Take screenshots for a single YAML config file.
# Runs from DOCS_DIR so relative output paths in the YAML resolve to the correct location.
screenshot:
ifeq ($(FILE),)
	$(error Usage: make screenshot konnect/platform/overview.yaml)
endif
	@cd '$(DOCS_DIR)' && \
	  SHOT_SCRAPER_CHROME_PROFILE='$(SHOT_SCRAPER_CHROME_PROFILE)' \
	  uv run --project '$(SELF_DIR)' shot-scraper multi --silent \
	  --macro '$(SELF_DIR)macros.yaml' \
	  '$(SELF_DIR)$(FILE)'
	@grep 'output:' '$(SELF_DIR)$(FILE)' | sed 's/.*output: *//' | while read f; do echo "$(abspath $(DOCS_DIR))/$$f"; done

# Take screenshots for every YAML config in konnect/ in alphabetical order.
screenshots-all:
	@find '$(SELF_DIR)konnect' -name '*.yaml' | sort | while read f; do \
	  file=$${f#$(SELF_DIR)}; \
	  echo "--- $$file ---"; \
	  cd '$(abspath $(DOCS_DIR))' && \
	    SHOT_SCRAPER_CHROME_PROFILE='$(SHOT_SCRAPER_CHROME_PROFILE)' \
	    uv run --project '$(SELF_DIR)' shot-scraper multi \
	    --macro '$(SELF_DIR)macros.yaml' \
	    "$$f"; \
	  grep 'output:' "$$f" | sed 's/.*output: *//' | while read o; do echo "$(abspath $(DOCS_DIR))/$$o"; done; \
	done

.PHONY: install set-env auth screenshot screenshots-all $(FILE)
%:
	@:
