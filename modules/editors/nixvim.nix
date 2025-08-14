{ inputs, ... }:

{
  home-manager.sharedModules = [ inputs.nixvim.homeManagerModules.nixvim ];

  rso.home = {

    sessionVariables.EDITOR = "nvim";

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
  };
}
