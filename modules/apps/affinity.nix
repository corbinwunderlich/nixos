{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.affinity.enable = lib.mkEnableOption "Enables Affinity Photo and Designer";

  config = lib.mkIf config.affinity.enable {
    nixpkgs.overlays = [inputs.affinity-nix.overlays.default];

    environment.systemPackages = with pkgs; [
      affinity-photo
      affinity-designer
    ];

    nix.settings = {
      extra-substituters = ["https://cache.forall.systems"];
      extra-trusted-public-keys = [
        "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
      ];
    };
  };
}
