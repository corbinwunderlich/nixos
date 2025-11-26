{
  pkgs,
  lib,
  config,
  ...
}: {
  options.nu.enable = lib.mkEnableOption "Enables nushell";

  config = lib.mkIf config.nu.enable {
    home.packages = with pkgs; [
      fd
      bat
      xh
      dust
      delta
      fzf
    ];

    programs.nushell = let
      nu_scripts = pkgs.fetchFromGitHub {
        owner = "nushell";
        repo = "nu_scripts";
        rev = "ff8092707054ad091d67bd408374a39977e33c1b";
        hash = "sha256-oxnXzxQkNccCs36j+aMzg4QGHDcX7niJruqxCkeg0LM=";
      };
    in {
      enable = true;

      settings = {
        show_banner = false;
        table.mode = "rounded";

        edit_mode = "vi";
      };

      envFile.text = ''
        $env.PROMPT_COMMAND = {
            let cwd = (pwd | str replace $env.HOME "~")

            let time = $env.CMD_DURATION_MS
            let elapsed = if ($time | is-not-empty) {
                $"($time) ms"
            } else {
                "init"
            }

            $"(ansi "#ffffff")($cwd) after ($elapsed)\n(ansi reset)" |
        }

        $env.PROMPT_COMMAND_RIGHT = {||}

        $env.PROMPT_INDICATOR_VI_INSERT = $"(ansi "#ffffff")❯ (ansi reset)(ansi -e '4 q')"
        $env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi "#ffffff"): (ansi reset)(ansi -e '2 q')"
        $env.PROMPT_MULTILINE_INDICATOR = $"(ansi "#ffffff")::: (ansi reset)"
      '';

      configFile.text = ''
        use ${nu_scripts}/themes/nu-themes/tokyo-night.nu
        tokyo-night set color_config
      '';

      shellAliases = {
        ll = "ls -l";
        l = "ls -la";
        grim = "grimblast";
        svim = "sudo -Es nvim";

        cat = "bat";
        du = "dust";

        sudo = "/run/wrappers/bin/sudo";
      };
    };

    programs.carapace.enable = true;

    programs.direnv.enableNushellIntegration = true;

    programs.ghostty.settings.command = lib.mkForce "${pkgs.nushell}/bin/nu";
    programs.tmux.shell = lib.mkForce "${pkgs.nushell}/bin/nu";
  };
}
