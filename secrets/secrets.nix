let
  rso = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwaEu0TGRXhxjk1+Pz2LP66Vfvvgr3IvxkRfkcRiP0Y raf@rotterdam"
  ];

  # Personal Computers
  rotterdam = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICALhZfVq0qUaEmn4FGPxErmHf7qIJgoiS7lJVPoLk9m";

  # Servers
  avior = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCaGPjz/YuBkQK/WGOKwFhhjI+dXjBOOBG2w4KJ2RKG";
in
{
  "nix-signing-key.sec.age".publicKeys = rso ++ [ rotterdam ];
}
