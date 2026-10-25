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

      substituters = ["https://cache.lantian.pub/lantian"];
      trusted-public-keys = ["lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="];
    };

    nixpkgs.overlays = [
      (final: _: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
        };
      })
    ];

    environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  };
}
