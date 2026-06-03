{
  config,
  pkgs,
  hosts,
  ...
}:
let
  # add `http: !include http.yaml` to configuration.yaml
  httpConfig = (pkgs.formats.yaml { }).generate "http.yaml" {
    use_x_forwarded_for = true;
    trusted_proxies = [
      hosts.node1.ipv4
      hosts.node1.ipv6
      "127.0.0.1"
      "::1"
      "2a02:168:a1ea::/64"
    ];
  };
in
{
  virtualisation.oci-containers.containers.home-assistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    volumes = [
      "/var/lib/homeassistant:/config"
      "${httpConfig}:/config/http.yaml:ro"
    ];
    extraOptions = [
      "--network=host"
    ];
    environment = {
      TZ = config.time.timeZone;
    };
  };

  virtualisation.oci-containers.containers.matter-server = {
    image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
    volumes = [
      "/var/lib/matter-server:/data"
    ];
    cmd = [
      "--storage-path"
      "/data"
      "--paa-root-cert-dir"
      "/data/credentials"
      "--primary-interface"
      "end0"
      "--log-level"
      "debug"
    ];
    extraOptions = [
      "--network=host"
    ];
    environment = {
      TZ = config.time.timeZone;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/homeassistant 0750 root root -"
    "d /var/lib/matter-server 0750 root root -"
  ];

  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant UI
    5580 # Matter Server WebSocket
  ];
}
