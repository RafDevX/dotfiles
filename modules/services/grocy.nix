{ config, lib, ... }:

{
  options.rso.grocy = {
    enable = lib.mkEnableOption "Grocy";

    domain = lib.mkOption {
      type = with lib.types; singleLineStr;
      example = "sub.example.com";
      description = ''
        Domain where to serve the Grocy application (using nginx).
      '';
    };
  };

  config =
    let
      cfg = config.rso.grocy;
    in
    lib.mkIf cfg.enable {
      services.grocy = {
        enable = true;
        hostName = cfg.domain;

        settings = {
          culture = "en";
          currency = "SEK";

          calendar = {
            firstDayOfWeek = 1; # Monday
            showWeekNumber = true;
          };
        };
      };

      rso.restic.paths = [ config.services.grocy.dataDir ];
    };
}
