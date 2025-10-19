{ ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # this pins apps to the dock so that [Win+N] will open/show the Nth pin,
  # making it easier to switch between windows (e.g., Win+3 always shows the
  # current Discord window, even when Win+Tab won't)
  # (maybe should check if they're actually installed before referring to them
  # though, not sure what'll happen if they don't exist)
  rso.home.extraConfig.dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Console.desktop" # Win+1
        "brave-browser.desktop" # Win+2
        "discord.desktop" # Win+3
        "Mattermost.desktop" # Win+4
        "spotify.desktop" # Win+5
      ];
    };
  };
}
