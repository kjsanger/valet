VERSION := $(shell git describe --always --tags --dirty)
ldflags := "-X github.com/wtsi-npg/valet/valet.Version=${VERSION}"
build_args := -a -v -ldflags ${ldflags}

build_path = "build/valet-${VERSION}"

CGO_ENABLED?=${CGO_ENABLED}

.PHONY: build coverage dist install lint test check clean

all: build

install:
	go install ${build_args}

build:
	mkdir -p ${build_path}
	GOOS=linux GOARCH=amd64 go build ${build_args} -o ${build_path}/valet github.com/wtsi-npg/valet

lint:
	golangci-lint run ./...

check: test

test:
	GOOS=linux GOARCH=amd64 ginkgo -r --race

coverage:
	GOOS=linux GOARCH=amd64 ginkgo -r --cover -coverprofile=coverage.out

dist: build test
	cp README.md COPYING ${build_path}
	mkdir ${build_path}/scripts
	cp scripts/valet_archive_create.sh ${build_path}/scripts/
	tar -C ./build -cvj -f valet-${VERSION}.tar.bz2 valet-${VERSION}
	shasum -a 256 valet-${VERSION}.tar.bz2 > valet-${VERSION}.tar.bz2.sha256

clean:
	go clean
	rm -rf build/*
