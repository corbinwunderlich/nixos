{...}: {
  imports = [../modules.nix];

  hyprland.enable = false;
  hyprlock.enable = false;
  hyprpaper.enable = false;
  i3.enable = true;
  ags.enable = false;

  home = {
    username = "corbin";
    homeDirectory = "/home/corbin";

    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
