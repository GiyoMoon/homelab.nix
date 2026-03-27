{
  services.screego = {
    enable = true;
    openFirewall = true;
    settings = {
      SCREEGO_EXTERNAL_IP = "dns:outerwilds.space";
      SCREEGO_TRUST_PROXY_HEADERS = "true";
      SCREEGO_AUTH_MODE = "none";
    };
  };
}
