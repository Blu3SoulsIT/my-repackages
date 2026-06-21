{
  lib,
  stdenvNoCC,
  fetchurl,
  writeShellApplication,
  nix-update,
  curl,
  jq,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gwtoolbox";
  version = "8.28_Release";

  src = fetchurl {
    url = "https://github.com/gwdevhub/GWToolboxpp/releases/download/${finalAttrs.version}/GWToolbox.exe";
    hash = "sha256-umn5koacchuuxbwx5tSG1Xbo91du4Adr0Yjr+HX9Cy4=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/GWToolbox.exe

    runHook postInstall
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-${finalAttrs.pname}";
    runtimeInputs = [
      nix-update
      curl
      jq
    ];
    text = ''
      echo "Checking GitHub for the latest release containing GWToolbox.exe..."

      TARGET_VERSION=$(curl -s "https://api.github.com/repos/gwdevhub/GWToolboxpp/releases" | jq -r 'map(select(.assets[].name == "GWToolbox.exe")) | .[0].tag_name')

      if [ -z "$TARGET_VERSION" ] || [ "$TARGET_VERSION" == "null" ]; then
        echo "Error: Failed to find a valid release with GWToolbox.exe from GitHub API."
        exit 1
      fi

      echo "Found target version: $TARGET_VERSION"
      nix-update ${finalAttrs.pname} --flake
    '';
  };

  meta = with lib; {
    description = "GWToolbox launcher executable";
    homepage = "https://github.com/gwdevhub/GWToolboxpp";
    platforms = platforms.all;
  };
})
