{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.passwordmanager.enable = lib.mkEnableOption "Enables 1password";

  imports = [inputs._1password-shell-plugins.hmModules.default];

  config = lib.mkIf config.passwordmanager.enable {
    programs._1password-shell-plugins = {
      enable = true;

      plugins = with pkgs; [gh awscli2 cachix];
    };

    programs.ssh = {
      enable = true;

      extraConfig = ''
        IdentityAgent ~/.1password/agent.sock

        Match Originalhost siarnaq Exec "host siarnaq.ridgewood"
          HostName siarnaq.ridgewood
          ProxyJump none
        Host siarnaq
          User corbin
          HostName ridgewood.wcopy.net
          ProxyJump ampere
          SetEnv TERM=xterm-256color
      '';

      matchBlocks = {
        "instance-1.wcopy.net" = {
          hostname = "instance-1.wcopy.net";
          user = "opc";
        };

        "tethys" = {
          hostname = "tethys.ridgewood";
          user = "root";
        };

        "nixpi*" = {
          user = "root";
        };
      };

      forwardAgent = true;
    };

    xdg.configFile."1Password/ssh/agent.toml".text = ''
      [[ssh-keys]]
      vault = "Private"

      [[ssh-keys]]
      vault = "Corbin"
    '';
  };
}
