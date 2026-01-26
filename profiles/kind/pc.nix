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
    misc.audio
    networking.dns-over-https
    # technically ssh server is not really required for laptops, but it's
    # simpler to use agenix if there's an ssh host key, and in any case this
    # might come in useful in the future if/when there's a better host-to-host
    # intercom mechanism that works even when IPs change and across firewalls
    services.ssh-server
    graphical.captive-portals
    graphical.flameshot
    programs.ssh-client
    misc.config-editor
  ];

  rso.me.shell = pkgs.zsh;
  programs.zsh.enable = true;

  rso.home.enable = true;

  time.timeZone = lib.mkDefault "Europe/Lisbon";

  networking.networkmanager.enable = true;
  rso.me.extraGroups = [ "networkmanager" ]; # allow user to manage network

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
    options = "compose:rctrl";
  };

  services.printing.enable = true; # enable CUPS

  fonts.packages =
    with pkgs;
    [
      fira-code
      font-awesome
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
    ]
    # all fonts in the nerd-fonts namespace
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
