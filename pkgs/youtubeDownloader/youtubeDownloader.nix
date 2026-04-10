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
  version = "1.16.3";
  src = fetchFromGitHub {
    owner = "Tyrrrz";
    repo = "YoutubeDownloader";
    rev = finalAttrs.version;
    hash = "sha256-fEj3Ix+0/3Py+fVIl5r+aXhPaIfJj4YXuGzZTTVxy/A=";
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
