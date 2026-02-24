{
  host,
  lib,
  meta,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./beszel/agent.nix
  ];
  nix.settings = {
    auto-optimise-store = true;
    builders-use-substitutes = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  documentation = {
    man.enable = lib.mkDefault false;
    nixos.enable = lib.mkDefault false;
  };

  environment.systemPackages = with pkgs; [
    vim
    btop
  ];

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      X11Forwarding = lib.mkDefault true;
      PermitRootLogin = lib.mkDefault "yes";
    };
    openFirewall = lib.mkDefault true;
  };

  networking = {
    hostName = meta.hostname;
    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "end0";
      address = [
        "${host.ipv4}/16"
        "${host.ipv6}/64"
      ];
      gateway = [ "10.0.0.1" ];
      networkConfig = {
        IPv6AcceptRA = true;
      };
      ipv6AcceptRAConfig = {
        UseDNS = true;
      };
    };
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKokeEDCkwISIkctnn5TkjMbJa+h/rq2Ek/0dN9LIHjF macbook"
    ];
  };

  system.stateVersion = "25.05";

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "letsencrypt@jasi.dev";
      server = "https://acme-v02.api.letsencrypt.org/directory";
      dnsProvider = "cloudflare";
      credentialFiles = {
        CF_API_EMAIL_FILE = config.sops.secrets.cloudflare_email.path;
        CF_DNS_API_TOKEN_FILE = config.sops.secrets.cloudflare_acme_token.path;
      };
    };
  };
  sops.secrets = {
    cloudflare_email = { };
    cloudflare_acme_token = { };
  };

  sops = {
    defaultSopsFile = ../secrets/secrets.json;
    defaultSopsFormat = "json";
  };
}
