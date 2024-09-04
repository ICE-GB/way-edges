{
  rustPlatform,
  lib,
  pkgs,
}: let
  cargoToml = builtins.fromTOML (builtins.readFile ../Cargo.toml);
  pname = cargoToml.package.name;
  version = cargoToml.package.version;
in
  rustPlatform.buildRustPackage {
    pname = pname;
    version = version;

    nativeBuildInputs = with pkgs; [
      git
      pkg-config
      cmake
      makeWrapper
      buildPackages.gtk4
    ];

    buildInputs = with pkgs;
      [
        xorg.libX11
        gtk4
        libadwaita
        xorg.libXtst
        gtk4-layer-shell.dev
        libpulseaudio
      ]
      ++ lib.optionals stdenv.isDarwin
      (with darwin.apple_sdk_11_0.frameworks; [
        CoreGraphics
        ApplicationServices
      ]);

    src = builtins.path {
      name = pname;
      path = lib.cleanSource ../.;
    };

    cargoLock.lockFile = ../Cargo.lock;

    # Set Environment Variables
    RUST_BACKTRACE = "full";

    # Needed to enable support for SVG icons in GTK
    postInstall = ''
      wrapProgram "$out/bin/way-edges" \
        --set GDK_PIXBUF_MODULE_FILE ${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache
    '';

    meta = with lib; {
      description = "hidden widget on screen edges";
      mainProgram = pname;
      platforms = platforms.all;
    };
  }
