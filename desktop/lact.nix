{
  pkgs,
  lib,
  ...
}: {
  hardware.amdgpu.overdrive.enable = true;

  boot.kernelParams = ["amdgpu.sg_display=0"];

  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    after = ["multi-user.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    enable = true;
  };

  environment.etc."lact/config.yaml".text = (lib.generators.toYAML {}) {
    apply_settings_timer = 5;

    daemon = {
      log_level = "info";
      admin_groups = ["wheel" "sudo"];
      disable_clocks_cleanup = false;
    };

    gpus."1002:744C-1DA2:475E-0000:03:00.0" = {
      fan_control_enabled = false;
      power_cap = 280.0;
      performance_level = "high";
      voltage_offset = -30;
    };
  };

  environment.systemPackages = with pkgs; [
    lact
  ];
}
