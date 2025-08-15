{
  profiles,
  lib,
  ...
}:

{
  imports = with profiles; [
    services.ssh-server
    services.restic
  ];

  time.timeZone = lib.mkDefault "Europe/Lisbon";

  nix.settings = {
    # Don't add @wheel here, since it allows for privilege escalation
    # https://github.com/NixOS/nix/issues/9649#issuecomment-1868001568
    trusted-users = [ "root" ];
    trusted-public-keys = [
      "rotterdam:jRJCBUxAFAddxw2oJpd5QuXx+ikKWqCN3qOxKxI7540="
    ];
  };
}
