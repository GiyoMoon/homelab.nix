{
  pkgs,
  inputs,
  config,
  ...
}:
{
  users.users.chaos_spaces = {
    isSystemUser = true;
    group = "chaos_spaces";
  };
  users.groups.chaos_spaces = { };

  systemd.services.chaos_spaces = {
    description = "chaos_spaces service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${inputs.chaos_spaces.packages.${pkgs.system}.server}/bin/chaos_spaces";
      User = "chaos_spaces";
      Group = "chaos_spaces";
      StateDirectory = "chaos_spaces";
      Restart = "on-failure";
      Environment = [
        "BIND_ADDRESS=0.0.0.0:8095"
        "DATABASE_URL=/var/lib/chaos_spaces/chaos_spaces.db"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8095 ];

  services.restic.backups.chaos_spaces = {
    environmentFile = config.sops.templates.restic_env.path;

    paths = [
      "/var/lib/chaos_spaces"
    ];

    extraBackupArgs = [
      "--tag chaos_spaces"
    ];

    timerConfig = {
      OnCalendar = "*-*-* 04:10:00";
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
    timers.chaos_spaces-backup = {
      description = "Daily chaos_spaces backup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
    };
    services.chaos_spaces-backup = {
      description = "Trigger chaos_spaces database backup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.sqlite}/bin/sqlite3 /var/lib/chaos_spaces/chaos_spaces.db \".backup /var/lib/chaos_spaces/chaos_spaces.db.backup\"";
      };
    };
  };
}
