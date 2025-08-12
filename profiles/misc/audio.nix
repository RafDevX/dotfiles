{ ... }:

{
  services.pulseaudio.enable = false; # might have been enabled by Gnome/etc.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
