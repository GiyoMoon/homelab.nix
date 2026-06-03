{ pkgs, config, ... }:
{
  services.kanidm = {
    package = pkgs.kanidm_1_10.withSecretProvisioning;
    server = {
      enable = true;
      settings = {
        origin = "https://id.outerwilds.space";
        domain = "id.outerwilds.space";
        bindaddress = "127.0.0.1:8093";
        tls_chain = "${config.security.acme.certs."id.outerwilds.space".directory}/fullchain.pem";
        tls_key = "${config.security.acme.certs."id.outerwilds.space".directory}/key.pem";
      };
    };
    client = {
      enable = true;
      settings = {
        uri = "https://id.outerwilds.space";
      };
    };

    provision = {
      enable = true;
      instanceUrl = "https://id.outerwilds.space";
      adminPasswordFile = config.sops.secrets.kanidm_admin_password.path;
      idmAdminPasswordFile = config.sops.secrets.kanidm_idm_admin_password.path;

      persons = {
        jasi = {
          present = true;
          displayName = "jasi";
          mailAddresses = [ "outerwilds@jasi.dev" ];
        };
      };

      groups = {
        users = {
          present = true;
          members = [ "jasi" ];
        };
      };

      systems.oauth2 = {
        rustical = {
          present = true;
          displayName = "rustical outerwilds.space";
          originUrl = "https://cal.outerwilds.space/";
          originLanding = "https://cal.outerwilds.space/frontend/login/oidc/callback";
          public = false;
          preferShortUsername = true;
          basicSecretFile = config.sops.secrets.kanidm_rustical_secret.path;

          scopeMaps = {
            users = [
              "openid"
              "email"
              "profile"
            ];
          };
        };
      };
    };
  };

  security.acme.certs."id.outerwilds.space" = {
    group = "kanidm";
  };

  sops.secrets = {
    kanidm_admin_password = {
      owner = "kanidm";
      group = "kanidm";
    };
    kanidm_idm_admin_password = {
      owner = "kanidm";
      group = "kanidm";
    };
    kanidm_rustical_secret = {
      mode = "0444";
      owner = "kanidm";
      group = "kanidm";
    };
  };

  services.restic.backups.kanidm = {
    environmentFile = config.sops.templates.restic_env.path;

    paths = [
      "/var/lib/kanidm"
    ];

    extraBackupArgs = [
      "--tag kanidm"
    ];

    timerConfig = {
      OnCalendar = "*-*-* 04:02:00";
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
    timers.kanidm-backup = {
      description = "Daily kanidm backup";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
    };
    services.kanidm-backup = {
      description = "Trigger kanidm database backup";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.sqlite}/bin/sqlite3 /var/lib/kanidm/kanidm.db \".backup /var/lib/kanidm/kanidm.db.backup\"";
      };
    };
  };
}
