{
  config,
  lib,
  ...
}: {
  options.rclone.enable = lib.mkEnableOption "Enables rclone";

  config = lib.mkIf config.rclone.enable {
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "/home/corbin/.config/sops/age/keys.txt";

      secrets = {
        "siarnaq-dav/password" = {};
        "siarnaq-dav/url" = {};
      };
    };

    programs.rclone = {
      enable = true;

      remotes.siarnaq-dav = {
        config = {
          type = "webdav";
          pacer_min_sleep = "0.01ms";
          vendor = "owncloud";
          user = "k";
        };

        secrets = {
          url = config.sops.secrets."siarnaq-dav/url".path;
          pass = config.sops.secrets."siarnaq-dav/password".path;
        };
      };
    };
  };
}
