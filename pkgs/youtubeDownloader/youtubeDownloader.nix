{
  buildDotnetModule,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,

  dotnetCorePackages,

  ffmpeg,
}:
buildDotnetModule (finalAttrs: {
  pname = "youtubeDownloader";
  version = "1.16.1";
  src = fetchFromGitHub {
    owner = "Tyrrrz";
    repo = "YoutubeDownloader";
    rev = "6b7c635b0221cd256629319d1eaec408e38afbe5"; # finalAttrs.version;
    hash = "sha256-P34akbynbP0Aecg+tjt2XsN/PL3leXZ27YcL8/LZ83U=";
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
