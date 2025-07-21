{...}: {
  imports = [../modules.nix];

  sway.enable = true;
  hyprland.enable = false;

  home = {
    username = "corbin";
    homeDirectory = "/home/corbin";

    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
