{
  description = "NixOS configuration for my homelab nodes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    turing-rk1 = {
      url = "github:GiyoMoon/nixos-turing-rk1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # PR: nixos/beszel-agent: Enable systemd monitoring
    # https://github.com/NixOS/nixpkgs/pull/461327
    nixpkgs-beszel-pr = {
      url = "github:NixOS/nixpkgs/refs/pull/461327/merge";
      flake = false;
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      turing-rk1,
      sops-nix,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      hosts = {
        node1 = {
          ipv4 = "10.0.10.1";
          ipv6 = "2a02:168:a1ea::11";
        };
        node3 = {
          ipv4 = "10.0.10.3";
          ipv6 = "2a02:168:a1ea::13";
        };
      };

      mkNixosSystem =
        name: host:
        nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs host;
            meta = {
              hostname = name;
            };
          };
          modules = [
            turing-rk1.nixosModules.turing-rk1
            sops-nix.nixosModules.sops
            ./nodes/${name}.nix
          ];
        };

      mkDeploy = name: host: {
        # Enable on first run
        # sshUser = "nixos";
        hostname = name;
        profiles.system.path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.${name};
      };
    in
    {
      nixosConfigurations = lib.mapAttrs mkNixosSystem hosts;
      deploy = {
        nodes = lib.mapAttrs mkDeploy hosts;
        sshUser = "root";
        user = "root";
        autoRollback = false;
        magicRollback = false;
        remoteBuild = true;
      };
    };
}
