{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fd
    ripgrep
    htop
  ];
}
