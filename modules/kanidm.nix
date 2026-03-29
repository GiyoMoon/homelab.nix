{ pkgs, config, ... }:
{
  services.kanidm = {
    package = pkgs.kanidm_1_9.withSecretProvisioning;
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
}
