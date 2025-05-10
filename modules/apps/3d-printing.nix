{
  config,
  lib,
  pkgs,
  ...
}: {
  options.bambu-studio.enable = lib.mkEnableOption "Enables Bambu Studio slicer and other 3d printing utilities";

  config = lib.mkIf config.bambu-studio.enable {
    environment.systemPackages = with pkgs; [
      (runCommand "orca-slicer" {nativeBuildInputs = [pkgs.makeWrapper];} ''
        mkdir -p $out/bin

        cp ${pkgs.orca-slicer}/bin/orca-slicer $out/bin/orca-slicer

        wrapProgram $out/bin/orca-slicer --set GDK_DPI_SCALE 1.25

        mkdir -p $out/share

        cp -r ${pkgs.orca-slicer}/share/* $out/share
      '')
    ];
  };
}
