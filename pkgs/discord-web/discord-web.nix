{
  lib,
  callPackage,
  writeShellScriptBin,
  makeDesktopItem,
  symlinkJoin,
  chromium,
  discord-icon ? callPackage ./discord-icon.nix { },
  url ? "https://discord.com/app",
  extraFlags ? [ ],
}:
let
  pname = "discord-web";

  launcher = writeShellScriptBin pname ''
    exec ${lib.getExe chromium} \
      --user-data-dir="''${XDG_DATA_HOME:-$HOME/.local/share}/${pname}" \
      --app=${lib.escapeShellArg url} \
      ${lib.escapeShellArgs extraFlags} \
      "$@"
  '';

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Discord";
    genericName = "Chat";
    comment = "Discord web app in Chromium";
    exec = pname;
    icon = "${discord-icon}";
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
    ];
    # Chromium --app windows get an app_id/WM_CLASS derived from the URL + profile name
    startupWMClass = "chrome-discord.com__app-Default";
  };
in
symlinkJoin {
  name = pname;
  paths = [
    launcher
    desktopItem
  ];
  meta = {
    description = "Vanilla Discord web app running as a Chromium app window";
    mainProgram = pname;
    platforms = lib.platforms.linux;
  };
}
