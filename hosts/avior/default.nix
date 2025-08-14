{
  config,
  secretsDir,
  profiles,
  ...
}:

{
  imports = with profiles; [
    kind.server
    firmware.bios
    services.nginx
    ./disk.nix
    ./hardware.nix
  ];

  services.postgresql = {
    enable = true;
    enableJIT = true;
  };

  services.nginx.virtualHosts."firefly.rso.pt" = {
    enableACME = true;
    # redirect to HTTPS automatically
    forceSSL = true;
  };

  services.firefly-iii = {
    enable = true;
    virtualHost = "firefly.rso.pt";
    enableNginx = true;
    settings = {
      APP_URL = "https://firefly.rso.pt";
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
      TZ = "Europe/Lisbon";
    };
  };

  age.secrets = {
    firefly3AppKey = {
      file = secretsDir + "/firefly3-app-key.age";
      owner = config.services.firefly-iii.user;
    };
    firefly3DbPassword = {
      file = secretsDir + "/firefly3-db-password.age";
      owner = config.services.firefly-iii.user;
    };
    firefly3MailPassword = {
      file = secretsDir + "/firefly3-mail-password.age";
      owner = config.services.firefly-iii.user;
    };
  };

  system.stateVersion = "25.05";
}
