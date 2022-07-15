{ stdenv
, autoPatchelfHook
, bash
, coreutils
, libredirect
, lndir
, makeWrapper
, qLibs
, rlwrap
, runCommand
, shellcheck
, util-linux
, writeTextFile
}:
let
  # From https://code.kx.com/q4m3/14_Introduction_to_Kdb+/#1481-the-environment-variables,
  # set QHOME to the location of `q.k`.
  # To pass in a license, invoke q with QLIC set to the *directory* in which
  # kc.lic is located.
  # Other .q (or .k) files are loaded with `\l path/to/file`.
  # .so files are loaded by defining their name/path when defining the function:
  # https://code.kx.com/q/interfaces/using-c-functions/

  version = "4.0-2020.05.04";

  # Package that contains just the stdlib
  q-stdlib = writeTextFile {
    name = "q-stdlib-${version}";
    destination = "/q/q.k";
    text = builtins.readFile ./q.k;
  };

  # The Q unwrapped binary
  q-bin = stdenv.mkDerivation {
    pname = "q-bin";
    inherit version;
    dontUnpack = true;

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    doBuild = false;

    installPhase = ''
      runHook preInstall
      install -Dm755 ${./q} $out
      runHook postInstall
    '';
  };

  # This is a wrapper for the Q binary that is extended with a number of
  # features.
  #
  # See the comments in the script for more details.
  q-wrapper = writeTextFile {
    name = "q-${version}";
    destination = "/bin/q";
    executable = true;
    checkPhase = "${shellcheck}/bin/shellcheck $out/bin/q";
    text = ''
      #!${bash}/bin/bash
      # A wrapper for the Q binary extended with more environment variables.
      #
      # See the table below in the Globals for more details.
      set -euo pipefail

      ### Globals ###

      # On which CPU the process should be pinned.
      : "''${QCPU:=}"
      # In which folder the database should be stored.
      : "''${QDB:=''${QHOME:-$QHOME/db}}"
      # A root folder for the Q binary to load libraries from.
      : "''${QHOME:=}"
      # Extend QHOME with a list of paths to load libraries from. The paths
      # must be absolute.
      : "''${QLIB:=}"
      # Override in which directory to look for to load the Q license.
      : "''${QLIC:=}"

      # This is the load order, by order of precedence
      QLIB=''${QHOME:+$QHOME:}''${QLIB:+$QLIB:}${qLibs}/q:${q-stdlib}/q

      # Temporary work dir with all of QLIB merged into.
      qhome=$(${coreutils}/bin/mktemp -d)

      ### Functions ###

      log() {
        echo "[''$$]$*" >&2
      }

      # Cleanup to execute on process termination.
      at_exit() {
        local ret=$? pid=
        set +e
        # Make sure to forward the signal
        pid=$(jobs -p)
        if [[ -n $pid ]]; then
          log "killing $pid"
          kill "$pid"
          wait "$pid"
        fi
        if [[ -n $qhome ]]; then
          log "cleaning $qhome"
          rm -rf "$qhome"
        fi
        exit "$ret"
      }

      ### Main ###

      # Setup a callback on process termination
      trap at_exit EXIT

      # Build the symlink tree
      IFS=:
      for dir in $QLIB; do
        ${lndir}/bin/lndir -silent "$dir" "$qhome"
      done
      IFS=' '

      # Change directory into the Q DB
      if [[ -n $QDB ]]; then
        cd "$QDB"
      else
        log "warn: QDB and QHOME are unset. The db will be written to the current directory."
      fi

      # Point Q to the symlink filesystem
      export QHOME=$qhome
      cmd=(${q-bin} "$@")
      # Wrap if stdin is interactive
      # XXX: this breaks libredirect
      # if [[ -t 0 ]]; then
      #   cmd=(${rlwrap}/bin/rlwrap "''${cmd[@]}")
      # fi
      log "QCPU=$QCPU"
      # Bind to one CPU
      if [[ -n $QCPU ]]; then
        ${util-linux}/bin/taskset -pc "$QCPU" ''$$
      else
        ${util-linux}/bin/taskset -p ''$$
      fi
      log "QDB=$QDB"
      log "QHOME=$QHOME"
      log "QLIB=$QLIB"
      log "QLIC=$QLIC"

      log "\$''${cmd[*]}"
      # Run!
      NIX_REDIRECTS=/q/=$QHOME/ LD_PRELOAD=${libredirect}/lib/libredirect.so "''${cmd[@]}"
    '';
  };
in
q-wrapper
