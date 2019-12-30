BIN={{ project }}
PKG=github.com/{{ package }}
CLI_VERSION=`cat .version`
GOOS?=linux
BUILD_DIR=./build/bin

M = $(shell printf "\033[34;1m◉\033[0m")

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

.PHONY: build
build: build-dir; $(info $(M) building ...)                         @ ## build the binary
	@GOOS=$(GOOS) go build \
		-ldflags "-X main.version=$(CLI_VERSION) -X main.compiled=$(date +%s)" \
		-o ./build/bin/$(BIN) ./cmd/main.go

.PHONEY: build-dir
build-dir: ;
	@[ ! -d "${BUILD_DIR}" ] && mkdir -vp "${BUILD_DIR}/public" || true

.PHONY: proto
proto: ; $(info $(M) running protoc commands...)                    @ ## code generation from .proto files
	@rm *.pb.go 2> /dev/null || true
	@for i in `ls proto`;   \
		do                  \
			protoc			\
			-Iproto			\
			-I$(GOPATH)/src \
			-I$(GOPATH)/src/$(PKG)/proto \
			-I$(GOPATH)/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
			--go_out=plugins=grpc,paths=source_relative:. \
			--grpc-gateway_out=logtostderr=true,paths=source_relative,allow_delete_body=true:. \
			"proto/$${i}"; 	\
		done
	@sed -i 's/json:"id,omitempty"/json:"id,omitempty" bson:"_id"/g' dope.pb.go

.PHONY: help
help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

