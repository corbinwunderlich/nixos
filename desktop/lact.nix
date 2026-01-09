{pkgs, ...}: {
  hardware.amdgpu.overdrive = {
    enable = true;
    ppfeaturemask = "0xffff7fff";
  };

  hardware.graphics = {
    package = pkgs.unstable.mesa;
    package32 = pkgs.unstable.pkgsi686Linux.mesa;
  };

  boot.kernelParams = ["amdgpu.sg_display=0" "amdgpu.gfx_off=0" "amdgpu.runtime_pm=0" "amdgpu.gpu_recovery=1"];

  services.lact = {
    enable = true;

    settings = {
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
  };
}
