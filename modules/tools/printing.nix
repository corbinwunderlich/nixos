{
  config,
  lib,
  pkgs,
  ...
}: {
  options.printing.enable = lib.mkEnableOption "Enables printing";

  config = lib.mkIf config.printing.enable {
    nixpkgs.config.allowUnfree = true;

    services.printing.enable = true;

    services.printing.drivers = with pkgs; [hplip];

    hardware.printers = {
      ensurePrinters = [
        {
          name = "HP_7855";
          location = "Home";
          deviceUri = "ipp://printer.local.";
          model = "HP/hp-envy_photo_7800_series.ppd.gz";
          ppdOptions.pageSize = "Letter";
        }
      ];

      ensureDefaultPrinter = "HP_7855";
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
