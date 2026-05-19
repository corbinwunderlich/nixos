{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.passwordmanager.enable = lib.mkEnableOption "Enables 1password";

  imports = [inputs._1password-shell-plugins.hmModules.default];

  config = let
    forgejo-credential-1password = pkgs.writeShellScriptBin "forgejo-credential-1password" ''
      case "$1" in
        get)
          declare -A in
          while IFS='=' read -r k v; do [ -z "$k" ] && break; in[$k]=$v; done
          case "''${in[host]}" in
            git.wcopy.net)
              printf 'username=%s\npassword=%s\n' \
                "corbin" \
                "$(/run/wrappers/bin/op read 'op://Private/Forgejo API Key/credential')"
              ;;
          esac
          ;;
        store|erase) : ;;
      esac
    '';
  in
    lib.mkIf config.passwordmanager.enable {
      programs._1password-shell-plugins = {
        enable = true;

        plugins = with pkgs; [gh cachix];
      };

      programs.ssh = {
        enable = true;

        enableDefaultConfig = false;

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

          "idrac*" = {
            user = "root";
            setEnv.TERM = "xterm-256color";
          };

          "*" = {
            forwardAgent = true;
          };
        };
      };

      home.packages = [pkgs._1password-cli forgejo-credential-1password];

      programs.git.settings = {
        "credential \"https://git.wcopy.net\"" = {
          helper = ["" "!${forgejo-credential-1password}/bin/forgejo-credential-1password"];
        };
      };

      xdg.configFile."1Password/ssh/agent.toml".text = ''
        [[ssh-keys]]
        vault = "Private"

        [[ssh-keys]]
        vault = "Corbin"
      '';
    };
}
