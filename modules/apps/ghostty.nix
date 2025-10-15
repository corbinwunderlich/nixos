{
  config,
  pkgs,
  lib,
  ...
}: {
  options.ghostty.enable =
    lib.mkEnableOption "Enables the Ghostty terminal emulator";

  config = lib.mkIf config.ghostty.enable {
    fonts.packages = with pkgs; [nerd-fonts.jetbrains-mono];

    environment.systemPackages = [pkgs.ghostty];

    environment.sessionVariables = {
      GLFW_IM_MODULE = "ibus";
    };
  };
}
