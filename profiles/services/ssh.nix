# OpenSSH server
{ ... }:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwaEu0TGRXhxjk1+Pz2LP66Vfvvgr3IvxkRfkcRiP0Y raf@rotterdam"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJJWUTzd1uLY77F7ka6hLIygt1eocwrSLzQtZ9b6wRTf+6900Pfc2XyQvEMYjJd+ZqINbXN6mVnvlKtcaC6Nv2o= gazelle" # mobile
  ];
in
{
  services.openssh = {
    enable = true;

    # this makes it so that only the NixOS-managed keys (defined in the config
    # here, in this profile) are accepted, preventing an attacker from adding
    # unauthorized keys to ~/.ssh/authorized_keys since that file will no longer
    # be recognized; instead, root access is required to change any user's keys
    authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
