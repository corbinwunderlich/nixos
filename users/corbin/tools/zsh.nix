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

    if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
      sesh connect \"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙<fe0f>  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
      )\"
    fi
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
      fzf
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
