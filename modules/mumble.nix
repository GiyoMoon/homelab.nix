{ config, ... }:
{
  services.murmur = {
    enable = true;
    openFirewall = true;
    port = 64738;
    environmentFile = config.sops.templates."mumble.env".path;

    registerHostname = "yap.outerwilds.space";
    registerName = "📞 outerwilds.space";
    welcometext = "miep :3";

    password = "$MUMBLE_PASSWORD";
    users = 50;

    tls.certPath = "${config.security.acme.certs."yap.outerwilds.space".directory}/fullchain.pem";
    tls.keyPath = "${config.security.acme.certs."yap.outerwilds.space".directory}/key.pem";
  };

  security.acme.certs."yap.outerwilds.space" = {
    group = config.services.murmur.group;
  };

  sops.secrets.mumble_password = { };
  sops.templates."mumble.env".content = ''
    MUMBLE_PASSWORD=${config.sops.placeholder.mumble_password}
  '';
}
