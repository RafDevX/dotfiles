{ ... }:

{
  rso.home.programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Rafael Oliveira";
        email = "rafdev.x@gmail.com";
      };

      core.whitespace = "tab-in-indent,tabwidth=4";
      init.defaultBranch = "master";
      commit.verbose = true;
      pull.rebase = true;
      rerere.enabled = true;
      diff.colorMoved = "default"; # color moved codeblocks differently in diff
      url."git@github.com:".pushinsteadOf = "https://github.com/";
    };

    signing = {
      key = "2997CA7C4C3135D1";
      signByDefault = true;
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
