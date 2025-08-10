{
  config,
  pkgs,
  pkgs-unstable,
  nixvim,
  secretsDir,
  lib,
  inputs,
  ...
}:

{
  imports = [ ./hardware.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true; # firmware update utility

  zramSwap = {
    enable = true;
    memoryPercent = 50; # ZRAM swap with half total physical RAM size
  };

  networking.hostName = "rotterdam";
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = null;
  services.automatic-timezoned.enable = true;
  services.geoclue2.enableDemoAgent = lib.mkForce true; # because Gnome...
  services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";
  # ^ necessary because Mozilla Location Service has been shut down

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
    options = "compose:rctrl";
  };

  services.printing.enable = true; # enable CUPS

  services.fprintd.enable = true; # enable fingerprint

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.mutableUsers = false; # ensure users and groups are set declaratively
  users.users.raf = {
    isNormalUser = true;
    description = "Raf";
    hashedPassword = "$y$j9T$AgJhH28Mik/VmKWy979af0$3Z9vLnJR.D/fp/g2ym.ZbxaAqDZay4fORkkBcGGlTi9";
    createHome = true;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "wireshark"
    ];
  };

  # more for agenix to have a host key than anything else at this point, but
  # it might come in useful in the future if there's ever better host inter-comm
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # not CLI version
  };
  programs.steam.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.raf = {
    home.stateVersion = "24.05";
    home.username = "raf";
    home.homeDirectory = "/home/raf";

    imports = [ inputs.nixvim.homeManagerModules.nixvim ];

    home.packages = with pkgs; [
      brave
      discord
      flameshot
      jetbrains.idea-ultimate # intelliJ :(
      mattermost-desktop
      slack
      spotify
      zotero
      obsidian

      git
      gnupg
      httpie
      pinentry-gnome3 # for gpg, TODO: remove
      lf
      libqalculate
      timewarrior
      pkgs-unstable.typst
      pkgs-unstable.tinymist # typst lsp
      pkgs-unstable.typstyle
      zathura

      binutils # e.g., strings
      file
      unzip
      dogdns
      whois
    ];

    programs.java.enable = true;

    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      clipboard.providers.xsel.enable = true;
      colorschemes.onedark.enable = true;

      opts = {
        number = true;
        relativenumber = true;
        colorcolumn = [ 80 ];
      };

      keymaps = [
        # move lines up and down
        {
          mode = "v"; # visual
          key = "J";
          action = ":m '>+1<CR>gv=gv";
        }
        {
          mode = "v"; # visual
          key = "K";
          action = ":m '<-2<CR>gv=gv";
        }
      ];

      plugins = {
        lualine.enable = true; # status bar
        rainbow-delimiters.enable = true;
        lastplace.enable = true;

        nvim-autopairs = {
          enable = true;
          settings.check_ts = true; # treesitter
        };

        treesitter = {
          enable = true;
          settings = {
            indent.enable = true;
          };
        };
      };
    };
    home.sessionVariables.EDITOR = "nvim";

    programs.zsh = {
      enable = true;
      shellAliases = {
        cat = "bat";
        fd = "fd -u"; # unrestricted search (include hidden and ignored files)
        mv = "mv -i"; # prompt before overwrite
        cp = "cp -i"; # prompt before overwrite
        rm = "rm -I"; # prompt before removing >3 files or recursively
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "colored-man-pages"
          "command-not-found"
          "docker-compose"
          "extract"
          "git"
          "safe-paste"
        ];
      };
      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.7.0";
            hash = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
          };
        }
        {
          name = "zsh-completions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-completions";
            rev = "0.35.0";
            hash = "sha256-qSobM4PRXjfsvoXY6ENqJGI9NEAaFFzlij6MPeTfT0o=";
          };
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "0.8.0";
            hash = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
          };
        }
      ];
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        custom.timew = {
          description = "Timewarrior time-tracking status";
          when = ''[ "$(timew get dom.active)" = "1" ]'';
          command = "timew | head -n1 | cut -d' ' -f2-";
          style = "bold 111";
          symbol = "⏳";
          format = "tracking [$symbol ($output )]($style)";
        };
      };
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    home.sessionVariables._ZO_ECHO = "1"; # echo matched dir before navigating

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
    };

    programs.bat.enable = true;
    programs.htop.enable = true;

    programs.git = {
      enable = true;
      userName = "Rafael Oliveira";
      userEmail = "rafdev.x@gmail.com";
      signing = {
        key = "2997CA7C4C3135D1";
        signByDefault = true;
      };
      extraConfig = {
        core.whitespace = "tab-in-indent,tabwidth=4";
        init.defaultBranch = "master";
        commit.verbose = true;
        pull.rebase = true;
        rerere.enabled = true;
        url."git@github.com:".pushinsteadOf = "https://github.com/";
      };
      includes = [
        {
          condition = "gitdir:~/Documents/KTH/";
          contents.user = {
            email = "rmfseo@kth.se";
          };
        }
      ];
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "*.rso.pt rso.pt" = {
          hostname = "ssh.%h";
        };
        "*.datasektionen.se" = {
          user = "rmfseo";
        };
      };
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions =
          with pkgs.vscode-extensions;
          [
            eamodio.gitlens
            streetsidesoftware.code-spell-checker
            tomoki1207.pdf # pdf preview
            mkhl.direnv

            jnoortheen.nix-ide
            rust-lang.rust-analyzer
            tamasfe.even-better-toml
            hashicorp.terraform
            hashicorp.hcl
            redhat.java
            golang.go
            vue.volar
            esbenp.prettier-vscode
            samuelcolvin.jinjahtml
            mkhl.direnv
          ]
          ++ (with pkgs-unstable.vscode-extensions; [
            myriad-dreamin.tinymist # typst
          ])
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "code-spell-checker-swedish";
              publisher = "streetsidesoftware";
              version = "1.3.1";
              hash = "sha256-o5N8BMYtjCm4EWOqjNmH9VaHrcHB6swFqPqiyumCJKU=";
            }
          ];
        userSettings = {
          "files.autoSave" = "onFocusChange";
          "files.insertFinalNewline" = true;
          "files.trimFinalNewlines" = true;
          "editor.formatOnSave" = true;
          "editor.rulers" = [ 80 ];
          "cSpell.language" = "en,sv";
          "nix.formatterPath" = "nixfmt";
          "tinymist.exportPdf" = "onDocumentHasTitle";
          "tinymist.formatterMode" = "typstyle";
          "[typst]" = {
            "editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?";
          };
        }
        // (
          let
            prettierLangs = [
              "javascript"
              "typescript"
              "json"
              "jsonc"
              "html"
              "css"
              "scss"
              "markdown"
              "yaml"
              "vue"
              "graphql"
              "typescriptreact"
              "javascriptreact"
            ];
            withBrackets = map (lang: "[${lang}]") prettierLangs;
            scope = builtins.concatStringsSep "" withBrackets;
          in
          {
            ${scope}."editor.defaultFormatter" = "esbenp.prettier-vscode";
          }
        );
        keybindings = [
          {
            key = "alt+t";
            command = "editor.action.goToTypeDefinition";
          }
          {
            key = "shift+alt+up";
            command = "editor.action.copyLinesUpAction";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "shift+alt+down";
            command = "editor.action.copyLinesDownAction";
            when = "editorTextFocus && !editorReadonly";
          }
        ];
      };
    };

    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Flameshot Screenshot";
        binding = "Print";
        # ^ this will clash with built-in "Interactive Screenshot", so for it to
        # work it might be necessary to go to Settings > Keyboard > View and
        # Customize Shortcuts > Custom Shortcuts > Flameshot Screenshots, then
        # set the binding to backspace (disabled), and then re-set it to Print
        command = ''script --command "flameshot gui" /dev/null'';
      };
    };
  };

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

  virtualisation.docker.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    fd
    ripgrep
    nixfmt-rfc-style
    inputs.agenix.packages.${system}.default # agenix CLI
  ];

  # DNS over HTTPS (DoH) via Cloudflare
  services.dnsproxy = {
    enable = true;
    settings = {
      # https://dnscrypt.info/stamps/
      upstream = [
        # cloudflare
        "sdns://AgcAAAAAAAAABzEuMS4xLjEAEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5" # 1.1.1.1
        "sdns://AgcAAAAAAAAABzEuMC4wLjEAEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5" # 1.0.0.1
        "sdns://AgcAAAAAAAAAFlsyNjA2OjQ3MDA6NDcwMDo6MTExMV0AIDFkb3QxZG90MWRvdDEuY2xvdWRmbGFyZS1kbnMuY29tCi9kbnMtcXVlcnk" # [2606:4700:4700::1111]
        "sdns://AgcAAAAAAAAAFlsyNjA2OjQ3MDA6NDcwMDo6MTAwMV0AIDFkb3QxZG90MWRvdDEuY2xvdWRmbGFyZS1kbnMuY29tCi9kbnMtcXVlcnk" # [2606:4700:4700::1001]
      ];
      fallback = [
        # quad9
        "sdns://AgcAAAAAAAAABzkuOS45LjkADWRucy5xdWFkOS5uZXQKL2Rucy1xdWVyeQ" # 9.9.9.9
        "sdns://AgcAAAAAAAAADzE0OS4xMTIuMTEyLjExMgANZG5zLnF1YWQ5Lm5ldAovZG5zLXF1ZXJ5" # 149.112.112.112
        "sdns://AgcAAAAAAAAADVsyNjIwOmZlOjpmZV0ADWRucy5xdWFkOS5uZXQKL2Rucy1xdWVyeQ" # [2620:fe::fe]
        "sdns://AgcAAAAAAAAADFsyNjIwOmZlOjo5XQANZG5zLnF1YWQ5Lm5ldAovZG5zLXF1ZXJ5" # [2620:fe::9]
      ];
      listen-addrs = [ "127.0.0.53" ];
    };
    flags = [ "--cache" ];
  };
  networking = {
    nameservers = [ "127.0.0.53" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
  };
  # deal with captive portals despite custom DNS and DoH
  programs.captive-browser = {
    enable = true;
    interface = "wlp3s0";
    # same as default but with brave instead of chromium
    browser = lib.concatStringsSep " " [
      ''env XDG_CONFIG_HOME="$PREV_CONFIG_HOME"''
      (lib.getExe pkgs.brave)
      ''--user-data-dir=''${XDG_DATA_HOME:-$HOME/.local/share}/brave-captive''
      ''--proxy-server="socks5://$PROXY"''
      ''--host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost"''
      ''--no-first-run''
      ''--new-window''
      ''--incognito''
      ''-no-default-browser-check''
      ''http://cache.nixos.org/''
    ];
  };

  age.secrets = {
    nixSigningKey.file = secretsDir + "/nix-signing-key.sec.age";
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # used to sign build outputs before sending to remote when using
      # `nixos-rebuild` with `--target-host`; must be trusted by host
      secret-key-files = [ config.age.secrets.nixSigningKey.path ];
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

  system.stateVersion = "24.05";
}
