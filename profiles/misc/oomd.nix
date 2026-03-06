# User-space OOM killer to trigger before the Kernel one (to prevent freezes)
{ ... }:

{
  # Default memory threshold is 80%
  systemd.oomd = {
    enableRootSlice = true;
    enableUserSlices = true;
  };
}
