{ pkgs, ... }:
{
  imports = [
    ../modules/common.nix
    # ../modules/fishnet.nix
    ../modules/matrix.nix
  ];

  environment.systemPackages = with pkgs; [
    rclone
  ];

  fileSystems = {
    "/mnt/hdd1" = {
      device = "/dev/disk/by-uuid/30873e27-ec2a-4606-a4b1-1a1c19b1ce14";
      fsType = "ext4";
      options = [ "nofail" ];
    };
    "/mnt/hdd2" = {
      device = "/dev/disk/by-uuid/e108df93-f06b-48de-a256-9a12a2bfe9f3";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };
}
