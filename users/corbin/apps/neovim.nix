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

    home.sessionVariables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
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

    home.packages = with pkgs; [
      alejandra
      ripgrep
      fzf
      inputs.nixvim.packages.x86_64-linux.default
    ];
  };
}
