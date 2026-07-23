{
  stdenv,
  fetchFromGitHub,
  pkg-config,
  sw,
  systemd,
  resvg,
  freetype,
  harfbuzz,
  wayland,
  libxkbcommon,
  fontconfig,
  wayland-protocols,
}:
stdenv.mkDerivation rec {
  pname = "sw_swaybar";
  version = "fe226c9de2c5034eb13aa0d76ecf73d81fabdec0";

  src = fetchFromGitHub {
    owner = "pd2s";
    repo = "sw";
    rev = version;
    hash = "sha256-uWKJfJXVfUQrdThnBURloTLDQpn138wpIOHXKQg2E7c=";
  };

  sourceRoot = "/build/source/examples/sw_swaybar";

  nativeBuildInputs = [pkg-config];

  buildInputs = [
    sw
    systemd
    freetype
    harfbuzz
    resvg
    wayland
    libxkbcommon
    fontconfig
    wayland-protocols
  ];

  NIX_CFLAGS_COMPILE = "-I${fontconfig.dev}/include/fontconfig";
  NIX_LDFLAGS = "-lfreetype -lwayland-client -lresvg -lharfbuzz";

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin

    chmod -R +w .
    ./build.sh .

    cp -ar sw_swaybar $out/bin

    runHook postBuild
  '';
}
