{ ... }:
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
          "nope.chat"
          "immer.chat"
          "catgirl.cloud"
          "events.ccc.de"
          "matrix.org"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 6167 ];
}
