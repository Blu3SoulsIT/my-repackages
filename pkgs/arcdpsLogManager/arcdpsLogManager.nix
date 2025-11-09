{
  lib,
  buildDotnetModule,
  fetchFromGitHub,

  dotnetCorePackages,

  wrapGAppsHook3,
  openssl,
  krb5,
  icu,
  gtk3,
  libnotify,
}: 
let
  name = "arcdpsLogManager";
  version = "1.14.1";
  sha256 = "sha256-LvqUuSBrDbkmAJgL7fteUlCtQs27h8+8gqg1k2SgFWE=";
in
buildDotnetModule rec {
  pname = name;
  inherit version;
  src = fetchFromGitHub {
    owner = "gw2scratch";
    repo = "evtc";
    tag = "manager-v${version}";
    inherit sha256;
  };

  nugetDeps = ./deps.json;

  projectFile = "ArcdpsLogManager.Gtk/ArcdpsLogManager.Gtk.csproj";

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  buildInputs = [
    openssl
    krb5
    icu
  ];

  runtimeDeps = [
    gtk3
    libnotify
  ];

  meta = with lib; {
    description = "A manager for Guild Wars 2 log files.";
    longDescription = ''
      A manager for all your recorded logs. Filter logs, upload them with one click, find interesting statistics. 
    '';
    homepage = "https://gw2scratch.com/tools/manager";

    mainProgram = "GW2Scratch.ArcdpsLogManager.Gtk";
  };
}
