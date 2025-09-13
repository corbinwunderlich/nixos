{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    gh

    inputs.affinity-nix.packages.x86_64-linux.photo
    inputs.affinity-nix.packages.x86_64-linux.designer
  ];
}
