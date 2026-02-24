{ pkgs, config, ... }:
{
  services.caddy = {
    enable = true;
    enableReload = true;
    globalConfig = ''
      grace_period 1m
    '';
    virtualHosts = {
      "(outerwilds_space_cert)".extraConfig = ''
        tls ${config.security.acme.certs."outerwilds.space".directory}/fullchain.pem ${
          config.security.acme.certs."outerwilds.space".directory
        }/key.pem
      '';
      "outerwilds.space".extraConfig = ''
        import outerwilds_space_cert

        handle /.well-known/matrix/server {
          header Content-Type application/json
          header Access-Control-Allow-Origin "*"
          respond `{"m.server": "matrix.outerwilds.space:443"}`
        }
        handle /.well-known/matrix/client {
          header Content-Type application/json
          header Access-Control-Allow-Origin "*"
          respond `{"m.homeserver": {"base_url": "https://matrix.outerwilds.space"}}`
        }
        handle /.well-known/matrix/support {
          header Content-Type application/json
          header Access-Control-Allow-Origin "*"
          respond `{"contacts":[{"role":"m.role.admin","matrix_id":"@jasi:outerwilds.space"}]}`
        }

        handle {
          respond "miep :3"
        }
      '';
      "*.outerwilds.space".extraConfig = ''
        import outerwilds_space_cert
        abort
      '';
      "matrix.outerwilds.space".extraConfig = ''
        reverse_proxy 10.0.10.3:6167
      '';
      "beszel.outerwilds.space".extraConfig = ''
        reverse_proxy localhost:${toString config.services.beszel.hub.port}
      '';
      "chat.outerwilds.space".extraConfig = ''
        root * ${pkgs.cinny}

        handle /config.json {
          header Content-Type application/json
          header Access-Control-Allow-Origin "*"
          respond `{"defaultHomeserver": 0, "homeserverList": ["outerwilds.space"], "allowCustomHomeservers": false}`
        }

        try_files {path} /index.html
        file_server
      '';
    };
  };

  security.acme.certs."outerwilds.space" = {
    extraDomainNames = [ "*.outerwilds.space" ];
    group = config.services.caddy.group;
    reloadServices = [ "caddy" ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
