{
  config,
  secrets,
  lib,
  ...
}:

{
  options.rso.firefly-iii = {
    enable = lib.mkEnableOption "Firefly-III";

    domain = lib.mkOption {
      type = with lib.types; singleLineStr;
      example = "sub.example.com";
      description = ''
        Domain where to serve the Firefly application (using nginx).
      '';
    };
  };

  config =
    let
      cfg = config.rso.firefly-iii;
    in
    lib.mkIf cfg.enable {
      age.secrets = {
        firefly3AppKey = {
          file = secrets.host.firefly3AppKey;
          owner = config.services.firefly-iii.user;
        };
        firefly3DbPassword = {
          file = secrets.host.firefly3DbPassword;
          owner = config.services.firefly-iii.user;
        };
        firefly3MailPassword = {
          file = secrets.host.firefly3MailPassword;
          owner = config.services.firefly-iii.user;
        };
      };

      services.firefly-iii = {
        enable = true;
        virtualHost = cfg.domain;
        enableNginx = true;
        settings = {
          APP_URL = "https://${cfg.domain}";
          APP_ENV = "production";
          APP_KEY_FILE = config.age.secrets.firefly3AppKey.path;
          SITE_OWNER = "firefly@rso.pt";

          DB_CONNECTION = "pgsql";
          DB_HOST = "localhost";
          DB_DATABASE = "firefly-iii";
          DB_USERNAME = "firefly-iii";
          DB_PASSWORD_FILE = config.age.secrets.firefly3DbPassword.path;

          MAIL_MAILER = "smtp";
          MAIL_HOST = "mail.rso.pt";
          MAIL_PORT = "587";
          MAIL_FROM = "firefly@rso.pt";
          MAIL_USERNAME = "firefly@rso.pt";
          MAIL_PASSWORD_FILE = config.age.secrets.firefly3MailPassword.path;
          MAIL_ENCRYPTION = "tls";

          ENABLE_EXCHANGE_RATES = "true";
          ENABLE_EXTERNAL_RATES = "true";

          TRUSTED_PROXIES = "**";
          COOKIE_SECURE = "true";
          COOKIE_SAMESITE = "strict";
          TZ = config.time.timeZone;
        };
      };

      # enable HTTPS
      services.nginx.virtualHosts.${cfg.domain} = {
        enableACME = true;
        # redirect to HTTPS automatically
        forceSSL = true;
      };

      rso.restic.paths = [
        "${config.services.firefly-iii.dataDir}/storage/upload"
      ];
    };
}
