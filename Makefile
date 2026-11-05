# Reuse the existing RAE checks at an immutable source revision.
GO ?= go
VALE ?= vale
RAE_VERSION := v0.0.0-20261104214245-9b3146bf4d8a
RAE_TOOLS := github.com/OpenRAE/rae/implementations/tooling/go
TOOLS_BIN := $(CURDIR)/.tools/bin
export GOTOOLCHAIN := local
export GOWORK := off
export GOFLAGS := -mod=readonly

.PHONY: tools check build lint format architecture wiring policy precommit test test-ci regression mutation design-acceptance docs

tools:
	mkdir -p "$(TOOLS_BIN)"
	$(GO) mod download -json $(RAE_TOOLS)@$(RAE_VERSION) > .tools/rae-module.json
	$(GO) -C "$$(jq -er .Dir .tools/rae-module.json)" build -o "$(TOOLS_BIN)/" ./cmd/archcheck ./cmd/raesvet ./cmd/regressiontest github.com/golangci/golangci-lint/v2/cmd/golangci-lint
	GOBIN="$(TOOLS_BIN)" $(GO) install github.com/zricethezav/gitleaks/v8@v8.30.1

build:
	$(GO) -C implementations/go build ./...

lint:
	cd implementations/go && "$(TOOLS_BIN)/golangci-lint" run ./...
	$(GO) -C implementations/go vet -vettool="$(TOOLS_BIN)/raesvet" ./...

format:
	cd implementations/go && "$(TOOLS_BIN)/golangci-lint" fmt ./...

architecture:
	"$(TOOLS_BIN)/archcheck"

wiring:
	"$(TOOLS_BIN)/archcheck" -view

policy: architecture
	git diff --check
	jq -r '.files[] | "\(.sha256)  \(.destination_path)"' docs/source-manifest.json | sha256sum --check --strict

docs:
	$(VALE) README.md AGENTS.md CONTRIBUTING.md THIRD_PARTY_NOTICES.md .gc/plan-rules.md docs/architecture.md

check: build lint policy docs
	$(GO) -C implementations/go mod tidy -diff
	$(GO) -C implementations/go mod verify

precommit: policy
	"$(TOOLS_BIN)/gitleaks" git --staged --redact --no-banner

# Local test runs always name the relevant package and case.
test:
	@test -n "$(PACKAGE)" -a -n "$(TEST)" || { echo 'Set PACKAGE and TEST for a targeted test run.' >&2; exit 2; }
	$(GO) -C implementations/go test -race -run '$(TEST)' '$(PACKAGE)'

# CI only: preserve race detection and the existing 90% statement floor.
test-ci:
	@test "$$CI" = true || { echo 'Full tests run in CI only.' >&2; exit 2; }
	mkdir -p .tools
	$(GO) -C implementations/go test -race -covermode=atomic -coverprofile="$(CURDIR)/.tools/cover.out" ./...
	@if test "$$(wc -l < .tools/cover.out)" -gt 1; then \
	  $(GO) tool cover -func=.tools/cover.out | awk '/^total:/ { sub(/%/, "", $$3); found=1; if ($$3 < 90) exit 1 } END { if (!found) exit 1 }'; \
	else echo 'No executable statements in the bootstrap package.'; fi

regression:
	@test -n "$(BASE)" || { echo 'Set BASE to the comparison commit.' >&2; exit 2; }
	cd implementations/go && "$(TOOLS_BIN)/regressiontest" -base "$(BASE)"

mutation:
	@test "$$CI" = true || { echo 'Mutation runs are CI only.' >&2; exit 2; }
	@test -n "$(BASE)" || { echo 'Set BASE to the comparison commit.' >&2; exit 2; }
	$(GO) -C "$$(jq -er .Dir .tools/rae-module.json)" build -o "$(TOOLS_BIN)/gremlins" github.com/go-gremlins/gremlins/cmd/gremlins
	cd implementations/go && "$(TOOLS_BIN)/gremlins" unleash --workers 2 --config ../.gremlins.yaml --diff "$(BASE)"

design-acceptance:
	@bash tools/design-acceptance.sh
