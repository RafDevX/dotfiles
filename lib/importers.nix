{ lib, ... }:

let
  rakeLeaves = rakeLeavesWithSuffix ".nix" { defaultName = "default"; };

  rakeLeavesWithSuffix =
    /*
      Synopsis: rakeLeavesWithSuffix suffix args@{ defaultName ? null } path

      Recursively collect the files with `suffix` of `path` into attrs.

      Output Format:
      An attribute set where all files ending in `suffix` and directories with
      `defaultName`+`suffix` in them are mapped to keys that are either the file
      with `suffix` stripped or the folder name. All other directories are
      recursed further into nested attribute sets with the same format.

      Example file structure (with `suffix` ".nix" and `defaultName` "default"):
      ```
      ./core/default.nix
      ./base.nix
      ./main/dev.nix
      ./main/os/default.nix
      ```

      Example output:
      ```
      {
        core = ./core;
        base = ./base.nix;
        main = {
          dev = ./main/dev.nix;
          os = ./main/os;
        };
      }
      ```
    */
    suffix:
    args@{
      defaultName ? null,
    }:
    dirPath:
    let
      sieve =
        file: type:
        # Only rake files ending in suffix or directories
        (type == "regular" && lib.hasSuffix suffix file) || (type == "directory");

      collect = file: type: {
        name = lib.removeSuffix suffix file;
        value =
          let
            path = dirPath + "/${file}";
          in
          if
            (type == "regular")
            || (
              defaultName != null
              && type == "directory"
              && builtins.pathExists (path + "/${defaultName}${suffix}")
            )
          then
            path
          # recurse on directories that don't contain a default file
          else
            rakeLeavesWithSuffix suffix args path;
      };

      files = lib.filterAttrs sieve (builtins.readDir dirPath);
    in
    lib.filterAttrs (_n: v: v != { }) (lib.mapAttrs' collect files);
in
{
  inherit rakeLeaves rakeLeavesWithSuffix;
}
