{ ... }:

{
  rso.home = {
    programs.git = {
      delta = {
        enable = true;
        options = {
          line-numbers = true;
          navigate = true; # press n to go to next file in diff

          hyperlinks = true;
          hyperlinks-file-link-format = "vscode://file/{path}:{line}";
        };
      };

      extraConfig.merge.conflictStyle = "zdiff3";
    };

    shellAliases.diff = "delta";
  };
}
