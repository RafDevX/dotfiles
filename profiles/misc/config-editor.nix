# Environments where this flake / NixOS configurations are edited
{
  config,
  pkgs,
  secrets,
  inputs,
  ...
}:

{
  age.secrets = {
    nixSigningKey.file = secrets.host.nixSigningKey;
  };

  nix.settings.secret-key-files = [ config.age.secrets.nixSigningKey.path ];

  environment.systemPackages = with pkgs; [
    nixfmt
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default # agenix CLI
  ];
}
