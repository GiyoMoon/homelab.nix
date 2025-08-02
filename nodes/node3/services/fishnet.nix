{ pkgs, config, ... }:
{
  users = {
    users.fishnet = {
      isSystemUser = true;
      home = "/home/fishnet";
      createHome = true;
      group = "fishnet";
    };
    groups.fishnet = { };
  };

  systemd.services.fishnet = {
    description = "fishnet client";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      User = "fishnet";
      ExecStart = "${pkgs.fishnet}/bin/fishnet --conf /etc/fishnet/fishnet.ini --key-file ${config.sops.secrets.fishnet_key.path}";
      KillMode = "mixed";
      WorkingDirectory = "/tmp";
      PrivateTmp = true;
      DevicePolicy = "closed";
      ProtectSystem = false;
      Restart = "on-failure";
      StandardOutput = "append:/home/fishnet/fishnet.log";
      StandardError = "inherit";
    };
  };

  environment.etc."fishnet/fishnet.ini".text = ''
    [fishnet]
    cores=7
    userbacklog=0
    systembacklog=0
  '';
}
