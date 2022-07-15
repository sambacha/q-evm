{ system ? builtins.currentSystem
  , nixpkgs ? import ./nixpkgs.nix { inherit system; }
  }:
  let
    sources = import ./sources.nix;
    devshell = import sources.devshell { pkgs = nixpkgs; };
    tf = nixpkgs.terraform.withPlugins (p: [
      p.aws
      p.cloudflare
      p.external
      p.grafana
      (nixpkgs.callPackage ./pkgs/terraform-provider-htpasswd { })
      p.helm
      p.http
      p.kafka
      p.kubernetes
      p.local
      p.null
      p.random
      p.secret
      p.template
      p.tls
    ]);

    
# Q third-party libs
  kfk = nixpkgs.callPackage ./pkgs/kfk { }; # "kafka-kdb"
  log4q = nixpkgs.callPackage ./pkgs/log4q { };
  protobufkdb = nixpkgs.callPackage ./pkgs/protobufkdb { };
  qAbiEncode = nixpkgs.callPackage ./pkgs/qAbiEncode { };
  qbigint = nixpkgs.callPackage ./pkgs/qbigint { };
  qquartic = nixpkgs.callPackage ./pkgs/qquartic { };
  qunit = nixpkgs.callPackage ./pkgs/qunit { };
  qwebapi = nixpkgs.callPackage ./pkgs/qwebapi { };
  # Bundle them all into one big package
  qVendorLibs = nixpkgs.symlinkJoin {
    name = "q-libs";
    paths = [
      kfk
      log4q
      protobufkdb
      qAbiEncode
      qbigint
      qquartic
      qunit
      qwebapi
    ];
  };

  q = nixpkgs.callPackage ./pkgs/q {
    # Make those part of the base binary
    qLibs = qVendorLibs;
  };

  # kdb source
  kdbLibs = nixpkgs.symlinkJoin {
    name = "kdb-libs";
    paths = [
      # Get the protobufs
      (nixpkgs.runCommandNoCC "manifold-protos-q" { } ''
        mkdir -p $out/q/proto
        cp ${manifoldProtos}/*.proto $out/q/proto
      '')
      # Get the rest of the source
      (nixpkgs.runCommandNoCC "manifold-q"
        {
          src = builtins.path {
            path = ../modules/kdb/src/main/q;
            filter = name: type:
              with nixpkgs.lib;
              if type == "directory" then
              # Avoid adding the old DB folder in there
                ! hasSuffix "/db" name
              else # regular files
              # Only add .q and .sh files
                hasSuffix ".q" name || hasSuffix ".sh" name;
          };
        } ''
        mkdir $out
        cp -r $src $out/q
        chmod +w $out/q
        patchShebangs $out/q
      '')
    ];
  };

    kdb-container = nixpkgs.dockerTools.buildLayeredImage {
    name = "<% NAME %>";
    tag = "dev";
    contents = [
      nixpkgs.bashInteractive # for debugging
      nixpkgs.coreutils
      nixpkgs.gnused
      nixpkgs.dockerTools.fakeNss # otherwise q just outputs pwuid
      q
      kdbLibs
    ];
    maxLayers = 15;
    config = {
      Cmd = [ "/q/start.sh" ];
      Env = [
        "QHOME=/q"
        "QDB=/qdb"
      ];
      Volumes = {
        "/qdb" = { };
      };
      WorkingDir = "/";
    };
    extraCommands = ''
      # make sure /tmp exists
      mkdir -m 1777 tmp
    '';
  };


    packages = [
        # Used to invoke q scripts
      nixpkgs.rlwrap
      q


    commands = [
      { name = "gradle"; category = "dev"; help = "gradle build system"; command = ''$PRJ_ROOT/gradlew "$@"''; }
      { name = "j"; category = "dev"; help = "just a command runner"; command = ''${nixpkgs.just}/bin/just "$@"''; }
      { category = "dev"; package = nixpkgs.yarn; }
      { name = "tf"; category = "ops"; help = "terraform alias"; command = ''${tf}/bin/terraform "$@"''; }
    ];
  };


  nixos-configs = (nixpkgs.lib.recurseIntoAttrs (import ../ops/nixos/configs { inherit (nixpkgs) lib nixos; }));
}