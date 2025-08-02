{
  sops.defaultSopsFile = ./secrets.json;
  sops.defaultSopsFormat = "json";

  sops.secrets.fishnet_key = {
    owner = "fishnet";
    mode = "0400";
  };
}
