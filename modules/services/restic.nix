{
  config,
  lib,
  ...
}:
{
  options.rso.restic = {
    paths = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      default = [ ];
      example = [
        "/home"
        "/var/lib/service"
      ];
      description = ''
        Paths to back up. If empty, no backups are performed.
      '';
    };

    passwordFile = lib.mkOption {
      type = with lib.types; singleLineStr;
      example = "/etc/restic/repo-pwd";
      description = ''
        Path to file containing the password to
        unlock all target repositories.
      '';
    };

    backupPrepareCommand = lib.mkOption {
      type = with lib.types; nullOr lines;
      default = null;
      description = ''
        Script to run before starting the backup process.
      '';
    };

    targets = lib.mkOption {
      default = { };
      description = ''
        Restic repositories to back up to. If empty, no backups are performed.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              repository = lib.mkOption {
                type = with lib.types; singleLineStr;
                example = "s3:https://s3.amazonaws.com/bucket-name";
                description = ''
                  Restic repository to back up to.
                '';
              };

              credentialsEnvFile = lib.mkOption {
                type = with lib.types; singleLineStr;
                example = "/etc/restic/creds";
                description = ''
                  Credentials to authenticate with to the server (not to
                  be confused with the repository's actual password).
                  Must be in env-file format, understandable by systemd.

                  Example for S3 (`s3:https://s3.amazonaws.com/bucket-name`):
                  ```
                  AWS_DEFAULT_REGION=eu-north-1
                  AWS_ACCESS_KEY_ID=something
                  AWS_SECRET_ACCESS_KEY=something-else
                  ```

                  Example for restic REST server (`rest:https://example.com/path`):
                  ```
                  RESTIC_REST_USERNAME=client-hostname
                  RESTIC_REST_PASSWORD=password123
                  ```
                  (If server is configured to use private repositories,
                  `RESTIC_REST_USERNAME` must match the path provided.)
                '';
              };

              timer = lib.mkOption {
                type = with lib.types; singleLineStr;
                default = "03:42";
                example = "daily UTC"; # midnight
                description = ''
                  When to run the backup.
                  See {manpage}`systemd.timer(7)` § Calendar Events.
                '';
              };
            };
          }
        )
      );
    };

    extraServiceOptions = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      example = {
        startLimitIntervalSec = 12 * 60 * 60;
        startLimitBurst = 1;
      };
      description = ''
        Additional options to pass to `systemd.services.*`, for each of the
        services created for Restic backups (one per target).
      '';
    };
  };

  config =
    let
      cfg = config.rso.restic;
    in
    lib.mkIf (builtins.length cfg.paths != 0) {
      services.restic.backups = builtins.mapAttrs (name: target: {
        inherit (cfg) passwordFile backupPrepareCommand;
        inherit (target) repository;

        paths = cfg.paths ++ [
          "/var/lib/nixos" # contains uid/gid maps, required for restoring
        ];

        initialize = true;
        timerConfig = {
          OnCalendar = target.timer;
          RandomizedDelaySec = 600; # 10min
          Persistent = true;
        };

        environmentFile = target.credentialsEnvFile;

        checkOpts = [
          # ensure data integrity
          "--read-data-subset=2.5%"
        ];

        pruneOpts = [
          "--keep-within-daily 7d" # keep one snapshot for each of the last 7 days
          "--keep-within-weekly 2m" # +, keep one for each week in the last 2 months
          "--keep-within-monthly 1y" # +, keep one for each month in the last year
          "--keep-within-yearly 10y" # +, keep one for each year in the last decade
        ];
      }) cfg.targets;

      # additional configs for systemd services
      systemd.services = lib.mkIf (cfg.extraServiceOptions != { }) (
        builtins.mapAttrs' (
          name: target:
          let
            # must match service name in nixpkgs restic module
            # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/backup/restic.nix#L368
            serviceName = "restic-backups-${name}";
          in
          lib.nameValuePair serviceName cfg.extraServiceOptions
        ) cfg.targets
      );
    };
}
