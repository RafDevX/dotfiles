{ profiles, ... }:

{
  imports = with profiles; [
    firmware.base
  ];

  boot.loader = {
    grub.enable = true;
    timeout = 3;
  };
}
