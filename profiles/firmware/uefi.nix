{ profiles, ... }:

{
  imports = with profiles; [
    firmware.base
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.fwupd.enable = true; # UEFI firmware update utility
}
