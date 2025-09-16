{ config, secrets, ... }:

{
  age.secrets = {
    resticRepoPassword.file = secrets.host.resticRepoPassword;
    resticBackblazeCreds.file = secrets.host.resticBackblazeCreds;
  };

  rso.restic = {
    passwordFile = config.age.secrets.resticRepoPassword.path;

    targets.backblaze = {
      # note that backblaze's S3-compatible API doesn't work with restic init
      # for some reason, so we use the native B2 API
      repository = "b2:rso-restic-${config.networking.hostName}";

      # create a key with capabilities
      # CAPS = `listBuckets,listFiles,readFiles,writeFiles`, using command
      # `b2 key create nixos-restic-HOST CAPS --bucket rso-restic-HOST`.
      # then create a secret with `B2_ACCOUNT_ID` and `B2_ACCOUNT_KEY`
      credentialsEnvFile = config.age.secrets.resticBackblazeCreds.path;
    };
  };
}
