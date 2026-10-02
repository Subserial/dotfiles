{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchurl,
  pkg-config,
  pipewire,
  wayland,
  libxkbcommon,
  vulkan-loader,
  libGL,
  fontconfig,
  freetype,
  makeWrapper,
  curl,
  python3,
  dbus,
}:

let
  skiaBinaries = fetchurl {
    url = "https://github.com/rust-skia/skia-binaries/releases/download/0.89.1/skia-binaries-b98dbc3ef012d6f67535-x86_64-unknown-linux-gnu-gl-pdf-textlayout-vulkan.tar.gz";
    hash = "sha256-aS0PRQ59ewqsCf+5+bZsD59KGUqLelK424HXBXfMCf8=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "beskope";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "jturcotte";
    repo = "beskope";
    rev = "df7642bdbb4a30b1a8a495cca726115885d3c43b";
    hash = "sha256-t7XtYcz7mniQq2kQ8vwhm4zEEl0aWjmRiCguRCXYW9c=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "qdft-0.1.0" = "sha256-GU8Sz7NldYJk2CYDfrYcQJnmIL2CTukdCF8/SwOeBlU=";
      "slint-1.14.1" = "sha256-vl4QbmXrhcLrzHPDWQ2iDuOX/sJIWnHaluX4o6H8CcQ=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
    curl
    python3
  ];

  buildInputs = [
    pipewire
    wayland
    libxkbcommon
    vulkan-loader
    libGL
    fontconfig
    freetype
    dbus
  ];

  env = {
    SKIA_BINARIES_URL = "file://${skiaBinaries}";
  };

  postInstall = ''
    wrapProgram $out/bin/beskope \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          vulkan-loader
          libGL
          wayland
          libxkbcommon
        ]
      }
  '';

  meta = with lib; {
    description = "A desktop waveform visualizer for Wayland and PipeWire";
    homepage = "https://github.com/jturcotte/beskope";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "beskope";
  };
}
