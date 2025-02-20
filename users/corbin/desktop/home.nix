{...}: {
  imports = [../modules.nix];

  home = {
    username = "corbin";
    homeDirectory = "/home/corbin";

    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
