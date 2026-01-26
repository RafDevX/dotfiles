{ ... }:

{
  rso.home = {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;

      options = {
        line-numbers = true;
        navigate = true; # press n to go to next file in diff

        hyperlinks = true;
        hyperlinks-file-link-format = "vscode://file/{path}:{line}";
      };
    };

    programs.git.settings.merge.conflictStyle = "zdiff3";

    shellAliases.diff = "delta";
  };
}
