{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tmux.enable = lib.mkEnableOption "Enables rclone";

  config = lib.mkIf config.tmux.enable {
    programs.tmux = {
      enable = true;

      clock24 = true;

      keyMode = "vi";

      shell = "${pkgs.zsh}/bin/zsh";

      shortcut = "Space";

      mouse = true;

      plugins = with pkgs.tmuxPlugins;
        [
          sensible
        ]
        ++ (with pkgs; [
          {
            plugin = tmuxPlugins.resurrect;
            extraConfig = ''
              resurrect_dir="$HOME/.tmux/resurrect"
              set -g @resurrect-dir $resurrect_dir
              set -g @resurrect-hook-post-save-all "sed -i 's/--cmd lua.*--cmd set packpath/--cmd \"lua/g; s/--cmd set rtp.*\$/\"/' $resurrect_dir/last"
              set -g @resurrect-capture-pane-contents 'on'
              set -g @resurrect-processes '"~nvim"'
            '';
          }
        ]);

      extraConfig = ''
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        bind-key x kill-pane
        set -g detach-on-destroy off

        set -g status-bg "#000000"
        set -g status-fg "#ffffff"

        bind-key "T" run-shell "sesh connect \"$(
          sesh list --icons | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
          )\""
      '';
    };

    home.packages = with pkgs; [sesh];
  };
}
