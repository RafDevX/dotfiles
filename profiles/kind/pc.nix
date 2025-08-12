# PC == everything that's not a server; dynamic user-facing environments like
# laptops or workstations, which are always physical machines
{
  pkgs,
  profiles,
  lib,
  ...
}:

{
  imports = with profiles; [
    base
    misc.audio
    networking.dns-over-https
    # technically ssh server is not really required for laptops, but it's
    # simpler to use agenix if there's an ssh host key, and in any case this
    # might come in useful in the future if/when there's a better host-to-host
    # intercom mechanism that works even when IPs change and across firewalls
    services.ssh
    misc.config-editor
  ];

  time.timeZone = lib.mkDefault "Europe/Lisbon";

  networking.networkmanager.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
    options = "compose:rctrl";
  };

  services.printing.enable = true; # enable CUPS

  programs.zsh.enable = true;

  fonts.packages =
    with pkgs;
    [
      fira-code
      font-awesome
      noto-fonts
      noto-fonts-extra
      noto-fonts-emoji
      noto-fonts-cjk-sans
    ]
    # all fonts in the nerd-fonts namespace
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
