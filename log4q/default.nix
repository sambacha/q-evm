{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation {
  pname = "log4q";
  version = "0.0.0+unstable";

  src = fetchFromGitHub {
    owner = "prodrive11";
    repo = "log4q";
    rev = "932f33bfeab3f1faa60aac187d23bacc9bf1bd9e";
    sha256 = "sha256-Zr/GSicHerr1KGMUBvFlZSkR/HTBgVOp0BjEMYR5seI=";
  };

  patches = [ ./0001-log4q-use-logfmt-format.patch ];

  installPhase = ''
    install -D log4q.q $out/q/log4q.q
  '';
}
