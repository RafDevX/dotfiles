{ config, pkgs, ... }:

{
  rso.home = {
    programs = {
      zsh = {
        enable = true;

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

      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      eza = {
        enable = true;
        enableZshIntegration = true;
        git = config.rso.home.programs.git.enable;
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };

    # zoxide: echo matched dir before navigating
    sessionVariables._ZO_ECHO = "1";
  };
}
