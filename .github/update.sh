#!/usr/bin/env bash
set -ex

echo "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" > "hash"

# try (and fail) building, to get SRI hash of cargo deps
(set +e; nix build |& tee out)

# parse output, get hash, save
awk '/got: / {print $2}' out > "hash"

function clean() { rm -rf out; }
trap clean EXIT