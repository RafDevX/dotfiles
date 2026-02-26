{
  config,
  lib,
  ...
}:

{
  rso.mailserver = {
    enable = true;
    primaryUsername = lib.mkDefault "raf";
    primaryPasswordHash = lib.mkDefault "$2b$05$O1r4Q3k6127a6JC55GJAMez3jTnK/kzOquRbPsyBhrT3VyqvW6YVa";
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
          "so"
          "+r"
          ".x"
          "ev"
          "fd"
          "ra"
        ]
      )
    );
  };
}
