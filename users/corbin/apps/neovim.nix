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

        ExecStart = let
          script = pkgs.writeShellScriptBin "opencode-config" ''
            mkdir -p /home/corbin/.config/opencode

            if [ -f "/home/corbin/.config/opencode/opencode.json" ]; then rm /home/corbin/.config/opencode/opencode.json; fi

            url="$(cat ${config.sops.secrets."ollama/url".path})"

            cat <<EOL >> /home/corbin/.config/opencode/opencode.json
            {
              "provider": {
                "ollama": {
                  "npm": "@ai-sdk/openai-compatible",
                  "name": "Ollama",
                  "options": {
                    "baseURL": "$url/v1"
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
