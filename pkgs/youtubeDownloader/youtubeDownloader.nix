{
  lib,
  buildDotnetModule,
  fetchFromGitHub,

  dotnetCorePackages,

  ffmpeg,
}:
buildDotnetModule (finalAttrs: {
  pname = "youtubeDownloader";
  version = "1.16";
  src = fetchFromGitHub {
    owner = "Tyrrrz";
    repo = "YoutubeDownloader";
    tag = finalAttrs.version;
    hash = "sha256-JbByraY/0OJFywCDyZW5v6f2YoW8ohcPt2ADrVk5sq0=";
  };

  nugetDeps = ./deps.json;

  projectFile = "YoutubeDownloader/YoutubeDownloader.csproj";

  postPatch = ''
    substituteInPlace YoutubeDownloader/Services/SettingsService.cs \
      --replace-fail 'Path.Combine(AppContext.BaseDirectory, "Settings.dat")' 'Environment.GetEnvironmentVariable("YOUTUBEDOWNLOADER_SETTINGS_PATH") ?? "/tmp/YoutubeDownloader/Settings.dat"'
  '';

  __structuredAttrs = true;

  makeWrapperArgs = [
    "--run"
    "mkdir -p \${XDG_CONFIG_HOME:-$HOME/.config}/YoutubeDownloader"
    "--run"
    "export YOUTUBEDOWNLOADER_SETTINGS_PATH=\${XDG_CONFIG_HOME:-$HOME/.config}/YoutubeDownloader/Settings.dat"
  ];

  dotnetFlags = [
    "-p:Version=${finalAttrs.version}"
    "-p:Csharpier_Bypass=true"
    "-p:DownloadFFmpeg=false"
  ];

  buildInputs = [
    ffmpeg
  ];

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  meta = with lib; {
    description = "Youtube Downloader by Tyrrrz.";
    longDescription = ''
      Youtube Downloader by Tyrrrz. 
    '';
    homepage = "https://github.com/Tyrrrz/YoutubeDownloader";

    mainProgram = "YoutubeDownloader";
  };
})
