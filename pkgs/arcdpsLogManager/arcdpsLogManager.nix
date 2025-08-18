{ pkgs }: 
let
  name = "arcdpsLogManager";
  version = "1.14.1";
  sha256 = "sha256-LvqUuSBrDbkmAJgL7fteUlCtQs27h8+8gqg1k2SgFWE=";
in
  pkgs.buildDotnetModule rec {
    pname = name;
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "gw2scratch";
      repo = "evtc";
      tag = "manager-v${version}";
      inherit sha256;
    };

    nugetDeps = ./deps.json;

    projectFile = "ArcdpsLogManager.Gtk/ArcdpsLogManager.Gtk.csproj";

    dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0;
    dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;

    buildInputs = with pkgs; [
      openssl
      krb5
      icu
    ];

    runtimeDeps = with pkgs; [
      gtk3
      libnotify
    ];
  }
