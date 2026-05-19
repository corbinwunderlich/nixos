{
  config,
  lib,
  ...
}: {
  options.passwordmanager.enable = lib.mkEnableOption "Enables 1password";

  config = lib.mkIf config.passwordmanager.enable {
    nixpkgs.overlays = [
      (final: prev: {
        _1password-cli = prev.unstable._1password-cli;
        _1password-gui = prev.unstable._1password-gui;
      })
    ];

    programs._1password.enable = true;

    programs._1password-gui = {
      enable = true;

      polkitPolicyOwners = ["corbin"];
    };

    environment.etc."1password/custom_allowed_browsers" = {
      text = "firefox";
      mode = "0755";
    };
  };
}
