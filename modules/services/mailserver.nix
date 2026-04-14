{
  config,
  lib,
  ...
}:
{
  options.rso.mailserver = {
    enable = lib.mkEnableOption "Simple NixOS Mailserver";

    primaryUsername = lib.mkOption {
      type = with lib.types; singleLineStr;
      example = "john.doe";
      description = ''
        Primary username that will be combined with the specified primary domain
        (e.g., `john.doe@example.com`) to form the server's primary address, to
        which all mail will be forwarded (catchall alias).
      '';
    };

    primaryPasswordHash = lib.mkOption {
      type = with lib.types; singleLineStr;
      example = "$2b$05$rSLEDMr4j5NW.W1a3ueSz.QhooGRLJBJyzfTk.lXOEizIfOLkp.ly";
      description = ''
        Password hash to be set for the primary email account (as specified by
        `primary-address` and `primary-domain`).

        Generate with `mkpasswd -sm bcrypt`.
      '';
    };

    primaryDomain = lib.mkOption {
      type = with lib.types; singleLineStr;
      example = "example.com";
      description = ''
        Primary domain to handle mail for.
      '';
    };

    mailerDomain = lib.mkOption {
      type = with lib.types; singleLineStr;
      default = "mail.${config.rso.mailserver.primaryDomain}";
      example = "mail.example.com";
      description = ''
        Domain at which the mail server should be hosted.

        If not specified, this value will be calculated dynamically as the
        `mail.` subdomain of the primary domain (for example, if the primary
        domain is `example.com`, the mailer domain will be `mail.example.com`).
      '';
    };

    forwardToExternal = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      default = null;
      example = "external@gmail.com";
      description = ''
        External address to which all of the primary address's emails should be
        forwarded, if any.
      '';
    };
  };

  config =
    let
      cfg = config.rso.mailserver;
      primaryAddress = "${cfg.primaryUsername}@${cfg.primaryDomain}";
    in
    lib.mkIf cfg.enable {
      mailserver = {
        enable = true;
        stateVersion = 3;

        fqdn = cfg.mailerDomain;
        domains = [ cfg.primaryDomain ];

        # this sets up a stripped down nginx and opens port 80
        certificateScheme = "acme-nginx";

        # to deal with spam, see options `rejectRecipients` and `rejectSender`

        rejectSender = [
          "upgym.torresvedras@gmail.com"
        ];

        loginAccounts = {
          ${primaryAddress} = {
            hashedPassword = cfg.primaryPasswordHash;

            aliases = [ "@${cfg.primaryDomain}" ];
          };
        };

        forwards = lib.optionalAttrs (cfg.forwardToExternal != null) {
          ${primaryAddress} = cfg.forwardToExternal;
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = "lets-encrypt@rso.pt";
      };
    };
}
