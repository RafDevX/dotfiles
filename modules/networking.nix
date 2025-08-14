# Network configuration, including host interface names
{ lib, ... }:

{
  options.rso.networking = {
    wirelessInterface = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      default = null;
      example = "wlo1";
      description = ''
        The host's main wireless interface, if any.
      '';
    };
  };
}
