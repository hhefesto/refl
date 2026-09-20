self:
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkEnableOption types mkIf;
  cfg = config.services.refl.profile;
  name = types.strMatching "[a-z_][a-z0-9_-]*";
  positive = types.ints.positive;
  package = self.packages.${pkgs.stdenv.hostPlatform.system}.isolated-site;
  address = if lib.hasInfix ":" cfg.backend.address then "[${cfg.backend.address}]" else cfg.backend.address;
  origin = if cfg.ingress.enable then "https://${cfg.hostname}${lib.optionalString (cfg.ingress.httpsPort != 443) ":${toString cfg.ingress.httpsPort}"}"
    else "http://${address}:${toString cfg.backend.port}";
  credential = "/run/credentials/${cfg.serviceName}.service/dashboard-password";
  passwordFile =
    if cfg.dashboard.passwordFile != null then cfg.dashboard.passwordFile
    else if cfg.dashboard.password != "" then pkgs.writeText "refl-dashboard-password" cfg.dashboard.password
    else null;
in {
  options.services.refl.profile = {
    enable = mkEnableOption "the Refl proof game";
    serviceName = mkOption { type = name; default = "refl"; };
    user = mkOption { type = name; default = "refl"; };
    group = mkOption { type = name; default = "refl"; };
    stateDirectory = mkOption { type = name; default = "refl"; };
    runtimeDirectory = mkOption { type = name; default = "refl"; };
    backend.address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listening address: loopback behind the ingress, or a public address for plain-http operation without it (the browser then gets a non-Secure cookie).";
    };
    backend.trustedProxyRanges = mkOption {
      type = types.listOf types.str;
      default = lib.optionals cfg.ingress.enable [ "127.0.0.1/32" "::1/128" ];
      description = "Peer CIDRs allowed to supply X-Real-IP. Standalone defaults to none.";
    };
    backend.port = mkOption { type = types.port; default = 3007; };
    backend.openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open backend.port in the firewall (plain http on a public address, no ingress).";
    };
    hostname = mkOption {
      type = types.nullOr (types.strMatching "[a-zA-Z0-9][a-zA-Z0-9.-]*");
      default = null;
      description = "Public host name of the nginx and ACME ingress; required when ingress.enable is set.";
    };
    ingress = {
      enable = mkEnableOption "nginx and ACME public ingress (requires working DNS)";
      httpPort = mkOption { type = types.port; default = 80; };
      httpsPort = mkOption { type = types.port; default = 443; };
      trustedProxyRanges = mkOption {
        type = types.listOf types.str;
        default = import ./cloudflare-ranges.nix;
        description = ''
          Networks whose CF-Connecting-IP header is believed. Empty disables
          real-IP recovery, and every visit then geolocates to the proxy.
        '';
      };
    };
    analytics = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Record visits under <state>/analytics. No IP address is ever
          written: the address is resolved to a country on arrival and
          dropped, and the only per-person key is the anonymous cookie the
          site already sets for progress.
        '';
      };
      retentionDays = mkOption { type = positive; default = 400; };
      geoipDatabase = mkOption {
        type = types.nullOr types.path;
        default = "${pkgs.dbip-country-lite}/share/dbip/dbip-country-lite.mmdb";
        defaultText = "dbip-country-lite (8 MiB)";
        description = ''
          MaxMind-format database used to turn an address into a country.
          null drops it from the closure and leaves the map empty;
          pkgs.dbip-city-lite is the same thing at city resolution and
          125 MiB. Both are CC BY 4.0, so the dashboard credits DB-IP.
        '';
      };
    };
    dashboard = {
      password = mkOption {
        type = types.str;
        default = "";
        description = ''
          Password for /dashboard/ (user: refl). Convenient, but it lands
          in the world-readable Nix store -- prefer passwordFile. Empty and
          no passwordFile means the dashboard is off and answers 403.
        '';
      };
      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          File holding the dashboard password, delivered to the unit by
          systemd LoadCredential so it never reaches ExecStart. The host
          config points this at an agenix secret; this flake ships one at
          secrets/refl-dashboard-password.age. Unset, and with no password,
          the dashboard stays off and answers 403.
        '';
      };
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
    assertions = [
      { assertion = cfg.ingress.enable -> cfg.hostname != null;
        message = "services.refl.profile.hostname is required when ingress.enable is set"; }
      { assertion = !(cfg.dashboard.password != "" && cfg.dashboard.passwordFile != null);
        message = "services.refl.profile.dashboard: set password or passwordFile, not both"; }
    ];
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = { isSystemUser = true; group = cfg.group; };
    systemd.services.${cfg.serviceName} = {
      description = "Refl proof game";
      wantedBy = [ "multi-user.target" ];
      # The unit may bind one specific public address (backend.address), which
      # must exist before the first start.
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = cfg.stateDirectory;
        StateDirectoryMode = "0700";
        RuntimeDirectory = cfg.runtimeDirectory;
        RuntimeDirectoryMode = "0700";
        WorkingDirectory = "/run/${cfg.runtimeDirectory}";
        ExecStart = lib.escapeShellArgs ([
          "${package}/bin/refl-site"
          "--host" cfg.backend.address "--port" (toString cfg.backend.port)
          "--origin" origin
          "--data-dir" "/var/lib/${cfg.stateDirectory}"
          "--work-dir" "/tmp/${cfg.runtimeDirectory}"
          "--max-sessions" (toString cfg.limits.sessions)
          "--message-bytes" (toString cfg.limits.messageBytes)
          "--command-seconds" (toString cfg.limits.commandSeconds)
          "--idle-seconds" (toString cfg.limits.idleSeconds)
        ]
        ++ lib.concatMap (r: [ "--trusted-proxy" r ]) cfg.backend.trustedProxyRanges
        ++ lib.optionals cfg.analytics.enable
          ([ "--analytics" "--analytics-days" (toString cfg.analytics.retentionDays) ]
           ++ lib.optionals (cfg.analytics.geoipDatabase != null) [ "--geoip" cfg.analytics.geoipDatabase ])
        # The password is read from the credentials directory, never from the
        # command line: ExecStart is world-readable in the unit file.
        ++ lib.optionals (passwordFile != null) [ "--dashboard-password-file" credential ]);
        LoadCredential = lib.optional (passwordFile != null) "dashboard-password:${passwordFile}";
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
        # real_ip is a server-context directive and the location below
        # defines none of its own, so it is inherited cleanly.
        extraConfig = lib.optionalString (cfg.ingress.trustedProxyRanges != [ ]) (
          lib.concatMapStrings (r: "set_real_ip_from ${r};\n") cfg.ingress.trustedProxyRanges
          + "real_ip_header CF-Connecting-IP;\n");
        locations."/" = {
          proxyPass = "http://${address}:${toString cfg.backend.port}";
          proxyWebsockets = true;
          # Must be set *in this location*. nginx inherits proxy_set_header
          # as a whole array: the moment a location defines one of its own
          # -- which proxyWebsockets does, for Upgrade and Connection --
          # every header inherited from the server level is dropped. Asking
          # for the recommended set here puts X-Real-IP in the same array,
          # so it survives and the websocket upgrade keeps working.
          recommendedProxySettings = true;
        };
      };
    };
    networking.firewall.allowedTCPPorts =
      lib.optionals cfg.ingress.enable [ cfg.ingress.httpPort cfg.ingress.httpsPort ]
      ++ lib.optional cfg.backend.openFirewall cfg.backend.port;
  };
}
