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

    home.packages = with pkgs; [
      alejandra
      ripgrep
      fzf
      inputs.nixvim.packages.x86_64-linux.default
    ];
  };
}
