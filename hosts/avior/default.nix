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

  system.stateVersion = "25.05";
}
