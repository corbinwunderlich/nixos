{
  config,
  lib,
  pkgs,
  ...
}: {
  options.arduino.enable = lib.mkEnableOption "Enables arduino tools and kicad";

  config = lib.mkIf config.arduino.enable {
    kicad.enable = true;

    environment.systemPackages = with pkgs; [
      arduino-cli
      arduino-language-server

      (pkgs.python313Packages.buildPythonPackage rec {
        pyproject = true;

        pname = "stm32pio";
        version = "2.1.2";

        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-jiYWV9UMERWCUrBmnFPyoojCnD/7LTNcT3zavVECb+8=";
        };

        nativeBuildInputs = with pkgs.python313Packages; [setuptools setuptools-scm];
      })
    ];

    services.flatpak.enable = true;
    services.flatpak.packages = ["com.st.STM32CubeMX"];
  };
}
