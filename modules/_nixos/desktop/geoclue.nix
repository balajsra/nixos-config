{ pkgs, ... }:

{
  # https://wiki.nixos.org/wiki/Geoclue

  location.provider = "geoclue2";

  services.geoclue2 = {
    enable = true;
    enableNmea = false;
    enable3G = false;
    enableCDMA = false;
    enableModemGPS = false;
    enableWifi = true;
    enableDemoAgent = true;
    geoProviderUrl = "https://api.beacondb.net/v1/geolocate";

    appConfig.gammastep = {
      isAllowed = true;
      isSystem = false;
    };

    appConfig.gammastep-indicator = {
      isAllowed = true;
      isSystem = false;
    };
  };
}
