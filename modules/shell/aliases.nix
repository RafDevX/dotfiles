{ ... }:

{
  rso.home.shellAliases = {
    fd = "fd -u"; # unrestricted search (include hidden and ignored files)
    mv = "mv -i"; # prompt before overwrite
    cp = "cp -i"; # prompt before overwrite
    rm = "rm -I"; # prompt before removing >3 files or recursively
  };
}
