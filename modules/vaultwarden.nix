{ config, ... }:
{
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    domain = "vault.outerwilds.space";
    backupDir = "/var/backup/vaultwarden";
    environmentFile = config.sops.templates."vaultwarden.env".path;
    config = {
      ROCKET_ADDRESS = "::";
      ROCKET_PORT = 8096;
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = false;

      SSO_ENABLED = true;
      SSO_ONLY = true;
      SSO_SIGNUPS_MATCH_EMAIL = true;
      SSO_AUTHORITY = "https://id.outerwilds.space/oauth2/openid/vaultwarden";
      SSO_SCOPES = "email profile";
      SSO_PKCE = true;
      SSO_CLIENT_ID = "vaultwarden";
    };
  };

  sops.templates."vaultwarden.env" = {
    content = ''
      ADMIN_TOKEN=${config.sops.placeholder.vaultwarden_admin_token}
      SSO_CLIENT_SECRET=${config.sops.placeholder.kanidm_vaultwarden_secret}
    '';
    owner = "vaultwarden";
    group = "vaultwarden";
  };
  sops.secrets.vaultwarden_admin_token = { };

  services.restic.backups.vaultwarden = {
    environmentFile = config.sops.templates.restic_env.path;

    paths = [
      "/var/backup/vaultwarden"
    ];

    extraBackupArgs = [
      "--tag vaultwarden"
    ];

    timerConfig = {
      OnCalendar = "*-*-* 04:12:00";
      Persistent = true;
    };

    initialize = true;

    pruneOpts = [
      "--keep-last 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
    ];
  };

}
