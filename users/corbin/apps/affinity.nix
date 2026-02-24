{
  lib,
  config,
  inputs,
  ...
}: {
  options.affinity.enable = lib.mkEnableOption "Enables Affinity Photo and Designer";

  config = lib.mkIf config.affinity.enable {
    home.packages = with inputs.affinity-nix.packages.x86_64-linux; [
      photo
      designer
    ];
  };
}
