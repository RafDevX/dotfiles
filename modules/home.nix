# Home manager configuration for the host's primary user account
{
  config,
  options,
  lib,
  ...
}:

{
  options.rso.home = {
    # Note that any options that depend on Home Manager will only be effective
    # if this is true, meaning that those options can be applied to all hosts
    # indiscriminately and rely on Home Manager only being enabled for hosts
    # where that makes sense, rather than having their own separate guards
    enable = lib.mkEnableOption "home-manager";

    packages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = ''
        User-specific packages to make available to the primary user.
      '';
    };

    shellAliases = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      example = {
        g = "git";
      };
      description = ''
        Simple command aliases for all shells.
      '';
    };

    sessionVariables = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      example = {
        EDITOR = "nvim";
      };
      description = ''
        Environment variables to always set at login for the primary user.
      '';
    };

    programs = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      example = {
        java.enable = true;
        fzf = {
          enable = true;
          enableZshIntegration = true;
        };
      };
      description = ''
        Program-specific configurations for the primary user's environment.
      '';
    };

    extraConfig = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      example = {
        qt.style.name = "motif";
      };
      description = ''
        Additional top-level home-manager configurations for the primary user.
      '';
    };
  };

  config =
    let
      cfg = config.rso.home;

      username = config.rso.me.username;
    in
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        users.${username} = lib.mkIf cfg.enable (lib.mkAliasDefinitions options.rso.home.extraConfig);
      };

      rso.home.extraConfig = {
        inherit (cfg) programs;

        home = {
          inherit username;
          inherit (cfg) packages shellAliases sessionVariables;

          homeDirectory = "/home/${username}";

          # note: this makes the assumption that home-manager will never be
          # enabled for the first time after the host machine's first NixOS
          # release upgrade, which really isn't necessarily true, but sure
          stateVersion = config.system.stateVersion;
        };
      };
    };
}
