{ lib, inputs, ... }:

let
  /*
    Synopsis: mkProfiles profilesDir

    Generate profiles from the NixOS modules found in the specified directory.

    Inputs:
    - profilesDir: The path to the directory containing NixOS modules.

    Output Format:
    An attribute set representing profiles.
    The function uses the `rakeLeaves` function to recursively collect Nix files
    and directories within the `profilesDir` directory.
    The result is an attribute set mapping Nix files and directories
    to their corresponding keys.
    These profiles can be used to selectively apply certain configurations on a
    host-by-host basis, depending on necessity.
  */
  mkProfiles = profilesDir: lib.rso.rakeLeaves profilesDir;

  /*
    Synopsis: mkModules modulesDir

    Generate a list of NixOS modules found in the specified directory.

    Inputs:
    - modulesDir: The path to the directory containing NixOS modules.

    Output Format:
    A (flat) list of Nix files recursively collected from the given directory.
  */
  mkModules = modulesDir: lib.collect builtins.isPath (lib.rso.rakeLeaves modulesDir);

  /*
    Synopsis: mkSecrets secretsDir hostname

    Generate secrets from the age files found in the specified directory.

    Inputs:
    - secretsDir: The path to the directory containing age files.
    - hostname: This host's hostname.

    Output Format:
    An attribute set representing secrets, collected recursively from the given
    directory, where each leaf value is a file path.
    Keys correspond to file/directory names, except that they are given in
    camelCase instead of (what is here assumed to be) their original form in
    kebab-case, with trailing extensions removed.
    An additional top-level key `host` is defined as an alias to the top-level
    key corresponding to the given hostname; this means that files in a folder
    `machine/` will become accessible under secrets.host for host `machine`.
  */
  mkSecrets =
    secretsDir: hostname:
    let
      raked = lib.rso.rakeLeavesWithSuffix ".age" { } secretsDir;
      stripExtensions = key: builtins.head (lib.splitString "." key);
      mapper = key: lib.rso.kebabToCamel (stripExtensions key);
      secrets = lib.rso.mapAttrsRecursive' (name: value: lib.nameValuePair (mapper name) value) raked;
    in
    secrets // { host = secrets.${hostname}; };

  /*
    Synopsis: mkHost hostname hostPath { extraArgs ? (_:{}), extraModules ? [] }

    Generate a NixOS system configuration for the specified hostname.

    Inputs:
    - hostname: The hostname for the target NixOS system.
    - hostPath: The path to the directory containing host-specific Nix configs.
    - extraArgs: Function mapping hostname to extra arguments for all modules.
    - extraModules: Optional list of additional NixOS modules to include.

    Output Format:
    A NixOS system configuration representing the specified hostname, given the
    provided parameters and additional modules.
  */
  mkHost =
    hostname: hostPath:
    {
      extraArgs ? (_: { }),
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
      // (extraArgs hostname);

      modules = [
        { networking.hostName = hostname; }
        hostPath
      ]
      ++ extraModules;
    };

  /*
    Synopsis: mkHosts hostsDir { extraArgs ? (_: {}), extraModules ? [] }

    Generate a set of NixOS system configurations for the hosts defined in the
    specified directory.

    Inputs:
    - hostsDir: The path to the directory containing host-specific configs.
    - extraArgs: Function mapping hostname to extra arguments for all modules.
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
      extraArgs ? (_: { }),
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

  /*
    Synopsis: mkMergeTopLevel topLevelKeys subConfigs

    Generate a merged NixOS module configuration based on a list of sub-configs,
    merging them into one. Specifying the top-level keys is necessary to enable
    a workaround, otherwise this would fail for infinite recursion.

    See: https://gist.github.com/udf/4d9301bdc02ab38439fd64fbda06ea43 by udf

    Inputs:
    - topLevelKeys: A list of string keys to merge extract.
    - subConfigs: Configurations to merge.

    Output Format:
    An attribute set representing a NixOS module configuration.
  */
  mkMergeTopLevel =
    topLevelKeys: subConfigs:
    let
      # handle case where subConfigs is an empty list, so that the desired
      # attributes are always guaranteed to exist and evaluation never fails
      subConfigs' = subConfigs ++ [ (lib.genAttrs topLevelKeys (_: { })) ];
    in
    lib.getAttrs topLevelKeys (
      builtins.mapAttrs (k: v: lib.mkMerge v) (lib.foldAttrs (n: a: [ n ] ++ a) [ ] subConfigs')
    );
in
{
  inherit
    mkProfiles
    mkModules
    mkSecrets
    mkHost
    mkHosts
    mkMergeTopLevel
    ;
}
