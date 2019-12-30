#!/bin/bash

INFO() {
	printf "\033[38;5;33;1m◉\033[0m $1 \n"
}

WARN() {
	printf "\033[38;5;197;1m◉\033[0m $1 \n"
}

PROMPT() {
	printf "\033[38;5;123;1m◉\033[0m $1: "
}

PROMPT "Project name"
read PROJECT

[ -z "$PROJECT" ] && WARN "Invalid project name" && exit 1
[ -d "$PROJECT" ] && WARN "Project already exists" && exit 1

PROMPT "Author"
read AUTHOR

PROMPT "Organization"
read ORG

PROMPT "Repo"
read REPO

PROMPT "Initial version (1.0.0)"
read VERSION

mkdir ${PROJECT}
cd ${PROJECT}

INFO "generating standard go repo layout"
mkdir -p cmd server/ui

INFO "generating .gitignore"
curl -sSf https://raw.githubusercontent.com/elliottpolk/go-template/master/gitignore 1>> .gitignore

INFO "generating license"
curl -sSf https://raw.githubusercontent.com/licenses/license-templates/master/templates/mit.txt 1>> LICENSE
sed -i "s|{{ year }}|$(date +%Y)|g" LICENSE
sed -i "s|{{ organization }}|${ORG}|g" LICENSE

INFO "generating Makefile"
curl -sSf https://raw.githubusercontent.com/elliottpolk/go-template/master/Makefile 1>> Makefile
sed -i "s|{{ project }}|${PROJECT}|g" Makefile
sed -i "s|{{ repo }}|${REPO}|g" Makefile

INFO "generating version file"
tee <<EOF > .version
${VERSION:-"1.0.0"}
EOF

INFO "initializing go mod"
go mod init 2> /dev/null

INFO "generating stub main.go"
tee <<EOF > cmd/main.go
package main

import (
	"fmt"
	"os"
	"strconv"
	"time"

	cli "github.com/urfave/cli/v2"
)

var (
	version  string
	compiled string = fmt.Sprint(time.Now().Unix())
)

func main() {
	ct, err := strconv.ParseInt(compiled, 0, 0)
	if err != nil {
		panic(err)
	}

	app := cli.App {
		Name:      "${PROJECT}",
		Copyright: "Copyright © $(date +%Y) ${ORG}",
		Version:   version,
		Compiled:  time.Unix(ct, -1),
		Commands:  []*cli.Command{},
	}

	app.Run(os.Args)
}
EOF

INFO "initializing git repo"
git init 1> /dev/null
