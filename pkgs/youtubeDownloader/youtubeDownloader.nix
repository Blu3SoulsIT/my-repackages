{
  buildDotnetModule,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,

  dotnetCorePackages,

  ffmpeg,

  writeShellApplication,
  nix-update,
}:
buildDotnetModule (finalAttrs: {
  pname = "youtubeDownloader";
  version = "1.16.4";
  src = fetchFromGitHub {
    owner = "Tyrrrz";
    repo = "YoutubeDownloader";
    tag = finalAttrs.version;
    hash = "sha256-ILVOOcR+SFPGX5dOEcM8fYlpBnQCDC9E6GWUGw89Bhs=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  projectFile = "YoutubeDownloader/YoutubeDownloader.csproj";
  nugetDeps = ./deps.json;

  dotnetFlags = [
    "-p:Version=${finalAttrs.version}"
    "-p:Csharpier_Bypass=true"
    "-p:DownloadFFmpeg=false"
  ];

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs = [
    ffmpeg
  ];

  __structuredAttrs = true;

  makeWrapperArgs = [
    "--run"
    "export YOUTUBEDOWNLOADER_SETTINGS_PATH=\${XDG_CONFIG_HOME:-$HOME/.config}/YoutubeDownloader/Settings.dat"
  ];

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp $src/favicon.png $out/share/icons/hicolor/256x256/apps/tyrrrz-youtube-downloader.png
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-${finalAttrs.pname}";
    runtimeInputs = [ nix-update ];
    text = ''
      nix-update ${finalAttrs.pname} --flake
    '';
  };

  desktopItems = [
    (makeDesktopItem {
      desktopName = "YoutubeDownloader";
      genericName = "Youtube Downloader";
      exec = finalAttrs.meta.mainProgram;
      name = "YoutubeDownloader";
      icon = "tyrrrz-youtube-downloader";
    })
  ];

  meta = {
    description = "Youtube Downloader by Tyrrrz.";
    longDescription = ''
      Youtube Downloader by Tyrrrz. 
    '';
    homepage = "https://github.com/Tyrrrz/YoutubeDownloader";

    mainProgram = "YoutubeDownloader";
  };
})
