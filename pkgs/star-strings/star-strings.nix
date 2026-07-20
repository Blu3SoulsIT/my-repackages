{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writeShellApplication,
  nix-update,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "star-strings";
  version = "latest-unstable-2026-07-19";

  src = fetchFromGitHub {
    owner = "MrKraken";
    repo = "StarStrings";
    rev = "bfa25b827073aa4bcc879ecde3948e8508a1723b";
    hash = "sha256-+TLx7oXTde9ymrfg/61k8ZmwUOPEAaRKOZDxNnvA1Q0=";
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
