{
  pkgs,
  pkgs-unstable,
  profiles,
  lib,
  inputs,
  ...
}:

{
  imports = with profiles; [
    kind.laptop
    firmware.uefi
    graphical.gnome
    ./hardware.nix
  ];

  services.fprintd.enable = true; # enable fingerprint

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

  programs.firefox.enable = true;
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
      nil # nix LSP
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

          "nix.formatterPath" = [
            "nix"
            "fmt"
          ];
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettings" = {
            nil = {
              formatting = {
                command = [
                  "nix"
                  "fmt"
                ];
              };
            };
          };

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

  virtualisation.docker.enable = true;

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

  system.stateVersion = "24.05";
}
