{ lib, inputs, ... }:

let
  /*
    Synopsis: mkHost hostname hostPath { extraArgs ? {}, extraModules ? [] }

    Generate a NixOS system configuration for the specified hostname.

    Inputs:
    - hostname: The hostname for the target NixOS system.
    - hostPath: The path to the directory containing host-specific Nix configs.
    - extraArgs: Optional attributes to be passed down to all modules.
    - extraModules: Optional list of additional NixOS modules to include.

    Output Format:
    A NixOS system configuration representing the specified hostname, given the
    provided parameters and additional modules.
  */
  mkHost =
    hostname: hostPath:
    {
      extraArgs ? { },
      extraModules ? [ ],
      ...
    }:
    lib.nixosSystem {
      # note: shouldn't actually pass "system" here; see lib.nixosSystem at
      # https://github.com/NixOS/nixpkgs/blob/release-25.05/flake.nix#L43
      # system = "x86_64-linux";
      # (it's already set in the generated hardware.nix)

      specialArgs = {
        inherit inputs;
      }
      // extraArgs;

      modules = [
        { networking.hostName = hostname; }
        hostPath
      ]
      ++ extraModules;
    };

  /*
    Synopsis: mkHosts hostsDir { extraArgs ? {}, extraModules ? [] }

    Generate a set of NixOS system configurations for the hosts defined in the
    specified directory.

    Inputs:
    - hostsDir: The path to the directory containing host-specific configs.
    - extraArgs: Optional attributes to be passed down to all modules.
    - extraModules: Optional list of additional NixOS modules to include.

    Output Format:
    An attribute set representing NixOS system configurations for the hosts
    found in the `hostsDir`. The function scans the `hostsDir` directory
    for host-specific Nix configurations and generates a set of NixOS
    system configurations for each host. The resulting attribute set maps
    hostnames to their corresponding NixOS system configurations.
  */
  mkHosts =
    hostsDir:
    opts@{
      extraArgs ? { },
      extraModules ? [ ],
      ...
    }:
    lib.pipe (builtins.readDir hostsDir) [
      # Ignore hosts starting with an underscore
      (lib.filterAttrs (path: _: !(lib.hasPrefix "_" path)))
      # Generate host
      (lib.mapAttrs' (
        name: type:
        let
          # Get hostname from host path
          hostPath = hostsDir + "/${name}";
          hostname = lib.removeSuffix ".nix" (builtins.baseNameOf hostPath);
        in
        lib.nameValuePair hostname (mkHost hostname hostPath opts)
      ))
    ];
in
{
  inherit mkHost mkHosts;
}
