{ config, ... }:
{
  services.ddns-updater = {
    enable = true;
    environment = {
      SERVER_ENABLED = "no";
      CONFIG_FILEPATH = config.sops.templates."ddns_config.json".path;
      PERIOD = "5m";
    };
  };

  users = {
    users."ddns-updater" = {
      isNormalUser = true;
      createHome = false;
      group = "ddns-updater";
    };
    groups."ddns-updater" = { };
  };

  sops = {
    secrets = {
      cloudflare_ddns_token = { };
      cloudflare_zone_id_outerwilds_space = { };
    };
    templates."ddns_config.json" = {
      owner = "ddns-updater";
      content = builtins.toJSON {
        "settings" = [
          {
            "domain" = "outerwilds.space";
            "provider" = "cloudflare";
            "zone_identifier" = config.sops.placeholder.cloudflare_zone_id_outerwilds_space;
            # 1 = auto
            "ttl" = 1;
            "ip_version" = "ipv4";
            "token" = config.sops.placeholder.cloudflare_ddns_token;
          }
          {
            "domain" = "*.outerwilds.space";
            "provider" = "cloudflare";
            "zone_identifier" = config.sops.placeholder.cloudflare_zone_id_outerwilds_space;
            # 1 = auto
            "ttl" = 1;
            "ip_version" = "ipv4";
            "token" = config.sops.placeholder.cloudflare_ddns_token;
          }
        ];
      };
    };
  };
}
