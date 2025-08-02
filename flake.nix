{
  description = "NixOS configuration for my homelab nodes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      ...
    }@inputs:
    let
      mkNixosConfig =
        hostname: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            meta = { inherit hostname; };
          };
          modules = [
            inputs.turing-rk1.nixosModules.turing-rk1
            inputs.sops-nix.nixosModules.sops
            ./nodes/${hostname}
          ];
        };

      mkDeployNode =
        hostname: nixosSystem:
        let
          system = nixosSystem.pkgs.stdenv.hostPlatform.system;
        in
        {
          inherit hostname;
          # Enable on first run
          # sshUser = "nixos";
          sshUser = "root";
          user = "root";
          autoRollback = false;
          magicRollback = false;
          remoteBuild = true;

          profiles.system.path = deploy-rs.lib.${system}.activate.nixos nixosSystem;
        };
    in
    {
      nixosConfigurations = {
        node1 = mkNixosConfig "node1" "aarch64-linux";
        node3 = mkNixosConfig "node3" "aarch64-linux";
      };

      deploy.nodes = {
        node1 = mkDeployNode "node1.lan" self.nixosConfigurations.node1;
        node3 = mkDeployNode "node3.lan" self.nixosConfigurations.node3;
      };
    };
}
