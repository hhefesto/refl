# A prover can observe only its session directory and this pinned tool closure.
# It cannot see progress, other sessions, host files, or the host network.
{ pkgs, executable, paths, variables ? { } }:
let
  closure = pkgs.closureInfo { rootPaths = paths; };
  inherit (pkgs) lib;
in pkgs.writeShellScriptBin "refl-prover" ''
  set -euo pipefail
  session="$PWD"
  mounts=()
  while IFS= read -r path; do
    mounts+=(--ro-bind "$path" "$path")
  done < ${closure}/store-paths
  exec ${pkgs.bubblewrap}/bin/bwrap \
    --unshare-all --die-with-parent --new-session \
    --clearenv --setenv HOME "$session/home" \
    --setenv TMPDIR /tmp --setenv TZ UTC \
    ${lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "--setenv ${lib.escapeShellArg k} ${lib.escapeShellArg v}") variables)} \
    --proc /proc --dev /dev --size 16777216 --tmpfs /tmp \
    --dir /etc --ro-bind ${pkgs.tzdata}/share/zoneinfo/UTC /etc/localtime \
    "''${mounts[@]}" --bind "$session" "$session" --chdir "$session" \
    ${executable} "$@"
''
