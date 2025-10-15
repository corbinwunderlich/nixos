{
  pkgs,
  lib,
  config,
  ...
}: let
  zshrc = ''
    bindkey "''${key[Up]}" up-line-or-search
    PROMPT="%~ at %T"$'\n'"❯ "

    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE

    export PAGER=bat

    eval "$(direnv hook zsh)"
  '';
in {
  options.zsh.enable = lib.mkEnableOption "Enables ZSH";

  config = lib.mkIf config.zsh.enable {
    home.packages = with pkgs; [
      fd
      bat
      eza
      xh
      dust
      delta
    ];

    programs.zsh = {
      enable = true;

      enableCompletion = false;
      autosuggestion.enable = true;

      shellAliases = {
        ll = "eza -l";
        grim = "grimblast";
        svim = "sudo -Es nvim";

        cat = "bat";
        ls = "eza";
        du = "dust";
      };

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      plugins = [
        {
          name = "zsh-autocomplete";
          src = pkgs.zsh-autocomplete;
          file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
        }
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh";
        }
        {
          name = "zsh-vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      initContent = zshrc;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.git = {
      enable = true;
      delta.enable = true;
    };
  };
}
