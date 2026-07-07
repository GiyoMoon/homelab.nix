{ config, ... }:
{
  virtualisation.oci-containers.containers = {
    fusion = {
      image = "ghcr.io/0x2e/fusion:1.1.1";
      ports = [ "8097:8080" ];
      environmentFiles = [ config.sops.templates."fusion.env".path ];
      environment = {
        TZ = config.time.timeZone;
        FUSION_OIDC_ISSUER = "https://id.outerwilds.space/oauth2/openid/fusion";
        FUSION_OIDC_CLIENT_ID = "fusion";
        FUSION_OIDC_REDIRECT_URI = "https://rss.outerwilds.space/api/oidc/callback";
        FUSION_TRUSTED_PROXIES = "10.0.0.0/16,2a02:168:a1ea::/64";
      };
      volumes = [
        "/var/lib/fusion:/data"
      ];
    };
  };

  sops.templates."fusion.env".content = ''
    FUSION_OIDC_CLIENT_SECRET=${config.sops.placeholder.kanidm_fusion_secret}
    FUSION_PASSWORD=${config.sops.placeholder.fusion_password}
  '';
  sops.secrets.fusion_password = { };

  systemd.tmpfiles.rules = [
    "d /var/lib/fusion 0750 root root -"
  ];
}
