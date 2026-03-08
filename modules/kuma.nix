{
  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = "6170";
    };
  };

  networking.firewall.allowedTCPPorts = [ 6170 ];
}
