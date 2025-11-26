{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.neovim.enable = lib.mkEnableOption "Enables Neovim";

  config = lib.mkIf config.neovim.enable {
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "/home/corbin/.config/sops/age/keys.txt";

      secrets = {
        "ollama/url" = {
          mode = "666";
        };

        "ollama/key" = {
          mode = "666";
        };
      };
    };

    systemd.user.services."opencode-config" = {
      Service = {
        WorkingDirectory = "/home/corbin";

        Type = "oneshot";

        Environment = "PATH=${pkgs.coreutils-full}/bin";

        ExecStart = let
          script = pkgs.writeShellScriptBin "opencode-config" ''
            mkdir -p /home/corbin/.config/opencode

            if [ -f "/home/corbin/.config/opencode/opencode.json" ]; then rm /home/corbin/.config/opencode/opencode.json; fi

            url="$(cat ${config.sops.secrets."ollama/url".path})"
            key="$(cat ${config.sops.secrets."ollama/key".path})"

            cat <<EOL >> /home/corbin/.config/opencode/opencode.json
            {
              "provider": {
                "ollama": {
                  "npm": "@ai-sdk/openai-compatible",
                  "name": "Ollama",
                  "options": {
                    "baseURL": "$url/v1",
                    "headers": {
                      "Authorization": "Bearer $key"
                    }
                  },
                  "models": {
                    "gpt-oss:20b": {
                      "name": "GPT OSS 20b"
                    },
                    "qwen3-coder:30b": {
                      "name": "Qwen Coder 30b"
                    }
                  }
                }
              }
            }
            EOL
          '';
        in "${script}/bin/opencode-config";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    programs.bash.bashrcExtra = ''
      export OLLAMA_API_KEY="$(cat ${config.sops.secrets."ollama/key".path})"
    '';

    programs.zsh.initContent = ''
      export OLLAMA_API_KEY="$(cat ${config.sops.secrets."ollama/key".path})"
    '';

    programs.nushell.extraEnv = ''
      $env.OLLAMA_API_KEY = (cat ${config.sops.secrets."ollama/key".path})
    '';

    home.sessionVariables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
    };

    home.packages = with pkgs; [
      alejandra
      ripgrep
      fzf
      inputs.nixvim.packages.x86_64-linux.default
      opencode
    ];
  };
}
