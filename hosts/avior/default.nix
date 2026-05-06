{
  profiles,
  ...
}:

{
  imports = with profiles; [
    kind.server
    firmware.bios
    services.mailserver
    services.postgresql
    services.nginx
    ./disk.nix
    ./hardware.nix
  ];

  rso.mailserver.primaryDomain = "rso.pt"; # override from hostname (default)

  rso.firefly-iii = {
    enable = true;
    domain = "firefly.rso.pt";
  };

  rso.grocy = {
    enable = true;
    domain = "grocy.rso.pt";
  };

  rso.nginx-static = {
    "rso.pt" = {
      rootDirectoryName = "basic";
    };

    "just1.rso.pt" = {
      rootDirectoryName = "just1";
      basicAuthHashes = {
        just1 = "$2y$05$aBpas4uRVVD/SgWQ6VljWuiqLNt5aD.N9Uvpx8JmIYEmwLAsA9TLC";
      };
    };

    "toki.rso.pt" = {
      rootDirectoryName = "toki";
    };
  };

  system.stateVersion = "25.05";
}
