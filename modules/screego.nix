{ config, ... }:
{
  services.screego = {
    enable = true;
    openFirewall = true;
    settings = {
      SCREEGO_EXTERNAL_IP = "dns:outerwilds.space";
      SCREEGO_TRUST_PROXY_HEADERS = "true";
      SCREEGO_AUTH_MODE = "all";
      SCREEGO_TURN_PORT_RANGE = "52000:55000";
      SCREEGO_USERS_FILE = config.sops.templates."screego.users".path;
    };
  };

  sops.secrets.screego_password_hash = { };
  sops.templates."screego.users" = {
    mode = "0444";
    content = ''
      screen:${config.sops.placeholder.screego_password_hash}
    '';
  };
}
