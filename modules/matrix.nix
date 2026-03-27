{ pkgs, config, ... }:
{
  services.matrix-continuwuity = {
    enable = true;
    settings = {
      global = {
        server_name = "outerwilds.space";
        address = [
          "0.0.0.0"
          "::"
        ];
        port = [ 6167 ];
        allow_registration = false;
        allow_encryption = true;
        allow_federation = true;
        trusted_servers = [
          "unredacted.org"
          "fairydust.space"
          "nope.chat"
          "immer.chat"
          "catgirl.cloud"
          "events.ccc.de"
          "matrix.org"
        ];
        database_backup_path = "/var/lib/private/continuwuity/backups";
        database_backups_to_keep = 1;
        admin_signal_execute = [ "server backup-database" ];
      };
    };
  };

  services.restic.backups.matrix = {
    environmentFile = config.sops.templates.restic_env.path;

    paths = [
      "/var/lib/private/continuwuity"
    ];

    extraBackupArgs = [
      "--tag matrix"
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

  sops.secrets = {
    restic_repository = { };
    restic_password = { };
    restic_host = { };
    restic_aws_access_key_id = { };
    restic_aws_secret_access_key = { };
  };

  sops.templates.restic_env.content = ''
    RESTIC_REPOSITORY=${config.sops.placeholder.restic_repository}
    RESTIC_PASSWORD=${config.sops.placeholder.restic_password}
    RESTIC_HOST=${config.sops.placeholder.restic_host}
    AWS_ACCESS_KEY_ID=${config.sops.placeholder.restic_aws_access_key_id}
    AWS_SECRET_ACCESS_KEY=${config.sops.placeholder.restic_aws_secret_access_key}
  '';

  systemd = {
    timers.continuwuity-backup = {
      description = "Daily continuwuity database backup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
    };
    services.continuwuity-backup = {
      description = "Trigger continuwuity database backup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl kill --signal=SIGUSR2 continuwuity.service";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 6167 ];
}
