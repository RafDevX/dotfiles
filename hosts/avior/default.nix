{
  profiles,
  ...
}:

{
  imports = with profiles; [
    kind.server
    firmware.bios
    services.postgresql
    services.nginx
    ./disk.nix
    ./hardware.nix
  ];

  rso.firefly-iii = {
    enable = true;
    domain = "firefly.rso.pt";
  };

  rso.nginx-static."just1.rso.pt" = {
    rootDirectoryName = "just1";
    basicAuthHashes = {
      just1 = "$2y$05$aBpas4uRVVD/SgWQ6VljWuiqLNt5aD.N9Uvpx8JmIYEmwLAsA9TLC";
    };
  };

  system.stateVersion = "25.05";
}
