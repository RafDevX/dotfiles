{
  description = "Raf's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/v1.12.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.darwin.follows = ""; # saves resources on linux
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      disko,
      agenix,
      ...
    }@inputs:

    let
      lib = nixpkgs.lib.extend (
        final: _prev:
        import ./lib ({
          inherit inputs;

          lib = final;
        })
      );

      dependencyModules = [
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        agenix.nixosModules.default
      ];

      userConfig = {
        username = "raf";
        name = "Raf";
        hashedPassword = lib.mkDefault "$y$j9T$22ptNC3YRhTx7OgmwpMuU0$EQUgjVjGlRkfwYnwFp0x/Dnn1yjW1XH3vocdBnNCPyB";
      };

      system = "x86_64-linux";
    in
    {
      nixosConfigurations = lib.rso.mkHosts ./hosts {
        extraArgs = {
          # pkgs is already a default arg passed to NixOS modules, but we also
          # want to have a pkgs-unstable equivalent
          pkgs-unstable = import nixpkgs-unstable { inherit system; };
          profiles = lib.rso.mkProfiles ./profiles;
          secretsDir = ./secrets;
        };

        extraModules =
          dependencyModules
          ++ (lib.rso.mkModules ./modules)
          ++ [
            { rso.me = userConfig; }
          ];
      };

      formatter = {
        ${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
      };
    };
}
