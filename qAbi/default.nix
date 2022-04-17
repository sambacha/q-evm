{ stdenv, fetchFromGitHub, gmp, ... }:
stdenv.mkDerivation {
  pname = "qAbiEncode";
  version = "0.0.0+unstable";

  src = fetchFromGitHub {
    owner = "manifoldfinance";
    repo = "qAbiEncode";
    rev = "4445a051ec6b7f457dff5b3a18238c064210390a";
    sha256 = "14ib6pi2j27mfm8i9p3144n5v0g4hkrmdggl0l0g7yi7x5ckkhkj";
  };

  NIX_CFLAGS_COMPILE = "-I${gmp.dev}/include";
  NIX_CFLAGS_LINK = "-L${gmp.out}/lib";

  installPhase = ''
    ls -la
    install -Dm644 abi.q $out/q/abi.q
    install -Dm644 qKeccak.so $out/q/l64/qKeccak.so
    strip $out/q/l64/*.so
  '';
}