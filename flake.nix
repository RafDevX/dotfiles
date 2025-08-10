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
    {
      nixosConfigurations = {
        # Personal Computers: Cities in the Netherlands
        # https://en.wikipedia.org/wiki/List_of_cities_in_the_Netherlands
        rotterdam = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable { inherit system; };
            secretsDir = ./secrets;
          };

          modules = [
            ./hosts/rotterdam
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
          ];
        };

        # Servers: Stars (Modern Proper Name)
        # https://en.wikipedia.org/wiki/List_of_proper_names_of_stars (A->Z)
        avior = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable { inherit system; };
            secretsDir = ./secrets;
          };

          modules = [
            ./hosts/avior
            disko.nixosModules.disko
            agenix.nixosModules.default
          ];
        };
      };

      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      };
    };
}
