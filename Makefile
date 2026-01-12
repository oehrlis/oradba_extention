# =============================================================================
# OraDBA Extension Makefile
# =============================================================================
# Comprehensive development workflow for the OraDBA extension template
#
# Usage:
#   make help          - Show this help
#   make lint          - Run all linters
#   make test          - Run tests
#   make build         - Build distribution tarball
#   make ci            - Run full CI pipeline
#
# =============================================================================

SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

# -----------------------------------------------------------------------------
# Project Configuration
# -----------------------------------------------------------------------------
DIST ?= dist
VERSION := $(shell cat VERSION 2>/dev/null || echo "0.0.0")
EXTENSION_NAME := $(shell grep '^name:' .extension 2>/dev/null | awk '{print $$2}' || echo "extension-template")

# -----------------------------------------------------------------------------
# Tool Detection
# -----------------------------------------------------------------------------
HAS_SHELLCHECK := $(shell command -v shellcheck 2>/dev/null)
HAS_SHFMT := $(shell command -v shfmt 2>/dev/null)
HAS_MARKDOWNLINT := $(shell command -v markdownlint 2>/dev/null)
HAS_BATS := $(shell command -v bats 2>/dev/null)
HAS_GIT := $(shell command -v git 2>/dev/null)

# -----------------------------------------------------------------------------
# Color Definitions
# -----------------------------------------------------------------------------
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# -----------------------------------------------------------------------------
# Help System
# -----------------------------------------------------------------------------
.PHONY: help
help: ## Show this help message
	@echo ""
	@echo -e "$(BLUE)OraDBA Extension Development Makefile$(NC)"
	@echo ""
	@echo -e "$(GREEN)Development Targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## .*Development/ {printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(GREEN)Linting & Formatting:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## .*(Lint|Format|Check)/ {printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(GREEN)Build & Release:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## .*(Build|Clean|Release)/ {printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(GREEN)Version Management:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## .*Version/ {printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(GREEN)CI/CD & Tools:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z_-]+:.*?## .*(CI|Tool|Info|Status)/ {printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(GREEN)Quick Shortcuts:$(NC)"
	@echo -e "  $(GREEN)t$(NC)                  Alias for 'test'"
	@echo -e "  $(GREEN)l$(NC)                  Alias for 'lint'"
	@echo -e "  $(GREEN)f$(NC)                  Alias for 'format'"
	@echo -e "  $(GREEN)b$(NC)                  Alias for 'build'"
	@echo -e "  $(GREEN)c$(NC)                  Alias for 'clean'"
	@echo ""

# -----------------------------------------------------------------------------
# Development Targets
# -----------------------------------------------------------------------------
.PHONY: test
test: ## Development: Run BATS tests
	@echo -e "$(BLUE)Running tests...$(NC)"
ifndef HAS_BATS
	@echo -e "$(RED)Error: bats not found$(NC)"
	@echo -e "$(YELLOW)Install with: apt-get install bats (Ubuntu) or brew install bats-core (macOS)$(NC)"
	@exit 1
endif
	@bats tests && echo -e "$(GREEN)✓ Tests passed$(NC)" || (echo -e "$(RED)✗ Tests failed$(NC)" && exit 1)

# -----------------------------------------------------------------------------
# Linting & Formatting
# -----------------------------------------------------------------------------
.PHONY: lint
lint: lint-sh lint-md ## Lint: Run all linters (shellcheck + markdownlint)

.PHONY: lint-sh
lint-sh: ## Lint: Run shellcheck on shell scripts
	@echo -e "$(BLUE)Linting shell scripts...$(NC)"
ifndef HAS_SHELLCHECK
	@echo -e "$(RED)Error: shellcheck not found$(NC)"
	@echo -e "$(YELLOW)Install with: apt-get install shellcheck (Ubuntu) or brew install shellcheck (macOS)$(NC)"
	@exit 1
endif
	@FAILED=0; \
	while IFS= read -r -d '' file; do \
		echo -e "  Checking $$file..."; \
		shellcheck -e SC1091 "$$file" || FAILED=1; \
	done < <(find scripts bin lib tests \( -name "*.sh" -o -name "*.bats" \) -type f -print0 2>/dev/null); \
	if [ $$FAILED -eq 0 ]; then \
		echo -e "$(GREEN)✓ Shell linting passed$(NC)"; \
	else \
		echo -e "$(RED)✗ Shell linting failed$(NC)"; \
		exit 1; \
	fi

.PHONY: lint-md
lint-md: ## Lint: Run markdownlint on markdown files
	@echo -e "$(BLUE)Linting markdown files...$(NC)"
ifndef HAS_MARKDOWNLINT
	@echo -e "$(YELLOW)Warning: markdownlint not found (optional)$(NC)"
	@echo -e "$(YELLOW)Install with: npm install -g markdownlint-cli$(NC)"
else
	@markdownlint "**/*.md" --ignore node_modules --ignore dist --ignore build && \
		echo -e "$(GREEN)✓ Markdown linting passed$(NC)" || \
		(echo -e "$(RED)✗ Markdown linting failed$(NC)" && exit 1)
endif

.PHONY: format
format: ## Format: Format shell scripts with shfmt
	@echo -e "$(BLUE)Formatting shell scripts...$(NC)"
ifndef HAS_SHFMT
	@echo -e "$(YELLOW)Warning: shfmt not found (optional)$(NC)"
	@echo -e "$(YELLOW)Install with: go install mvdan.cc/sh/v3/cmd/shfmt@latest$(NC)"
else
	@FAILED=0; \
	while IFS= read -r -d '' file; do \
		echo -e "  Formatting $$file..."; \
		shfmt -i 4 -bn -ci -sr -w "$$file" || FAILED=1; \
	done < <(find scripts bin lib -name "*.sh" -type f -print0 2>/dev/null); \
	if [ $$FAILED -eq 0 ]; then \
		echo -e "$(GREEN)✓ Formatting complete$(NC)"; \
	else \
		echo -e "$(RED)✗ Formatting failed$(NC)"; \
		exit 1; \
	fi
endif

.PHONY: format-check
format-check: ## Format: Check if shell scripts are formatted correctly
	@echo -e "$(BLUE)Checking shell script formatting...$(NC)"
ifndef HAS_SHFMT
	@echo -e "$(YELLOW)Warning: shfmt not found (optional) - skipping format check$(NC)"
else
	@FILES=$$(find scripts bin lib -name "*.sh" -type f 2>/dev/null); \
	if [ -z "$$FILES" ]; then \
		echo -e "$(YELLOW)No shell scripts found to check$(NC)"; \
	else \
		UNFORMATTED=$$(echo "$$FILES" | xargs shfmt -i 4 -bn -ci -sr -d 2>/dev/null); \
		if [ -n "$$UNFORMATTED" ]; then \
			echo -e "$(RED)✗ The following files are not formatted correctly:$(NC)"; \
			echo "$$UNFORMATTED"; \
			echo -e "$(YELLOW)Run 'make format' to fix$(NC)"; \
			exit 1; \
		else \
			echo -e "$(GREEN)✓ All files are properly formatted$(NC)"; \
		fi; \
	fi
endif

.PHONY: check
check: lint test ## Check: Run lint and test (for quick validation)
	@echo -e "$(GREEN)✓ All checks passed$(NC)"

# -----------------------------------------------------------------------------
# Build & Distribution
# -----------------------------------------------------------------------------
.PHONY: build
build: ## Build: Build extension tarball
	@echo -e "$(BLUE)Building extension tarball...$(NC)"
	@./scripts/build.sh --dist "$(DIST)" && echo -e "$(GREEN)✓ Build complete$(NC)" || (echo -e "$(RED)✗ Build failed$(NC)" && exit 1)

.PHONY: clean
clean: ## Clean: Remove dist directory
	@echo -e "$(BLUE)Cleaning dist directory...$(NC)"
	@rm -rf "$(DIST)" && echo -e "$(GREEN)✓ Clean complete$(NC)"

.PHONY: clean-all
clean-all: clean ## Clean: Deep clean including caches
	@echo -e "$(BLUE)Deep cleaning...$(NC)"
	@find . -type f -name "*.log" -delete 2>/dev/null || true
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name ".DS_Store" -delete 2>/dev/null || true
	@echo -e "$(GREEN)✓ Deep clean complete$(NC)"

# -----------------------------------------------------------------------------
# Version Management
# -----------------------------------------------------------------------------
.PHONY: version
version: ## Version: Display current version
	@echo -e "$(BLUE)Current version:$(NC) $(VERSION)"

.PHONY: version-bump-patch
version-bump-patch: ## Version: Bump patch version (0.0.X)
ifndef HAS_GIT
	@echo -e "$(RED)Error: git not found$(NC)"
	@exit 1
endif
	@echo -e "$(BLUE)Bumping patch version...$(NC)"
	@CURRENT=$$(cat VERSION | tr -d '[:space:]'); \
	MAJOR=$$(echo $$CURRENT | cut -d. -f1); \
	MINOR=$$(echo $$CURRENT | cut -d. -f2); \
	PATCH=$$(echo $$CURRENT | cut -d. -f3); \
	NEW_PATCH=$$((PATCH + 1)); \
	NEW_VERSION="$$MAJOR.$$MINOR.$$NEW_PATCH"; \
	echo "$$NEW_VERSION" > VERSION; \
	echo -e "$(GREEN)Version bumped: $$CURRENT → $$NEW_VERSION$(NC)"

.PHONY: version-bump-minor
version-bump-minor: ## Version: Bump minor version (0.X.0)
ifndef HAS_GIT
	@echo -e "$(RED)Error: git not found$(NC)"
	@exit 1
endif
	@echo -e "$(BLUE)Bumping minor version...$(NC)"
	@CURRENT=$$(cat VERSION | tr -d '[:space:]'); \
	MAJOR=$$(echo $$CURRENT | cut -d. -f1); \
	MINOR=$$(echo $$CURRENT | cut -d. -f2); \
	NEW_MINOR=$$((MINOR + 1)); \
	NEW_VERSION="$$MAJOR.$$NEW_MINOR.0"; \
	echo "$$NEW_VERSION" > VERSION; \
	echo -e "$(GREEN)Version bumped: $$CURRENT → $$NEW_VERSION$(NC)"

.PHONY: version-bump-major
version-bump-major: ## Version: Bump major version (X.0.0)
ifndef HAS_GIT
	@echo -e "$(RED)Error: git not found$(NC)"
	@exit 1
endif
	@echo -e "$(BLUE)Bumping major version...$(NC)"
	@CURRENT=$$(cat VERSION | tr -d '[:space:]'); \
	MAJOR=$$(echo $$CURRENT | cut -d. -f1); \
	NEW_MAJOR=$$((MAJOR + 1)); \
	NEW_VERSION="$$NEW_MAJOR.0.0"; \
	echo "$$NEW_VERSION" > VERSION; \
	echo -e "$(GREEN)Version bumped: $$CURRENT → $$NEW_VERSION$(NC)"

.PHONY: tag
tag: ## Version: Create git tag from VERSION file
ifndef HAS_GIT
	@echo -e "$(RED)Error: git not found$(NC)"
	@exit 1
endif
	@echo -e "$(BLUE)Creating git tag...$(NC)"
	@VERSION=$$(cat VERSION | tr -d '[:space:]'); \
	git tag -a "v$$VERSION" -m "Release v$$VERSION" && \
	echo -e "$(GREEN)✓ Tag v$$VERSION created$(NC)" && \
	echo -e "$(YELLOW)Push with: git push origin v$$VERSION$(NC)" || \
	(echo -e "$(RED)✗ Failed to create tag$(NC)" && exit 1)

.PHONY: status
status: ## Status: Show git status and current version
ifndef HAS_GIT
	@echo -e "$(RED)Error: git not found$(NC)"
	@exit 1
endif
	@echo -e "$(BLUE)=== Repository Status ===$(NC)"
	@echo -e "$(BLUE)Version:$(NC) $(VERSION)"
	@echo -e "$(BLUE)Extension:$(NC) $(EXTENSION_NAME)"
	@echo ""
	@git status -s

# -----------------------------------------------------------------------------
# CI/CD Helpers
# -----------------------------------------------------------------------------
.PHONY: ci
ci: clean lint test build ## CI: Run full CI pipeline
	@echo -e "$(GREEN)✓ CI pipeline complete$(NC)"

.PHONY: pre-commit
pre-commit: format lint test ## CI: Run pre-commit checks
	@echo -e "$(GREEN)✓ Pre-commit checks passed$(NC)"

.PHONY: info
info: ## Info: Show extension information
	@echo -e "$(BLUE)=== Extension Information ===$(NC)"
	@echo -e "$(BLUE)Name:$(NC)       $(EXTENSION_NAME)"
	@echo -e "$(BLUE)Version:$(NC)    $(VERSION)"
	@echo -e "$(BLUE)Dist dir:$(NC)   $(DIST)"
	@echo ""
	@echo -e "$(BLUE)=== Directory Structure ===$(NC)"
	@ls -la | grep "^d" || true
	@echo ""
	@echo -e "$(BLUE)=== Content Directories ===$(NC)"
	@for dir in bin sql rcv etc lib; do \
		if [ -d "$$dir" ]; then \
			count=$$(find "$$dir" -type f 2>/dev/null | wc -l); \
			echo -e "  $(GREEN)$$dir$(NC): $$count files"; \
		fi; \
	done

.PHONY: tools
tools: ## Tools: Show development tools status
	@echo -e "$(BLUE)=== Development Tools Status ===$(NC)"
	@echo ""
	@echo -e "$(BLUE)Required Tools:$(NC)"
ifdef HAS_SHELLCHECK
	@echo -e "  $(GREEN)✓$(NC) shellcheck  $$(shellcheck --version | head -n2 | tail -n1)"
else
	@echo -e "  $(RED)✗$(NC) shellcheck  (not found)"
	@echo -e "    $(YELLOW)Install: apt-get install shellcheck (Ubuntu) or brew install shellcheck (macOS)$(NC)"
endif
ifdef HAS_BATS
	@echo -e "  $(GREEN)✓$(NC) bats        $$(bats --version 2>/dev/null | head -n1)"
else
	@echo -e "  $(RED)✗$(NC) bats        (not found)"
	@echo -e "    $(YELLOW)Install: apt-get install bats (Ubuntu) or brew install bats-core (macOS)$(NC)"
endif
ifdef HAS_GIT
	@echo -e "  $(GREEN)✓$(NC) git         $$(git --version | cut -d' ' -f3)"
else
	@echo -e "  $(RED)✗$(NC) git         (not found)"
endif
	@echo ""
	@echo -e "$(BLUE)Optional Tools:$(NC)"
ifdef HAS_SHFMT
	@echo -e "  $(GREEN)✓$(NC) shfmt       $$(shfmt --version 2>/dev/null | head -n1)"
else
	@echo -e "  $(YELLOW)○$(NC) shfmt       (not found - optional)"
	@echo -e "    $(YELLOW)Install: go install mvdan.cc/sh/v3/cmd/shfmt@latest$(NC)"
endif
ifdef HAS_MARKDOWNLINT
	@echo -e "  $(GREEN)✓$(NC) markdownlint $$(markdownlint --version 2>/dev/null | head -n1)"
else
	@echo -e "  $(YELLOW)○$(NC) markdownlint (not found - optional)"
	@echo -e "    $(YELLOW)Install: npm install -g markdownlint-cli$(NC)"
endif
	@echo ""

# -----------------------------------------------------------------------------
# Quick Shortcuts
# -----------------------------------------------------------------------------
.PHONY: t l f b c
t: test ## Shortcut for 'test'
l: lint ## Shortcut for 'lint'
f: format ## Shortcut for 'format'
b: build ## Shortcut for 'build'
c: clean ## Shortcut for 'clean'
