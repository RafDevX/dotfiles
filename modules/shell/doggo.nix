# A drop-in replacement for dogdns (which was a better dig-like DNS utility)
# Doggo is written in Go while dog was Rust, but sadly the latter is fully
# unmaintained and considered insecure (due to no dependency updates)
{ pkgs, ... }:

{
  rso.home = {
    packages = with pkgs; [ doggo ];

    shellAliases.dog = "doggo";
  };
}
