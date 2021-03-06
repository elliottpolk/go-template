BIN={{ project }}
PKG={{ repo }}/{{ project }}
CLI_VERSION=`cat .version`
GOOS?=linux
BUILD_DIR=./build/bin

M = $(shell printf "\033[38;5;33;1m◉\033[0m")

default: clean build ;                                              @ ## defaulting to clean and build

.PHONY: all
all: clean build

.PHONY: clean
clean: ; $(info $(M) running clean ...)                             @ ## clean up the old build dir
	@rm -vrf build

.PHONY: test
test: unit-test;													@ ## wrapper to run all testing

.PHONY: unit-test
unit-test: ; $(info $(M) running unit tests...)                     @ ## run the unit tests
	@go get -v -u
	@go test -cover ./...

.PHONEY: build-dir
build-dir: ;
	@[ ! -d "${BUILD_DIR}" ] && mkdir -vp "${BUILD_DIR}/public" || true

.PHONY: build
build: build-dir; $(info $(M) building ...)                         @ ## build the binary
	@GOOS=$(GOOS) go build \
		-ldflags "-X main.version=$(CLI_VERSION) -X main.compiled=$(date +%s)" \
		-o ./build/bin/$(BIN) ./cmd/main.go

.PHONY: install
install: build-dir; $(info $(M) installing ...)             		@ ## install the binary locally
	@GOOS=$(GOOS) go build -ldflags "-X main.version=$(VERSION) -X main.compiled=$(date +%s)" -o $(GOPATH)/bin/$(BIN) ./cmd

.PHONY: help
help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

