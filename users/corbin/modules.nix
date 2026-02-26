{
  lib,
  config,
  ...
}: {
  imports = [
    ./apps/1password.nix
    ./apps/ghostty.nix
    ./apps/neovim.nix
    ./apps/game-mods.nix
    ./apps/affinity.nix

    ./tools/zsh.nix
    ./tools/fcitx.nix
    ./tools/direnv.nix
    ./tools/rclone.nix
    ./tools/tmux.nix
    ./tools/nushell.nix

    ./wms/i3.nix
    ./wms/sway.nix
    ./wms/hyprland.nix
    ./wms/hyprlock.nix
    ./wms/hyprpaper.nix
    ./wms/widgets/ags.nix
    ./wms/widgets/dunst.nix

    ./common.nix
  ];

  passwordmanager.enable = lib.mkDefault true;
  ghostty.enable = lib.mkDefault true;
  neovim.enable = lib.mkDefault true;
  mods.enable = lib.mkDefault true;
  affinity.enable = lib.mkDefault true;

  zsh.enable = lib.mkDefault true;
  fcitx.enable = lib.mkDefault true;
  rclone.enable = lib.mkDefault false;
  tmux.enable = lib.mkDefault true;
  nu.enable = lib.mkDefault true;

  hyprland.enable = lib.mkDefault false;
  hyprlock.enable = lib.mkDefault config.hyprland.enable;
  hyprpaper.enable = lib.mkDefault config.hyprland.enable;
  sway.enable = lib.mkDefault true;
  i3.enable = lib.mkDefault false;
  ags.enable = lib.mkDefault config.hyprland.enable;
  dunst.enable = lib.mkDefault true;
}
