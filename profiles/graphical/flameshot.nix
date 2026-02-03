{
  config,
  pkgs,
  lib,
  ...
}:

{
  rso.home.packages = [
    # Change back to `pkgs.flameshot` when there's a new flameshot release;
    # This is just until PR #4363 is in nixpkgs, otherwise it does not support
    # copying to clipboard. Upstream says no release anytime soon though.
    (pkgs.flameshot.overrideAttrs (oldAttrs: {
      patches = oldAttrs.patches or [ ] ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/flameshot-org/flameshot/pull/4363.patch";
          hash = "sha256-G3uSLIWZ8mOVTgO3EtH8YgUbpMf8Qkuur6pcoM7hrug=";
        })
      ];
    }))
  ];

  rso.home.extraConfig.dconf.settings = lib.mkIf config.services.desktopManager.gnome.enable {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Flameshot Screenshot";
      binding = "Print";
      # ^ this will clash with built-in "Interactive Screenshot", so for it to
      # work it might be necessary to go to Settings > Keyboard > View and
      # Customize Shortcuts > Custom Shortcuts > Flameshot Screenshots, then
      # set the binding to backspace (disabled), and then re-set it to Print
      command = ''script --command "flameshot gui" /dev/null'';
    };
  };
}
