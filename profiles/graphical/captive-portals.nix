# Custom browser to access captive portals despite custom DNS and DoH
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.captive-browser = {
    enable = true;
    interface = config.rso.networking.wirelessInterface;
    # same as default but with brave instead of chromium
    browser = lib.concatStringsSep " " [
      ''env XDG_CONFIG_HOME="$PREV_CONFIG_HOME"''
      (lib.getExe pkgs.brave)
      "--user-data-dir=\${XDG_DATA_HOME:-$HOME/.local/share}/brave-captive"
      ''--proxy-server="socks5://$PROXY"''
      ''--host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost"''
      "--no-first-run"
      "--new-window"
      "--incognito"
      "-no-default-browser-check"
      "http://cache.nixos.org/"
    ];
  };

  rso.home.packages = [ pkgs.brave ];
}
