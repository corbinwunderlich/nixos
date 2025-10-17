{
  config,
  lib,
  pkgs,
  ...
}: {
  options.rclone.enable = lib.mkEnableOption "Enables rclone";

  config = let
    rclone-project-script = pkgs.writeShellScriptBin "rclone-script" ''
      ${pkgs.rclone}/bin/rclone bisync siarnaq-dav:corbin/Projects ~/Projects --resync --recover
    '';
  in
    lib.mkIf config.rclone.enable {
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

      systemd.user.services."rclone-siarnaq-dav-corbin/projects" = {
        Service = {
          ExecStart = "${rclone-project-script}/bin/rclone-script";
          Restart = "always";
          RestartSec = 5;

          Environment = "RCLONE_CONFIG=${config.home.homeDirectory}/.config/rclone/rclone.conf";
        };

        Install = {
          WantedBy = ["default.target"];
        };
      };
    };
}
