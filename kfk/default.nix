{ stdenv, fetchFromGitHub, rdkafka, zlib, openssl, ... }:

let
  version = "1.5.0";
  kdbSrc = fetchFromGitHub {
    owner = "KxSystems";
    repo = "kdb";
    rev = "39b957030bf6a4608f2508ff29894d7fac32a0c2";
    sha256 = "0r0yfnfn2g89hc7gvk2y1d568lkda0463jw3ha1gg8h83v1vm63f";
  };
in
stdenv.mkDerivation {
  inherit version;
  name = "kfk-${version}";

  src = fetchFromGitHub {
    owner = "KxSystems";
    repo = "kafka";
    rev = "v${version}";
    sha256 = "1yi9f8gy3nv5hncd0qh9q2lzk315pavf3bkc5wq48ki0yxllhaqf";
  };

  # The Makefile downloaded k.h from kdb repo, master branch.
  # Patch this out, and copy it into $src after unpack.
  patches = [ ./0001-Makefile-don-t-download-k.h-from-github-master-branc.patch ];

  preConfigure = ''
    cp ${kdbSrc}/c/c/k.h .
  '';

  #NIX_CFLAGS_COMPILE = "-I.";
  NIX_CFLAGS_LINK = "-L${zlib.out}/lib -L${openssl.out}/lib";

  makeFlags = [
    "KAFKA_ROOT=${rdkafka}"
  ];

  # override install phase, cause their `make install` is bonkers, and we only
  # really care about libkfk.so anyways.
  installPhase = ''
    install -Dm644 kfk.q $out/q/kfk.q
    install -Dm644 libkfk.so $out/q/l64/libkfk.so
    strip $out/q/l64/*.so
  '';

  meta = {
    description = "A thin wrapper for kdb+ around librdkafka C API for Kafka";
  };
}
