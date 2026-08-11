{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  buildFHSEnv,
  writeShellApplication,
  nix-update,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nuclear";
  version = "1.46.2";

  # nix-update can now easily find and update this!
  src = fetchurl {
    url = "https://github.com/nukeop/nuclear/releases/download/player@${finalAttrs.version}/nuclear_${finalAttrs.version}_amd64.deb";
    hash = "sha256-V/dkAQI0fY52orfenQj8eKpBcmPpJY+50AhH6qSZdSY=";
  };

  dontUnpack = true;
  dontBuild = true;

  # We define the inner components inside the installPhase
  installPhase =
    let

      # 1. Extract the .deb natively
      nuclear-extracted = stdenv.mkDerivation {
        name = "${finalAttrs.pname}-extracted-${finalAttrs.version}";
        inherit (finalAttrs) src;
        nativeBuildInputs = [ dpkg ];
        unpackPhase = "dpkg -x $src .";
        installPhase = ''
          mkdir -p $out
          cp -r usr/* $out/
          mv $out/bin/nuclear-music-player $out/bin/${finalAttrs.pname}
        '';
      };

      # 2. Build the pristine FHS sandbox
      fhs = buildFHSEnv {
        name = finalAttrs.pname;
        targetPkgs =
          pkgs: with pkgs; [
            nuclear-extracted

            gtk3
            webkitgtk_4_1
            glib
            glib-networking
            libsoup_3
            gdk-pixbuf
            cairo
            pango
            atk

            at-spi2-core
            at-spi2-atk
            dbus

            cacert
            openssl
            zlib

            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
            (gst_all_1.gst-plugins-good.override {
              qt5Support = false;
              qt6Support = false;
            })
            gst_all_1.gst-plugins-bad
            gst_all_1.gst-plugins-ugly
            gst_all_1.gst-libav
            alsa-lib
            libpulseaudio

            mesa
            libglvnd
            libGL
            vulkan-loader

            nss
            nspr
            systemd
            libX11
            libXcomposite
            libXdamage
            libXext
            libXfixes
            libXrandr
            libxcb
          ];

        profile = ''
          export WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1

          export GST_PLUGIN_SYSTEM_PATH_1_0=/usr/lib/gstreamer-1.0:/lib/gstreamer-1.0
          export GST_PLUGIN_PATH_1_0=/usr/lib/gstreamer-1.0:/lib/gstreamer-1.0

          export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
          export SSL_CERT_DIR=/etc/ssl/certs

          export GIO_EXTRA_MODULES=/usr/lib/gio/modules
          export GIO_MODULE_DIR=/usr/lib/gio/modules
        '';

        runScript = "nuclear";
      };

    in
    ''
      mkdir -p $out/bin $out/share/applications
      mkdir -p $out/bin $out/share/icons

      ln -s ${fhs}/bin/${finalAttrs.pname} $out/bin/${finalAttrs.pname}

      cp ${nuclear-extracted}/share/applications/*.desktop $out/share/applications/${finalAttrs.pname}.desktop
      cp -r ${nuclear-extracted}/share/icons $out/share/

      substituteInPlace $out/share/applications/${finalAttrs.pname}.desktop \
      --replace-warn 'Exec=nuclear-music-player' 'Exec=${finalAttrs.pname}' \
      --replace-warn 'Exec=nuclear' 'Exec=${finalAttrs.pname}'
    '';

  passthru.updateScript = writeShellApplication {
    name = "update-${finalAttrs.pname}";
    runtimeInputs = [ nix-update ];
    text = ''
      nix-update ${finalAttrs.pname} --flake --version-regex 'player@(.*)'
    '';
  };

  meta = with lib; {
    description = "Streaming music player that finds free music from alternative sources";
    homepage = "https://nuclearplayer.com/";
    license = licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = finalAttrs.pname;
  };
})
