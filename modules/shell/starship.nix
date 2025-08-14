{ ... }:

{
  rso.home.programs.starship = {
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
}
