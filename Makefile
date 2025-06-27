ifdef HAS_GIT
GIT_SHORT_COMMIT := $(shell git rev-parse --short HEAD)
GIT_TAG    := $(shell git describe --tags --abbrev=0 --exact-match 2>/dev/null)
GIT_DIRTY  = $(shell test -n "`git status --porcelain`" && echo "dirty" || echo "clean")

TMP_VERSION := canary

BINARY_VERSION := ""

ifndef VERSION
ifeq ($(GIT_DIRTY), clean)
ifdef GIT_TAG
	TMP_VERSION = $(GIT_TAG)
	BINARY_VERSION = $(GIT_TAG)
endif
endif
else
  BINARY_VERSION = $(VERSION)
endif

endif

VERSION ?= $(TMP_VERSION)

# Semantic Release
.PHONY: semantic-release-dependencies
semantic-release-dependencies:
	@npm install --save-dev semantic-release
	@npm install @semantic-release/exec conventional-changelog-conventionalcommits -D

.PHONY: semantic-release
semantic-release: semantic-release-dependencies
	@npm ci
	@npx semantic-release

.PHONY: semantic-release-ci
semantic-release-ci: semantic-release-dependencies
	@npx semantic-release

.PHONY: semantic-release-dry-run
semantic-release-dry-run: semantic-release-dependencies
	@npm ci
	@npx semantic-release -d

.PHONY: export-tag-github-actions
export-tag-github-actions:
	@echo "version=$(VERSION)" >> $${GITHUB_OUTPUT}