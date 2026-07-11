{ inputs, ... }:

{
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
      unstable-small.flake = inputs.nixpkgs-unstable-small; # fewer but newer
    };

    nixPath = [
      "nixpkgs=flake:pkgs"
      "unstable=flake:unstable"
      "unstable-small=flake:unstable-small"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };
}
