{
  config,
  lib,
  pkgs,
  ...
}: {
  options.pulseaudio.enable = lib.mkEnableOption "Enables PulseAudio";

  config = lib.mkIf config.pulseaudio.enable {
    services.pipewire.enable = false;

    services.pulseaudio = {
      enable = true;
      support32Bit = true;
    };

    environment.systemPackages = with pkgs; [pavucontrol];
  };
}
