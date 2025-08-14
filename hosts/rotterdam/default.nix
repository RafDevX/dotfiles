{
  pkgs,
  pkgs-unstable,
  profiles,
  ...
}:

{
  imports = with profiles; [
    kind.laptop
    firmware.uefi
    graphical.gnome
    ./hardware.nix
  ];

  rso.networking.wirelessInterface = "wlp3s0";

  services.fprintd.enable = true; # enable fingerprint

  virtualisation.docker.enable = true;

  programs.steam.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # not CLI version
  };
  rso.me.extraGroups = [ "wireshark" ]; # allow listening on all interfaces

  rso.home = {
    programs = {
      java.enable = true;
      firefox.enable = true;
    };

    packages = with pkgs; [
      brave
      discord
      jetbrains.idea-ultimate # intelliJ :(
      mattermost-desktop
      slack
      spotify
      zotero
      obsidian

      gnupg
      httpie
      pinentry-gnome3 # for gpg, TODO: remove
      lf
      libqalculate
      timewarrior
      pkgs-unstable.typst
      pkgs-unstable.tinymist # typst lsp
      pkgs-unstable.typstyle
      nil # nix LSP
      zathura

      binutils # e.g., strings
      file
      unzip
      dogdns
      whois
    ];
  };

  system.stateVersion = "24.05";
}
