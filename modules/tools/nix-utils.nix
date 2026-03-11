{
  config,
  lib,
  inputs,
  ...
}: {
  options.nix-utils.enable = lib.mkEnableOption "Enables Nix Utils";

  config = lib.mkIf config.nix-utils.enable {
    programs.nix-index-database.comma.enable = true;

    programs.nix-ld.enable = true;

    nix.settings = {
      trusted-users = ["@wheel root"];

      substituters = ["https://cache.garnix.io" "https://attic.xuyh0120.win/lantian"];
      trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
    };

    nixpkgs.overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.system;
          config.allowUnfree = true;
        };
      })
    ];

    environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  };
}
