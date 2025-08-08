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
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      disko,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        # Personal Computers: Cities in the Netherlands
        # https://en.wikipedia.org/wiki/List_of_cities_in_the_Netherlands
        rotterdam = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable { inherit system; };
          };

          modules = [
            ./rotterdam
            home-manager.nixosModules.home-manager
          ];
        };

        # Servers: Stars (Modern Proper Name)
        # https://en.wikipedia.org/wiki/List_of_proper_names_of_stars (A->Z)
        avior = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable { inherit system; };
          };

          modules = [
            ./avior
            disko.nixosModules.disko
          ];
        };
      };

      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      };
    };
}
