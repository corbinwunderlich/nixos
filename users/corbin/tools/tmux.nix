{
  config,
  lib,
  pkgs,
  ...
}: {
  options.tmux.enable = lib.mkEnableOption "Enables rclone";

  config = lib.mkIf config.tmux.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "s" ''
        ${pkgs.tmux}/bin/tmux attach -t "$(${pkgs.sesh}/bin/sesh list | ${pkgs.fzf}/bin/fzf)"
      '')
    ];

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
        vim-tmux-navigator

        {
          plugin = resurrect;
          extraConfig = ''
            resurrect_dir="$HOME/.tmux/resurrect"
            set -g @resurrect-dir $resurrect_dir
            set -g @resurrect-strategy-nvim "session"
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-processes 'ssh sqlite3 mprocs nix litecli sudo nvim'
            set -g @resurrect-hook-post-save-all "sed -i 's| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g; s|/nix/store/.*/bin/||g' $(readlink -f $resurrect_dir/last)"
          '';
        }
      ];

      extraConfig = ''
        set -g allow-passthrough on

        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        bind-key x kill-pane
        set -g detach-on-destroy off

        set -g pane-active-border-style "fg=blue"

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
      enableAlias = false;
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
          "PATH=${lib.makeBinPath (with pkgs; [coreutils tmux hostname gnused gnutar gzip gawk gnugrep diffutils zsh zsh-completions] ++ config.home.packages ++ ["/run/current-system/sw" "/home/corbin/.nix-profile/bin"])}:$PATH"
          "TMUX=/run/user/1000/tmux-1000/default"
        ];

        Type = "forking";

        ExecStartPre = pkgs.writeShellScript "tmux-setup" ''
          export PATH=${lib.makeBinPath (with pkgs; [coreutils])}

          mkdir -p /run/user/1000/tmux-1000
          chmod 700 /run/user/1000/tmux-1000

          NEWEST_FILE=$(ls -1 /home/corbin/.tmux/resurrect/tmux_resurrect_*.txt 2>/dev/null |
            sort -V |
            tail -n 1)

          if [[ -z $NEWEST_FILE ]]; then
            echo "No tmux_resurrect files found" >&2
            exit 1
          fi

          if [[ ! -s $NEWEST_FILE ]]; then
            echo "''${NEWEST_FILE} is empty, deleting..."
            rm -f "$NEWEST_FILE"

            # Find the next newest file (if any)
            NEWEST_FILE=$(ls -1 "/home/corbin/.tmux/resurrect/tmux_resurrect_*.txt" 2>/dev/null |
              sort -V |
              tail -n 1)

            if [[ -z $NEWEST_FILE ]]; then
              echo "No non‑empty tmux_resurrect files left after deletion" >&2
              exit 1
            fi
          fi

          SYMLINK="/home/corbin/.tmux/resurrect/last"

          rm -f "$SYMLINK"

          ln -s "$(basename "$NEWEST_FILE")" "$SYMLINK"

          echo "last now points at ''${NEWEST_FILE}"
        '';
        ExecStart = "${pkgs.tmux}/bin/tmux -S /run/user/1000/tmux-1000/default new-session -s 0 -d";
        ExecStop = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh";
        ExecStopPost = "${pkgs.tmux}/bin/tmux kill-server";

        WorkingDirectory = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts";

        RestartSec = 2;
        Restart = "always";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.services.tmux-autosave = {
      Unit = {
        Description = "Run tmux_resurrect save script every 5 minutes";
        OnFailure = "error@%n.service";
        BindsTo = ["tmux.service"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh";
        ExecStartPost = pkgs.writeShellScript "tmux-resurrect-cleanup" ''
          NEWEST_FILE=$(ls -1 /home/corbin/.tmux/resurrect/tmux_resurrect_*.txt 2>/dev/null |
            sort -V |
            tail -n 1)

          if [[ -z $NEWEST_FILE ]]; then
            echo "No tmux_resurrect files found" >&2
            exit 1
          fi

          if [[ ! -s $NEWEST_FILE ]]; then
            echo "''${NEWEST_FILE} is empty, deleting..."
            rm -f "$NEWEST_FILE"

            # Find the next newest file (if any)
            NEWEST_FILE=$(ls -1 "/home/corbin/.tmux/resurrect/tmux_resurrect_*.txt" 2>/dev/null |
              sort -V |
              tail -n 1)

            if [[ -z $NEWEST_FILE ]]; then
              echo "No non‑empty tmux_resurrect files left after deletion" >&2
              exit 1
            fi
          fi

          SYMLINK="/home/corbin/.tmux/resurrect/last"

          rm -f "$SYMLINK"

          ln -s "$(basename "$NEWEST_FILE")" "$SYMLINK"

          echo "last now points at ''${NEWEST_FILE}"
        '';
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
