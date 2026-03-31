{ config, pkgs, ... }:
{
  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = "6170";
    };
  };

  services.restic.backups.kuma = {
    environmentFile = config.sops.templates.restic_env.path;

    paths = [
      "/var/lib/private/uptime-kuma"
    ];

    extraBackupArgs = [
      "--tag kuma"
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
    timers.kuma-backup = {
      description = "Daily kuma backup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
    };
    services.kuma-backup = {
      description = "Trigger kuma backup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.sqlite}/bin/sqlite3 /var/lib/private/uptime-kuma/kuma.db \".backup /var/lib/private/uptime-kuma/kuma.db.backup\"";
      };
    };
  };
}
