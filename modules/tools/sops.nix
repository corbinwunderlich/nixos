{
  config,
  lib,
  inputs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  options.sops.enable = lib.mkEnableOption "Enables SOPS";

  config = lib.mkIf config.sops.enable {
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "/home/corbin/.config/sops/age/keys.txt";

      secrets = {
        "samba/username" = {
          owner = "samba-credentials";
        };
        "samba/password" = {
          owner = "samba-credentials";
        };
      };
    };

    systemd.services."samba-credentials" = {
      enable = true;

      script = ''
        echo "username=$(cat ${config.sops.secrets."samba/username".path})
        password=$(cat ${
          config.sops.secrets."samba/password".path
        })" > /var/lib/samba-credentials/samba-credentials
      '';

      serviceConfig = {
        User = "samba-credentials";
        WorkingDirectory = "/var/lib/samba-credentials";
      };
    };

    users.users.samba-credentials = {
      home = "/var/lib/samba-credentials";
      createHome = true;
      isSystemUser = true;
      group = "samba-credentials";
    };

    users.groups.samba-credentials = {};
  };
}
