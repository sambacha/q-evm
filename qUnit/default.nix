{ lib, runCommand, fetchurl }:
let
  src = fetchurl {
    url = "https://raw.githubusercontent.com/timeseries/kdb/18822dd8d932d429b8ebacbbde2e3624440d5777/qunit/qunit.q";
    hash = "sha256-UaWtQ8WSVAhQb6mAoKon42iNeTvbAUg9ltABd0RNgrA=";
  };
in
runCommand "qunit" { } ''
  mkdir -p $out
  install -D ${src} $out/q/qunit.q
''