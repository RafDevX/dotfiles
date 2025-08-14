# Environments where this flake / NixOS configurations are edited
{
  config,
  pkgs,
  secretsDir,
  inputs,
  ...
}:

{
  age.secrets = {
    nixSigningKey.file = secretsDir + "/nix-signing-key.sec.age";
  };

  nix.settings.secret-key-files = [ config.age.secrets.nixSigningKey.path ];

  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    inputs.agenix.packages.${system}.default # agenix CLI
  ];
}
