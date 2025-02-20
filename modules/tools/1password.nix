{
  config,
  lib,
  machine,
  ...
}: {
  options.passwordmanager.enable = lib.mkEnableOption "Enables 1password";

  config = lib.mkIf config.passwordmanager.enable {
    nixpkgs.overlays = [
      (final: prev: {
        _1password-gui = prev._1password-gui.overrideAttrs (_old: {
          postFixup =
            if config.programs.hyprland.enable
            then ''
              wrapProgram $out/bin/1password \
                --set ELECTRON_OZONE_PLATFORM_HINT x11 \
                --set GDK_DPI_SCALE 1.5
            ''
            else "";
        });
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
