{ ... }:

{
  rso.home.programs.ssh = {
    enable = true;
    matchBlocks = {
      "*.rso.pt rso.pt" = {
        hostname = "ssh.%h";
      };
      "*.datasektionen.se" = {
        user = "rmfseo";
      };
    };
  };
}
