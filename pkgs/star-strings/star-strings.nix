{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writeShellApplication,
  nix-update,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "star-strings";
  version = "latest-unstable-2026-11-12";

  src = fetchFromGitHub {
    owner = "MrKraken";
    repo = "StarStrings";
    rev = "2c6c06fa52299f0a8dc48cd4fffd2d49d927392c";
    hash = "sha256-qGPwIwCfp2ENK5U4ehhBkWQjbY1ihC3+a4UIMhIjS3U=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp src/For_Players/Data/Localization/english/global.ini $out/global.ini

    runHook postInstall
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-${finalAttrs.pname}";
    runtimeInputs = [ nix-update ];
    text = ''
      nix-update ${finalAttrs.pname} --flake --version=branch
    '';
  };

  meta = with lib; {
    description = "Star Citizen Localization Strings";
    homepage = "https://github.com/MrKraken/StarStrings";
    platforms = platforms.all;
  };
})
