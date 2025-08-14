{ ... }:

{
  rso.home.programs.git = {
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
}
