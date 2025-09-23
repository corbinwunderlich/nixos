{
  stdenv,
  fetchFromGitHub,
  pkg-config,
  wayland-scanner,
  gnused,
  systemd,
  openlibm,
  wayland-protocols,
  wlroots,
  wayland,
  pixman,
  fcft,
  resvg,
  sw,
}:
stdenv.mkDerivation rec {
  pname = "sw_swaybar";
  version = "16540ec6c0be4301022f70e85799afb4f32736ec";

  src = fetchFromGitHub {
    owner = "pd2s";
    repo = "sw";
    rev = version;
    hash = "sha256-JlijxKJPojmeyq17reOG36V6I2qXnDoWzMxW6EwMlEI=";
  };

  nativeBuildInputs = [pkg-config wayland-scanner gnused];

  buildInputs = [
    systemd

    openlibm
    wayland-scanner
    wayland-protocols
    wlroots
    wayland
    pixman
    fcft

    resvg

    sw
  ];

  buildPhase = ''
    mkdir -p $out/bin

    cd $src/examples/sw_swaybar

    sed -E \
      -e 's|^ROOT_PATH=.*$|ROOT_PATH=$src/examples/sw_swaybar|' \
      -e 's|(\-o\s+)(\$\{ROOT_PATH\}/sw_swaybar)$|\1${"$out"}/bin/sw_swaybar|' \
      ./build.sh > /build/build.sh

    cat /build/build.sh
    chmod +x /build/build.sh
    CFLAGS="-lwayland-client -lpixman-1 -lfcft -lresvg" /build/build.sh
  '';
}
