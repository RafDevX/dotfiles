{
  config,
  secrets,
  lib,
  ...
}:

{
  rso.mailserver = {
    enable = true;
    primaryUsername = lib.mkDefault "raf";
    primaryPasswordFile = config.age.secrets.mailAccountPassword.path;
    primaryDomain = lib.mkDefault config.networking.hostName;

    # obfuscate a little to try to bypass crawlers
    forwardToExternal = lib.mkDefault (
      lib.concatStringsSep "" (
        lib.reverseList [
          "om"
          ".c"
          "il"
          "ma"
          "@g"
          ".x"
          "ev"
          "fd"
          "ra"
        ]
      )
    );
  };

  age.secrets = {
    mailAccountPassword.file = secrets.host.mailAccountPassword;
  };
}
