{ pkgs, config, ... }:
{
  services.hedgedoc = {
    enable = true;
    settings = {
      domain = "log.outerwilds.space";
      port = 8091;
      protocolUseSSL = true;
      allowEmailRegister = false;
      allowAnonymous = false;
      allowAnonymousEdits = true;
    };
  };

  services.restic.backups.hedgedoc = {
    environmentFile = config.sops.templates.restic_env.path;

    paths = [
      "/var/lib/hedgedoc"
    ];

    extraBackupArgs = [
      "--tag hedgedoc"
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
    timers.hedgedoc-backup = {
      description = "Daily hedgedoc backup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
    };
    services.hedgedoc-backup = {
      description = "Trigger hedgedoc database backup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.sqlite}/bin/sqlite3 /var/lib/hedgedoc/db.sqlite \".backup /var/lib/hedgedoc/db.sqlite.backup\"";
      };
    };
  };
}
