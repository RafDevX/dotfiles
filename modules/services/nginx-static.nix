{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.rso.nginx-static = lib.mkOption {
    default = { };
    description = ''
      Static file directories to serve at specified addresses using nginx.
    '';
    type = lib.types.attrsOf (
      lib.types.submodule (
        { ... }:
        {
          options = {
            rootDirectoryName = lib.mkOption {
              type = with lib.types; singleLineStr;
              example = "example";
              description = ''
                Directory name, within `/srv/www`.

                For example, if `abc` is used as a value in this option, nginx
                will be configured to serve files in `/srv/www/abc`.
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
                Users who can access the served files, specified as pairs of
                usernames and password hashes. Authentication is performed via
                HTTP basic auth.

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
      cfg = config.rso.nginx-static;
    in
    lib.mkIf (cfg != { }) (
      lib.rso.mkMergeTopLevel [ "services" "systemd" ] (
        lib.mapAttrsToList (
          name: static:
          let
            root = "/srv/www/${static.rootDirectoryName}";
          in
          {
            services.nginx.virtualHosts.${name} = {
              inherit root;

              enableACME = true;
              # redirect to HTTPS automatically
              forceSSL = true;

              basicAuthFile = lib.mkIf (static.basicAuthHashes != { }) (
                pkgs.writeText "${name}.htpasswd" (
                  builtins.concatStringsSep "\n" (
                    lib.mapAttrsToList (user: hash: "${user}:${hash}") static.basicAuthHashes
                  )
                )
              );
            };

            systemd.tmpfiles.rules =
              let
                inherit (config.services.nginx) user group;
              in
              [ "d ${root} 0755 ${user} ${group}" ];
          }
        ) cfg
      )
    );
}
