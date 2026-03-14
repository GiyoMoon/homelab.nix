{
  services.hedgedoc = {
    enable = true;
    settings = {
      domain = "log.outerwilds.space";
      port = 8091;
      protocolUseSSL = true;
      allowEmailRegister = false;
      allowAnonymous = false;
      allowAnonymousEdits = true;
    };
  };
}
