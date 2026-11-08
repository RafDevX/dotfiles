{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.rso.nginx-app = lib.mkOption {
    default = { };
    description = ''
      Dynamic applications to expose through nginx reverse proxy.
    '';
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            workingDirectoryName = lib.mkOption {
              type = with lib.types; singleLineStr;
              example = "example";
              description = ''
                Working directory name, within `/srv/app`.

                For example, if `abc` is used as a value in this option, the
                application working directory path will be configured as
                `/srv/app/abc`.

                This directory should not be used for permanent storage!
                Applications should instead rely on persistence only for the
                `/var/lib/nginx-app/{name}` state directory, where `{name}` is
                the name passed to this option.
              '';
            };

            port = lib.mkOption {
              type = lib.types.ints.between 1 65535;
              default = 3000;
              description = ''
                Local port on which the application listens (on `127.0.0.1`).

                Automatically provided to the application as `PORT`.
              '';
            };

            execStart = lib.mkOption {
              type = lib.types.singleLineStr;
              example = "/path/to/npm start";
              description = ''
                Command to execute when starting the application.
              '';
            };

            packages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
              description = ''
                Packages to add to the application's PATH.
              '';
            };

            environment = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
              description = ''
                Environment variables passed to the application.

                The `PORT` variable is automatically set from the port option.
              '';
            };

            environmentFile = lib.mkOption {
              type = lib.types.nullOr lib.types.singleLineStr;
              default = null;
              example = "/var/lib/some-name/.env";
              description = ''
                Optional file containing additional environment variables.
              '';
            };

            basicAuthHashes = lib.mkOption {
              type = with lib.types; attrsOf singleLineStr;
              default = { };
              example = {
                alice = "$2y$05$8BGHMe9LdMb.trkLsg/BUODaZ.XJdqkrf5986a1EefWEPcvWxYSka";
                bob = "$2y$05$NrDQKsbiMH//JMP3yVecFOYib6rJP6CAJFNx/S.hFenjf1qDd9H1O";
              };
              description = ''
                Users who can access the served application, specified as pairs
                of usernames and password hashes. Authentication is performed
                via HTTP basic auth.

                Password hashes can be generated using `htpasswd -nB username`.

                If no users are specified, no basic auth protection is enabled.
              '';
            };
          };
        }
      )
    );
  };

  config =
    let
      cfg = config.rso.nginx-app;
    in
    lib.mkIf (cfg != { }) (
      lib.rso.mkMergeTopLevel [ "services" "systemd" ] (
        lib.mapAttrsToList (
          name: app:
          let
            cwd = "/srv/app/${app.workingDirectoryName}";
            stateDirectory = "nginx-app/${app.workingDirectoryName}";
          in
          {
            services.nginx.virtualHosts.${name} = {
              enableACME = true;
              # redirect to HTTPS automatically
              forceSSL = true;

              locations."/" = {
                proxyPass = "http://127.0.0.1:${toString app.port}";
                proxyWebsockets = true;
              };

              basicAuthFile = lib.mkIf (app.basicAuthHashes != { }) (
                pkgs.writeText "${name}.htpasswd" (
                  builtins.concatStringsSep "\n" (
                    lib.mapAttrsToList (user: hash: "${user}:${hash}") app.basicAuthHashes
                  )
                )
              );
            };

            systemd.services."nginx-app-${app.workingDirectoryName}" = {
              description = "Application served at ${name}";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];

              path = [ pkgs.bash ] ++ app.packages;

              environment = {
                PORT = toString app.port;
                HOME = "/var/lib/${stateDirectory}";
                NPM_CONFIG_CACHE = "/var/lib/${stateDirectory}/.npm";
              }
              // app.environment;

              serviceConfig = {
                DynamicUser = true;

                WorkingDirectory = cwd;
                ExecStart = app.execStart;
                EnvironmentFile = app.environmentFile;

                StateDirectory = stateDirectory; # created in /var/lib/
                StateDirectoryMode = "0700";

                Restart = "on-failure";
                RestartSec = "5s";

                # filesystem isolation
                ProtectHome = true;
                PrivateTmp = true;
                PrivateDevices = true;

                # kernel isolation
                ProtectKernelTunables = true;
                ProtectKernelModules = true;
                ProtectControlGroups = true;
                ProtectKernelLogs = true;
                ProtectClock = true;
                ProtectHostname = true;

                # privilege restrictions (capabilities set to empty set)
                CapabilityBoundingSet = "";
                AmbientCapabilities = "";

                # process restrictions
                RestrictRealtime = true;
                RestrictSUIDSGID = true;
                LockPersonality = true;
                SystemCallArchitectures = "native";

                # only allow conventional network and unix sockets
                RestrictAddressFamilies = [
                  "AF_UNIX"
                  "AF_INET"
                  "AF_INET6"
                ];

                # files created by the application are private by default
                UMask = "0077";
              };
            };

            systemd.tmpfiles.rules = [
              "d ${cwd} 0755 root root"
            ];
          }
        ) cfg
      )
    );
}
