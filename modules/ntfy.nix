{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.outerwilds.space";
      listen-http = ":6180";
      behind-proxy = true;
    };
  };
}
