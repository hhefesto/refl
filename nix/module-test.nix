# Boot a real NixOS VM and run native/shell assertions. No Python test driver.
{ self, nixpkgs, pkgs, system }:
let
  probe = import ./prover-sandbox.nix {
    inherit pkgs;
    executable = "${pkgs.bash}/bin/bash";
    paths = [ pkgs.bash pkgs.coreutils pkgs.iproute2 ];
    variables.PATH = pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.iproute2 ];
  };
  machine = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.default
      "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
      ({ config, ... }: {
        system.stateVersion = "26.05";
        networking.hostName = "refl-test";
        boot.consoleLogLevel = 7;
        boot.kernelParams = [ "systemd.show_status=1" ];
        virtualisation = {
          memorySize = 4096;
          cores = 2;
          graphics = false;
          diskImage = null;
          sharedDirectories.results = { source = ''"$REFL_TEST_RESULTS"''; target = "/tmp/results"; };
        };
        services.refl.profile = {
          enable = true;
          serviceName = "proof-lab";
          user = "proof-user";
          group = "proof-group";
          stateDirectory = "proof-state";
          runtimeDirectory = "proof-runtime";
          backend.port = 8125;
          limits.idleSeconds = 2;
        };
        # Composition: these existing services must not be pulled in by Refl.
        assertions = [
          { assertion = !config.services.nginx.enable; message = "staging enables nginx"; }
          { assertion = !config.services.postgresql.enable; message = "Refl enables PostgreSQL"; }
          { assertion = config.networking.firewall.allowedTCPPorts == []; message = "staging opens a firewall port"; }
        ];
        environment.systemPackages = [ pkgs.curl pkgs.util-linux pkgs.procps ];
        systemd.services.verify-refl = {
          wantedBy = [ "multi-user.target" ];
          after = [ "proof-lab.service" ];
          unitConfig.RequiresMountsFor = [ "/tmp/results" ];
          path = [ pkgs.coreutils pkgs.curl pkgs.util-linux pkgs.gnugrep pkgs.procps ];
          serviceConfig = { Type = "oneshot"; TimeoutStartSec = 300; };
          script = ''
            exec > >(tee /tmp/results/test.log /dev/console) 2>&1
            # Let tee drain to the shared directory before the VM goes away.
            finish() { sync; sleep 2; systemctl poweroff --no-block; }
            trap finish EXIT
            set -euxo pipefail
            for i in $(seq 1 60); do
              curl -fs http://127.0.0.1:8125/api/health && break
              sleep 1
            done
            ${self.packages.${system}.refl-backend}/bin/refl-security-test
            cg=/sys/fs/cgroup/system.slice/proof-lab.service
            test "$(cat "$cg/memory.max")" = 2147483648
            test "$(cat "$cg/memory.swap.max")" = 0
            test "$(cat "$cg/cpu.max")" = '100000 100000'
            test "$(cat "$cg/pids.max")" = 128
            test "$(stat -c %U /var/lib/proof-state)" = proof-user
            test "$(stat -c %a /var/lib/proof-state)" = 700
            test "$(stat -c %U /run/proof-runtime)" = proof-user
            pid=$(systemctl show proof-lab -p MainPID --value)
            # Disconnected and idle sessions must leave no prover or work directory.
            sleep 3
            test "$(wc -l < "$cg/cgroup.procs")" = 1
            test -z "$(nsenter -t "$pid" -m -- find /tmp/proof-runtime/sessions -mindepth 1 -print -quit)"
            # Fill the service's actual temporary mount. It must stop at 256 MiB.
            if nsenter -t "$pid" -m -- dd if=/dev/zero of=/tmp/exhaust bs=1M count=260; then
              echo 'temporary storage was unbounded'; exit 1
            fi
            nsenter -t "$pid" -m -- rm /tmp/exhaust
            curl -fs http://127.0.0.1:8125/api/health
            # Same isolation wrapper used by all three production provers.
            mkdir -p /tmp/probe /tmp/sibling
            touch /root/refl-host-secret /tmp/sibling/other-session
            chown proof-user:proof-group /tmp/probe
            cd /tmp/probe
            runuser -u proof-user -- ${probe}/bin/refl-prover -c '
              test ! -e /root/refl-host-secret
              test ! -e /var/lib/proof-state
              test ! -e /tmp/sibling/other-session
              test ! -e /etc/passwd
              test "$(ls /sys/class/net 2>/dev/null | wc -l)" = 0
              test "$(ip -o link | wc -l)" = 1
              test -z "$(ip route)"
              echo own-session > ./writable
              if touch ${pkgs.bash}/forbidden; then exit 1; fi
            '
            test -f /tmp/probe/writable
            # Memory exhaustion in the *actual* aggregate cgroup must kill it,
            # then Restart=on-failure must recover without retaining workers.
            before=$(systemctl show proof-lab -p NRestarts --value)
            (echo "$BASHPID" > "$cg/cgroup.procs"; exec ${pkgs.coreutils}/bin/tail /dev/zero) >/dev/null &
            stress=$!
            for i in $(seq 1 60); do
              after=$(systemctl show proof-lab -p NRestarts --value)
              if [ "$after" -gt "$before" ]; then break; fi
              sleep 1
            done
            wait "$stress" || true
            test "$after" -gt "$before"
            for i in $(seq 1 60); do
              curl -fs http://127.0.0.1:8125/api/health && break
              sleep 1
            done
            systemctl is-active --quiet proof-lab
            test "$(wc -l < "$cg/cgroup.procs")" = 1
            touch /tmp/results/passed
          '';
        };
      })
    ];
  };
# Needs KVM: under TCG the boot alone exceeds the budget. Exposed as
# packages.module-test rather than a check so `nix flake check` stays
# runnable on hosts without /dev/kvm.
in pkgs.runCommand "refl-nixos-module-test" {
  nativeBuildInputs = [ pkgs.coreutils ];
  requiredSystemFeatures = [ "kvm" "nixos-test" ];
} ''
  export REFL_TEST_RESULTS=$TMPDIR/results
  # qemu-vm.nix always exports $TMPDIR/xchg (and SHARED_DIR, defaulting to
  # it) over virtfs; QEMU refuses to start when the directory is missing.
  mkdir -p "$REFL_TEST_RESULTS" "$TMPDIR/xchg"
  timeout 1200 ${machine.config.system.build.vm}/bin/run-refl-test-vm > $TMPDIR/console.log 2>&1 || {
    cat "$REFL_TEST_RESULTS/test.log" $TMPDIR/console.log
    exit 1
  }
  cat "$REFL_TEST_RESULTS/test.log" || true
  if ! test -f "$REFL_TEST_RESULTS/passed"; then
    cat $TMPDIR/console.log
    exit 1
  fi
  cp "$REFL_TEST_RESULTS/test.log" $out
''
