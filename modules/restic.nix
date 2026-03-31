{ config, ... }:
{
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
}
