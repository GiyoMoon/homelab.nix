{ config, ... }:
{
  users.users.malocher_timer = {
    isSystemUser = true;
    group = "malocher_timer";
  };
  users.groups.malocher_timer = { };

  sops.secrets.malocher_timer_hashed_login_password = {
    owner = "malocher_timer";
    mode = "0400";
  };

  systemd.services.malocher_timer = {
    description = "malocher timer service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "/var/lib/malocher_timer/malocher_timer";
      User = "malocher_timer";
      Group = "malocher_timer";
      StateDirectory = "malocher_timer";
      Restart = "on-failure";
      Environment = [
        "BIND_ADDRESS=0.0.0.0:8092"
        "CLIENT_ORIGIN=https://maloche.outerwilds.space"
        "DATABASE_URL=/var/lib/malocher_timer/maloche.db"
      ];
      EnvironmentFile = config.sops.secrets.malocher_timer_hashed_login_password.path;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8092 ];
}
