# Configuration for the host's primary user account
{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.rso.me = {
    username = lib.mkOption {
      type = with lib.types; singleLineStr;
      example = "john";
      description = ''
        Username for the host's primary user account.
      '';
    };

    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      example = "John Doe";
      description = ''
        Description for the host's primary user account.

        This corresponds to the /etc/passwd comment/GECOS field.
      '';
    };

    hashedPassword = lib.mkOption {
      type = with lib.types; singleLineStr;
      example = "$y$j9T$kGpQVCjF.2lMS2zYZLGtS1$dXV5jnEcdJcRZALfCtAYAIQn9CU6MDu0/g/eB94Lyj3";
      description = ''
        Password for the host's primary user account (hashed).

        Use `mkpasswd` to generate a value for this option.
      '';
    };

    shell = lib.mkOption {
      type = with lib.types; package;
      default = pkgs.bash;
      description = ''
        Default shell for the host's primary user account.

        Remember to also install the package! For example, `programs.zsh.enable`
        should be set to `true` if `pkgs.zsh` is passed here.
      '';
    };

    extraGroups = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      default = [ ];
      example = [
        "networkmanager"
        "wireshark"
      ];
      description = ''
        Additional groups the host's primary user account should be a part of.

        These refer to auxiliary groups (i.e., extra): the account's main group
        is always their personal group homonymous with their account.

        Note that the account is always part of `wheel`, so that group should
        not be listed here.
      '';
    };

    authorizedKeys = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      default = [ ];
      example = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwaEu0TGRXhxjk1+Pz2LP66Vfvvgr3IvxkRfkcRiP0Y john@machine"
      ];
      description = ''
        Public keys that can be used to authenticate as the host's primary user
        account via SSH, if an SSH server is enabled.
      '';
    };
  };

  config =
    let
      cfg = config.rso.me;
    in
    {
      # ensure users and groups are set declaratively
      users.mutableUsers = false;

      users.users.${cfg.username} = {
        inherit (cfg) hashedPassword shell;

        isNormalUser = true;
        description = cfg.name;
        createHome = true;
        extraGroups = [ "wheel" ] ++ cfg.extraGroups;

        openssh.authorizedKeys.keys = cfg.authorizedKeys;
      };
    };
}
