{
  profiles,
  ...
}:

{
  imports = with profiles; [
    kind.server
    firmware.bios
    services.nginx
    ./disk.nix
    ./hardware.nix
  ];

  services.postgresql = {
    enable = true;
    enableJIT = true;
  };

  rso.firefly-iii = {
    enable = true;
    domain = "firefly.rso.pt";
  };

  system.stateVersion = "25.05";
}
