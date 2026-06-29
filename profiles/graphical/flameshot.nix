{
  config,
  pkgs-unstable,
  lib,
  ...
}:

{
  rso.home.packages = with pkgs-unstable; [ flameshot ];
  # ^ switch back to stable when v14.0.0 is available there

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
