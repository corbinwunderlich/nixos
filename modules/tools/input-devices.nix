{
  config,
  lib,
  pkgs,
  ...
}: {
  options.sayodevice.enable = lib.mkEnableOption "Enable configuration for the Sayodevice O3C v1";
  options.neo65.enable = lib.mkEnableOption "Enable the FN key for the Neo65";

  config.services.udev.packages = lib.mkIf config.sayodevice.enable [
    (pkgs.writeTextFile {
      name = "sayo-rules";

      text = ''
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="8089", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="8089", TAG+="uaccess"
      '';

      destination = "/etc/udev/rules.d/70-sayo.rules";
    })
  ];

  config.boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  config.users.users.corbin.extraGroups = ["input"];
}
