{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writeShellApplication,
  nix-update,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "star-strings";
  version = "latest-unstable-2026-10-09";

  src = fetchFromGitHub {
    owner = "MrKraken";
    repo = "StarStrings";
    rev = "292e6be75dff41e74180b35171fbb7af9b640509";
    hash = "sha256-DcbiiM0Qj7SKu1DVmNlc/lyVc0HLMYszJ25mLqwat7o=";
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
