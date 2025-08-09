{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./disk.nix
    ./hardware.nix
  ];

  # use GRUB because host uses legacy BIOS (not UEFI)
  boot.loader = {
    grub.enable = true;
    timeout = 3;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50; # ZRAM swap with half total physical RAM size
  };

  networking.hostName = "avior";

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Lisbon";

  users.mutableUsers = false; # ensure users and groups are set declaratively
  users.users.raf = {
    isNormalUser = true;
    description = "Raf";
    hashedPassword = "$y$j9T$22ptNC3YRhTx7OgmwpMuU0$EQUgjVjGlRkfwYnwFp0x/Dnn1yjW1XH3vocdBnNCPyB";
    createHome = true;
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwaEu0TGRXhxjk1+Pz2LP66Vfvvgr3IvxkRfkcRiP0Y raf@rotterdam"
    ];
  };

  services.openssh.enable = true;

  services.postgresql = {
    enable = true;
    enableJIT = true;
  };

  services.nginx = {
    enable = true;

    # reload (vs. restart) when configuration changes
    enableReload = true;

    # enable compression
    recommendedZstdSettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;

    # other recommended settings
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedUwsgiSettings = true;

    # reject connections to unknown virtual hosts
    virtualHosts."_" = {
      default = true;
      rejectSSL = true;
      locations."/" = {
        return = "444"; # nginx doesn't respond and drops connection
      };
    };
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "lets-encrypt@rso.pt";
  };

  programs.zsh.enable = true;
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    fd
    ripgrep
    git
    curl
    htop
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Don't add @wheel here, since it allows for privilege escalation
      # https://github.com/NixOS/nix/issues/9649#issuecomment-1868001568
      trusted-users = [ "root" ];
      trusted-public-keys = [
        "rotterdam:jRJCBUxAFAddxw2oJpd5QuXx+ikKWqCN3qOxKxI7540="
      ];
    };

    # lock flake registry to keep sync'd with inputs
    # (e.g., used by `nix run pkgs#name`)
    registry = {
      pkgs.flake = inputs.nixpkgs; # alias to nixpkgs
      unstable.flake = inputs.nixpkgs-unstable;
    };

    nixPath = [
      "nixpkgs=flake:pkgs"
      "unstable=flake:unstable"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  system.stateVersion = "25.05";
}
