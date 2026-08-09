{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  webkitgtk_4_1,
  gtk3,
  glib,
  glib-networking,
  gst_all_1,
  writeShellApplication,
  nix-update,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nuclear";
  version = "1.46.1";

  src = fetchurl {
    url = "https://github.com/nukeop/nuclear/releases/download/player@${finalAttrs.version}/Nuclear_${finalAttrs.version}_amd64.deb";
    hash = "sha256-loTqy8QKXDr2UdUuolpehLzz0MWs4SqkMKlk6zX5URo=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    glib
    glib-networking
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/bin $out/
    cp -r usr/share $out/

    chmod +x $out/bin/nuclear-music-player

    runHook postInstall
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
    mainProgram = "nuclear-music-player";
  };
})
