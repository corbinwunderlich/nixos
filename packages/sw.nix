{
  stdenv,
  fetchFromGitHub,
  pkg-config,
  openlibm,
  wayland-scanner,
  wayland-protocols,
  wayland,
  pixman,
  fcft,
  resvg,
}:
stdenv.mkDerivation rec {
  pname = "sw";
  version = "16540ec6c0be4301022f70e85799afb4f32736ec";

  src = fetchFromGitHub {
    owner = "pd2s";
    repo = "sw";
    rev = version;
    hash = "sha256-JlijxKJPojmeyq17reOG36V6I2qXnDoWzMxW6EwMlEI=";
  };

  nativeBuildInputs = [pkg-config];

  buildInputs = [
    openlibm
    wayland-scanner
    wayland-protocols
    wayland
    pixman
    fcft
  ];

  env.CFLAGS = "-D SW_WITH_SVG=0 -D SW_WITH_WAYLAND_BACKEND=1";

  buildPhase = ''
    mkdir -p $out/include
    mkdir -p $out/lib64
    mkdir -p $out/lib64/pkgconfig

    cd $src
    mkdir -p /build/include
    ln -s ${resvg}/include/resvg.h /build/include/resvg.h

    wayland-scanner private-code "${wayland-protocols}/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml" "/build/include/xdg-shell.c"
    wayland-scanner private-code "${wayland-protocols}/share/wayland-protocols/staging/cursor-shape/cursor-shape-v1.xml" "/build/include/cursor-shape-v1.c"
    wayland-scanner private-code "${wayland-protocols}/share/wayland-protocols/unstable/tablet/tablet-unstable-v2.xml" "/build/include/tablet-unstable-v2.c"
    wayland-scanner private-code "$src/wlr-layer-shell-unstable-v1.xml" "/build/include/wlr-layer-shell-unstable-v1.c"
    wayland-scanner private-code "${wayland-protocols}/share/wayland-protocols/unstable/xdg-decoration/xdg-decoration-unstable-v1.xml" "/build/include/xdg-decoration-unstable-v1.c"
    wayland-scanner client-header "${wayland-protocols}/share/wayland-protocols/staging/cursor-shape/cursor-shape-v1.xml" "/build/include/cursor-shape-v1.h"
    wayland-scanner client-header "${wayland-protocols}/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml" "/build/include/xdg-shell.h"
    wayland-scanner client-header "$src/wlr-layer-shell-unstable-v1.xml" "/build/include/wlr-layer-shell-unstable-v1.h"
    wayland-scanner client-header "${wayland-protocols}/share/wayland-protocols/unstable/xdg-decoration/xdg-decoration-unstable-v1.xml" "/build/include/xdg-decoration-unstable-v1.h"

    BUILD_PATH=/build HEADER_INSTALL_PATH=$out/include LIBRARY_INSTALL_PATH=$out/lib64 PKGCONFIG_INSTALL_PATH=$out/lib64/pkgconfig ./build.sh install

    cp /build/source/stb_sprintf.h $out/include
    cp /build/source/stb_image.h $out/include
    cp /build/include/xdg-decoration-unstable-v1.h $out/include
    cp /build/include/xdg-decoration-unstable-v1.c $out/include
    cp /build/include/wlr-layer-shell-unstable-v1.h $out/include
    cp /build/include/wlr-layer-shell-unstable-v1.c $out/include
    cp /build/include/cursor-shape-v1.h $out/include
    cp /build/include/cursor-shape-v1.c $out/include
    cp /build/include/xdg-shell.h $out/include
    cp /build/include/xdg-shell.c $out/include
    cp /build/include/tablet-unstable-v2.c $out/include
  '';
}
