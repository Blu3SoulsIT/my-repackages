{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writeShellApplication,
  nix-update,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "star-strings";
  version = "0-unstable-2026-06-06";

  src = fetchFromGitHub {
    owner = "MrKraken";
    repo = "StarStrings";
    rev = "c3ab95cc48be01d6fd11cc026ffbb64134078a37";
    hash = "sha256-W6rMz8p64UwmbXyF4NekBrgKXY7rgMf2VWD5R3SrkfY=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp Data/Localization/english/global.ini $out/global.ini

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
