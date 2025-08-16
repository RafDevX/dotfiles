{ config, secrets, ... }:

{
  age.secrets = {
    resticRepoPassword.file = secrets.host.resticRepoPassword;
    resticBackblazeCreds.file = secrets.host.resticBackblazeCreds;
  };

  rso.restic = {
    passwordFile = config.age.secrets.resticRepoPassword.path;

    targets.backblaze = {
      repository = "s3:s3.eu-central-003.backblazeb2.com/rso-restic-${config.networking.hostName}";

      # create a key with:
      # `b2 key create X readBuckets,listFiles,readFiles,writeFiles --bucket Y`
      # then create a secret with `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY`
      credentialsEnvFile = config.age.secrets.resticBackblazeCreds.path;
    };
  };
}
