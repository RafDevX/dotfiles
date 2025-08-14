# A cat(1) clone with syntax highlighting
{ ... }:

{
  rso.home = {
    programs.bat.enable = true;

    shellAliases.cat = "bat";
  };
}
