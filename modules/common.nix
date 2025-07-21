{
  pkgs,
  inputs,
  ...
}: {
  environment.shells = with pkgs; [zsh];
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [wget inputs.nixvim.packages.x86_64-linux.default git lazygit htop btop unzip python3];
  programs.nix-ld.enable = true;

  nix.settings.trusted-users = ["@wheel root"];

  networking.firewall.allowedTCPPorts = [8080];
}
