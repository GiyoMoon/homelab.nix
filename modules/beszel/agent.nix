{
  pkgs,
  config,
  inputs,
  meta,
  ...
}:
{
  disabledModules = [ "services/monitoring/beszel-agent.nix" ];
  imports = [ "${inputs.nixpkgs-beszel-pr}/nixos/modules/services/monitoring/beszel-agent.nix" ];

  services.beszel.agent = {
    enable = true;
    openFirewall = true;
    package = pkgs.beszel;
    environmentFile = config.sops.templates."beszel-agent.env".path;
  };

  sops.secrets."beszel_token_${meta.hostname}" = { };
  sops.templates."beszel-agent.env" = {
    content = ''
      KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGktxJ5TCoRUA/POj9+Iz6C4KvUlNk0WTc6J2Vro+5n"
      TOKEN="${config.sops.placeholder."beszel_token_${meta.hostname}"}"
      HUB_URL="10.0.10.1"
      SKIP_GPU=true
    '';
  };
}
