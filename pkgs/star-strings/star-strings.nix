{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writeShellApplication,
  nix-update,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "star-strings";
  version = "latest-unstable-2026-06-17";

  src = fetchFromGitHub {
    owner = "MrKraken";
    repo = "StarStrings";
    rev = "7caecaf10a013d8cd45c1c7fc4ddde78e3fc0490";
    hash = "sha256-AaMJO96/4UlK56v8hktrW+veJZQe+CvKhGCUyolbJrg=";
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
