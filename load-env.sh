#!/bin/sh
# Load the devshell
source ./env/env.bash

# load Q libraries from these folders
export QLIB=$PWD/modules/domain/src/main:$PWD/modules/kdb/src/main/q:$PWD/modules/kdb/src/test/q
# pick the first CPU by default
export QCPU=0
# move the DB out
export QDB=$PWD/qdb
mkdir -p "$QDB"
# select which Q license to use
export QLIC=$PWD/config/qlicenses/dev