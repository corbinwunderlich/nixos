{
  config,
  lib,
  pkgs,
  ...
}: let
  pycuda = pkgs.python312Packages.pycuda.overrideAttrs (old: rec {
    pname = "pycuda";
    version = "2025.1";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-UnOOmpQcKVwKXfaqDUmsifZtg12szpyci4TnUw/kYi8=";
    };
  });

  xpra-html5 = pkgs.callPackage ./xpra-html5.nix {};

  nvHeaders = pkgs.runCommand "nv-headers" {} ''
    mkdir -p $out/include $out/lib/pkgconfig
    substituteAll ${pkgs.cudaPackages.libnvjpeg.dev}/share/pkgconfig/nvjpeg.pc $out/lib/pkgconfig/nvjpeg.pc
    substituteAll ${pkgs.nv-codec-headers-12}/lib/pkgconfig/ffnvcodec.pc $out/lib/pkgconfig/nvenc.pc
    substituteAll ${pkgs.cudaPackages.cudatoolkit}/share/pkgconfig/cuda.pc $out/lib/pkgconfig/cuda.pc
    cp ${pkgs.nv-codec-headers-12}/include/ffnvcodec/nvEncodeAPI.h $out/include
  '';

  xpraOverride = pkgs.xpra.overrideAttrs (oldAttrs: {
    #postPatch = oldAttrs.postPatch + "\n patchShebangs --build fs/bin/build_cuda_kernels.py";

    #stdenv = pkgs.cudaPackages.backendStdenv;

    #setupPyBuildFlags = oldAttrs.setupPyBuildFlags ++ ["--with-nvjpeg_encoder"];

    nativeBuildInputs = (lib.remove pkgs.clang oldAttrs.nativeBuildInputs) ++ [pkgs.cudaPackages.cuda_nvcc];

    #propagatedBuildInputs = lib.remove (builtins.elemAt oldAttrs.propagatedBuildInputs 21) oldAttrs.propagatedBuildInputs ++ [pkgs.python312Packages.pyopengl-accelerate pkgs.python312Packages.aioquic pkgs.python312Packages.uvloop pkgs.python312Packages.pyopenssl pkgs.gst_all_1.gst-vaapi pkgs.gst_all_1.gst-plugins-ugly pycuda];
    #propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [pkgs.libGL];

    #buildInputs = lib.remove (lib.last oldAttrs.buildInputs) oldAttrs.buildInputs ++ [pkgs.clang nvHeaders pkgs.libyuv pkgs.libavif pkgs.libspng pkgs.openh264 pkgs.python312Packages.aioquic pkgs.python312Packages.uvloop pkgs.python312Packages.pyopenssl pkgs.gst_all_1.gst-vaapi pkgs.gst_all_1.gst-plugins-ugly];
    #nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pkgs.clang pkgs.python312Packages.pyopenssl];

    postInstall = oldAttrs.postInstall + "\n mkdir -p $out/share/www" + "\n cp -r ${xpra-html5}/* $out/share/www/";
  });

  xpra = xpraOverride.override {
    nvidia_x11 = config.hardware.nvidia.package;
    nv-codec-headers-10 = pkgs.nv-codec-headers-12;
    withNvenc = true;
    withHtml = false;
  };

  xpraWestonXvfb = pkgs.writeShellScriptBin "xpra_weston_xvfb" ''
    unset DISPLAY
    export WAYLAND_DISPLAY=headless-$$
    ${pkgs.westonLite}/bin/weston --backend=headless --socket=$WAYLAND_DISPLAY --renderer=gl -- ${pkgs.xwayland}/bin/Xwayland -noreset $@
  '';
in {
  options.xrdp.enable = lib.mkEnableOption "Enables xrdp";

  config = lib.mkIf config.xrdp.enable {
    environment.systemPackages = [xpra xpra-html5 xpraWestonXvfb];

    security.polkit.enable = true;

    hardware.uinput.enable = true;

    boot.kernelModules = ["v4l2loopback"];

    systemd.services."xpra" = {
      enable = true;

      wantedBy = ["multi-user.target" "default.target"];
      after = ["graphical.target" "display-manager.service"];

      path = with pkgs; [bash util-linux] ++ [xpra];
      environment.DISPLAY = ":1";
      environment.LD_LIBRARY_PATH = "${pkgs.libGL}/lib";

      serviceConfig = {
        User = "corbin";
        WorkingDirectory = "/home/corbin";
        Restart = "on-failure";
      };

      script = ''
        xpra start-desktop --use-display :0 --daemon=no --pulseaudio=no --mdns=no --speaker=yes --sound-source=pulse  --html=${xpra-html5.out} --bind-wss=0.0.0.0:14500,auth=file,filename=/home/corbin/password.txt --video-encoders=nvjpeg,jpeg --ssl-key=/home/corbin/.xpra/cloudflare-key.pem --ssl-cert=/home/corbin/.xpra/cloudflare-cert.pem
      '';
    };
    users.users.corbin.linger = true;

    xdg.menus.enable = true;
  };
}
