{
  pkgs,
  inputs,
  ...
}: {
  environment.shells = with pkgs; [zsh];
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [wget inputs.nixvim.packages.x86_64-linux.default git lazygit htop];
  programs.nix-ld.enable = true;
  nix.settings.trusted-users = ["@wheel root"];
}
