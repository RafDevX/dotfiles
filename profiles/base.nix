# TODO: move to modules/, since this should always be applied
{
  pkgs,
  inputs,
  ...
}:

{
  zramSwap = {
    enable = true;
    memoryPercent = 50; # ZRAM swap with half total physical RAM size
  };

  # This keeps the system language as US English, but uses European standards
  # for everything else; namely dates, currency, number formatting, paper sizes,
  # and metric units.
  # See: https://unix.stackexchange.com/a/62317
  i18n = {
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings = {
      LANGUAGE = "en_US";
    };
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    fd
    ripgrep
    htop
  ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # lock flake registry to keep sync'd with inputs
    # (e.g., used by `nix run pkgs#name`)
    registry = {
      pkgs.flake = inputs.nixpkgs; # alias pkgs to nixpkgs
      unstable.flake = inputs.nixpkgs-unstable; # alias unstable
    };

    nixPath = [
      "nixpkgs=flake:pkgs"
      "unstable=flake:unstable"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };
}
