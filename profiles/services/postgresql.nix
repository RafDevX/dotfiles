{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.postgresql = {
    enable = true;
    enableJIT = true;
  };

  rso.restic =
    let
      dumpPath = "/root/postgres_dump.sql";

      sudo = lib.getExe pkgs.sudo;
      dumpall = lib.getExe' config.services.postgresql.finalPackage "pg_dumpall";
    in
    {
      backupPrepareCommand = "${sudo} -u postgres ${dumpall} > ${dumpPath}";

      paths = [ dumpPath ];
    };
}
