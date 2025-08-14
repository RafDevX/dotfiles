{ config, ... }:

{
  rso.home.programs.direnv = {
    enable = true;
    enableZshIntegration = config.rso.home.programs.zsh.enable;
    nix-direnv.enable = true;
  };
}
