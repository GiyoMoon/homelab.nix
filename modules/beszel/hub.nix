{ pkgs, ... }:
{
  services.beszel.hub = {
    enable = true;
    package = pkgs.beszel;
    port = 8090;
    host = "0.0.0.0";
    environment = {
      APP_URL = "https://beszel.outerwilds.space";
    };
  };
}
