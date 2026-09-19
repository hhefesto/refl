self:
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkEnableOption types mkIf;
  cfg = config.services.refl.profile;
  name = types.strMatching "[a-z_][a-z0-9_-]*";
  positive = types.ints.positive;
  package = self.packages.${pkgs.stdenv.hostPlatform.system}.isolated-site;
  address = if cfg.backend.address == "::1" then "[::1]" else cfg.backend.address;
  origin = if cfg.ingress.enable then "https://${cfg.hostname}${lib.optionalString (cfg.ingress.httpsPort != 443) ":${toString cfg.ingress.httpsPort}"}"
    else "http://${address}:${toString cfg.backend.port}";
in {
  options.services.refl.profile = {
    enable = mkEnableOption "the Refl proof game";
    serviceName = mkOption { type = name; default = "refl"; };
    user = mkOption { type = name; default = "refl"; };
    group = mkOption { type = name; default = "refl"; };
    stateDirectory = mkOption { type = name; default = "refl"; };
    runtimeDirectory = mkOption { type = name; default = "refl"; };
    backend.address = mkOption { type = types.enum [ "127.0.0.1" "::1" ]; default = "127.0.0.1"; };
    backend.port = mkOption { type = types.port; default = 3007; };
    hostname = mkOption { type = types.strMatching "[a-zA-Z0-9][a-zA-Z0-9.-]*"; default = "refl.hhefesto.com"; };
    ingress = {
      enable = mkEnableOption "nginx and ACME public ingress (requires working DNS)";
      httpPort = mkOption { type = types.port; default = 80; };
      httpsPort = mkOption { type = types.port; default = 443; };
    };
    limits = {
      memoryMiB = mkOption { type = positive; default = 2048; };
      cpuPercent = mkOption { type = positive; default = 100; };
      sessions = mkOption { type = positive; default = 4; };
      temporaryMiB = mkOption { type = positive; default = 256; };
      tasks = mkOption { type = positive; default = 128; };
      messageBytes = mkOption { type = positive; default = 65536; };
      commandSeconds = mkOption { type = positive; default = 120; };
      idleSeconds = mkOption { type = positive; default = 300; };
    };
  };
  config = mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = { isSystemUser = true; group = cfg.group; };
    systemd.services.${cfg.serviceName} = {
      description = "Refl proof game";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = cfg.stateDirectory;
        StateDirectoryMode = "0700";
        RuntimeDirectory = cfg.runtimeDirectory;
        RuntimeDirectoryMode = "0700";
        WorkingDirectory = "/run/${cfg.runtimeDirectory}";
        ExecStart = lib.escapeShellArgs [
          "${package}/bin/refl-site"
          "--host" cfg.backend.address "--port" (toString cfg.backend.port)
          "--origin" origin
          "--data-dir" "/var/lib/${cfg.stateDirectory}"
          "--work-dir" "/tmp/${cfg.runtimeDirectory}"
          "--max-sessions" (toString cfg.limits.sessions)
          "--message-bytes" (toString cfg.limits.messageBytes)
          "--command-seconds" (toString cfg.limits.commandSeconds)
          "--idle-seconds" (toString cfg.limits.idleSeconds)
        ];
        Restart = "on-failure";
        RestartSec = 2;
        UMask = "0077";
        MemoryMax = "${toString cfg.limits.memoryMiB}M";
        MemorySwapMax = 0;
        CPUQuota = "${toString cfg.limits.cpuPercent}%";
        TasksMax = cfg.limits.tasks;
        LimitNOFILE = 1024;
        LimitCORE = 0;
        KillMode = "control-group";
        TimeoutStopSec = 10;
        OOMPolicy = "kill";
        NoNewPrivileges = true;
        PrivateTmp = true;
        TemporaryFileSystem = "/tmp:rw,size=${toString cfg.limits.temporaryMiB}M,mode=1777";
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateDevices = true;
        # Masking individual /proc entries prevents an unprivileged nested
        # PID namespace from mounting procfs. Provers mount their own /proc;
        # the service has no host capabilities and /sys stays read-only.
        ProtectKernelTunables = false;
        ReadOnlyPaths = [ "/sys" ];
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        RestrictRealtime = true;
        CapabilityBoundingSet = "";
        # bubblewrap configures loopback through NETLINK_ROUTE after entering
        # its isolated network namespace. Blocking it prevents prover startup.
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
      };
    };
    services.nginx = mkIf cfg.ingress.enable {
      enable = true;
      virtualHosts.${cfg.hostname} = {
        forceSSL = true;
        enableACME = true;
        listen = [
          { addr = "0.0.0.0"; port = cfg.ingress.httpPort; }
          { addr = "0.0.0.0"; port = cfg.ingress.httpsPort; ssl = true; }
        ];
        locations."/" = {
          proxyPass = "http://${if cfg.backend.address == "::1" then "[::1]" else cfg.backend.address}:${toString cfg.backend.port}";
          proxyWebsockets = true;
        };
      };
    };
    networking.firewall.allowedTCPPorts = lib.optionals cfg.ingress.enable [ cfg.ingress.httpPort cfg.ingress.httpsPort ];
  };
}
