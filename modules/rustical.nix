{ config, pkgs, ... }:
{
  users = {
    users.rustical = {
      isSystemUser = true;
      group = "rustical";
      home = "/var/lib/rustical";
    };
    groups.rustical = { };
  };

  systemd.services.rustical = {
    description = "Rustical CalDAV/CardDAV Server";
    after = [
      "network.target"
      "kanidm.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "rustical";
      Group = "rustical";
      ExecStart = "${pkgs.rustical}/bin/rustical --config-file ${
        config.sops.templates."rustical.toml".path
      }";
      Restart = "on-failure";
      RestartSec = 5;
      StateDirectory = "rustical";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ReadWritePaths = [ "/var/lib/rustical" ];
    };
  };

  sops.templates."rustical.toml".content = ''
    [http]
    host = "127.0.0.1"
    port = 8094

    [data_store.sqlite]
    db_url = "sqlite:///var/lib/rustical/db.sqlite"

    [oidc]
    name = "kanidm"
    issuer = "https://id.outerwilds.space/oauth2/openid/rustical"
    client_id = "rustical"
    client_secret = "${config.sops.placeholder.kanidm_rustical_secret}"
    claim_userid = "preferred_username"
    scopes = ["openid", "email", "profile"]
    allow_sign_up = true
  '';
  sops.templates."rustical.toml".owner = "rustical";

  systemd.tmpfiles.rules = [
    "d /var/lib/rustical 0750 rustical rustical -"
  ];

  services.restic.backups.rustical = {
    environmentFile = config.sops.templates.restic_env.path;

    paths = [
      "/var/lib/rustical"
    ];

    extraBackupArgs = [
      "--tag rustical"
    ];

    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      Persistent = true;
    };

    initialize = true;

    pruneOpts = [
      "--keep-last 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
    ];
  };

  systemd = {
    timers.rustical-backup = {
      description = "Daily rustical backup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
    };
    services.rustical-backup = {
      description = "Trigger rustical backup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.sqlite}/bin/sqlite3 /var/lib/rustical/db.sqlite \".backup /var/lib/rustical/db.sqlite.backup\"";
      };
    };
  };
}
