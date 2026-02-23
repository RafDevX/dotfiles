{ ... }:

{
  services.nginx = {
    enable = true;

    # reload (vs. restart) when configuration changes
    enableReload = true;

    # enable compression
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;

    # other recommended settings
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedUwsgiSettings = true;

    # reject connections to unknown virtual hosts
    virtualHosts."_" = {
      default = true;
      rejectSSL = true;
      locations."/" = {
        return = "444"; # nginx doesn't respond and drops connection
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "lets-encrypt@rso.pt";
  };
}
