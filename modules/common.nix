{
  pkgs,
  inputs,
  ...
}: {
  environment.shells = with pkgs; [zsh];
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [wget inputs.nixvim.packages.x86_64-linux.default git lazygit htop btop unzip python3];
  programs.nix-ld.enable = true;

  nix.settings.substituters = ["https://cache.garnix.io"];
  nix.settings.trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];

  nix.settings.trusted-users = ["@wheel root"];

  networking.firewall.allowedTCPPorts = [8080];
}
