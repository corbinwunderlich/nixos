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

      plugins = with pkgs.tmuxPlugins; [
        sensible
        better-mouse-mode

        {
          plugin = resurrect;
          extraConfig = ''
            resurrect_dir="$HOME/.tmux/resurrect"
            set -g @resurrect-dir $resurrect_dir
            set -g @resurrect-hook-post-save-all "sed -i 's/--cmd lua.*--cmd set packpath/--cmd \"lua/g; s/--cmd set rtp.*\$/\"/' $resurrect_dir/last"
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-processes '"~nvim"'
          '';
        }
      ];

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

        set -g status-right "@#H - #(pwd)"
        set -g status-left "#S"
        set -g status-left-length 100
        set -g status-justify centre
        set -g window-status-format "#[fg=#ffffff]#I: #W"
        set -g window-status-current-format "#[fg=blue,bold]#I: #W"

        set-option -g status-position top

        set-option -g display-time 2000
        set-option -g message-style "bg=#000000,fg=yellow"
      '';
    };

    programs.sesh = {
      enable = true;
      tmuxKey = "T";
      icons = false;
    };

    programs.fzf = {
      enable = true;

      enableZshIntegration = true;

      tmux.enableShellIntegration = true;
    };

    systemd.user.services.tmux = {
      Unit = {
        Description = "tmux default session (detached)";
        Documentation = "man:tmux(1)";
      };

      Service = {
        Environment = [
          "DISPLAY=:0"
          "PATH=${lib.makeBinPath (with pkgs; [coreutils tmux hostname gnused gnutar gzip gawk gnugrep diffutils] ++ config.home.packages ++ ["/run/current-system/sw" "/home/corbin/.nix-profile/bin"])}:$PATH"
          "TMUX=/run/user/1000/tmux-1000/default"
        ];

        Type = "forking";

        ExecStart = "${pkgs.tmux}/bin/tmux -S /run/user/1000/tmux-1000/default new-session -s 0 -d";
        ExecStartPost = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh";
        ExecStop = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh";
        ExecStopPost = "${pkgs.tmux}/bin/tmux kill-server";

        WorkingDirectory = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts";

        RestartSec = 2;
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.services.tmux-autosave = {
      Unit = {
        Description = "Run tmux_resurrect save script every 5 minutes";
        OnFailure = "error@%n.service";
        After = ["tmux.service"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh";
      };
    };

    systemd.user.timers.tmux-autosave = {
      Unit = {
        Description = "Run tmux_resurrect save script every 5 minutes";
      };

      Timer = {
        OnBootSec = "5min";
        OnUnitActiveSec = "5min";
        Unit = "tmux-autosave.service";
      };

      Install = {
        WantedBy = ["timers.target"];
      };
    };
  };
}
