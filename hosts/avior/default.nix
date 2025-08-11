{
  config,
  pkgs,
  secretsDir,
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

  services.nginx.virtualHosts."firefly.rso.pt" = {
    enableACME = true;
    # redirect to HTTPS automatically
    forceSSL = true;
  };

  services.firefly-iii = {
    enable = true;
    virtualHost = "firefly.rso.pt";
    enableNginx = true;
    settings = {
      APP_URL = "https://firefly.rso.pt";
      APP_ENV = "production";
      APP_KEY_FILE = config.age.secrets.firefly3AppKey.path;
      SITE_OWNER = "firefly@rso.pt";

      DB_CONNECTION = "pgsql";
      DB_HOST = "localhost";
      DB_DATABASE = "firefly-iii";
      DB_USERNAME = "firefly-iii";
      DB_PASSWORD_FILE = config.age.secrets.firefly3DbPassword.path;

      MAIL_MAILER = "smtp";
      MAIL_HOST = "mail.rso.pt";
      MAIL_PORT = "587";
      MAIL_FROM = "firefly@rso.pt";
      MAIL_USERNAME = "firefly@rso.pt";
      MAIL_PASSWORD_FILE = config.age.secrets.firefly3MailPassword.path;
      MAIL_ENCRYPTION = "tls";

      ENABLE_EXCHANGE_RATES = "true";
      ENABLE_EXTERNAL_RATES = "true";

      TRUSTED_PROXIES = "**";
      COOKIE_SECURE = "true";
      COOKIE_SAMESITE = "strict";
      TZ = "Europe/Lisbon";
    };
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

  age.secrets = {
    firefly3AppKey = {
      file = secretsDir + "/firefly3-app-key.age";
      owner = config.services.firefly-iii.user;
    };
    firefly3DbPassword = {
      file = secretsDir + "/firefly3-db-password.age";
      owner = config.services.firefly-iii.user;
    };
    firefly3MailPassword = {
      file = secretsDir + "/firefly3-mail-password.age";
      owner = config.services.firefly-iii.user;
    };
  };

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
