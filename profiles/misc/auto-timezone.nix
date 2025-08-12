# Automatically detect timezone based on current geo-location
{ lib, ... }:

{
  time.timeZone = null;
  services.automatic-timezoned.enable = true;
  services.geoclue2.enableDemoAgent = lib.mkForce true; # because Gnome...
  services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";
  # ^ necessary because Mozilla Location Service has been shut down
}
