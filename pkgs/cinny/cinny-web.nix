# Cinny (https://app.cinny.in) as a Chromium app window with its own profile.
#
# On its own this is a plain launcher + desktop entry. Every argument below the
# divider can be changed with `.override { ... }` (the home-manager module in
# modules/cinny.nix does exactly that) to add flags, extensions or tabshare.
{
  lib,
  callPackage,
  writeShellApplication,
  makeDesktopItem,
  symlinkJoin,
  chromium,
  util-linux,
  cinny-icon ? callPackage ./cinny-icon.nix { },

  # ---------------------------------------------------------------------------

  # Page opened as the app window.
  url ? "https://app.cinny.in",
  # Window class Chromium gives the app window (also the .desktop file name).
  # null = derive it from `url` the way Chromium does.
  wmClass ? null,
  # Chromium --user-data-dir. null = "$XDG_CONFIG_HOME/cinny-web", resolved at runtime.
  profileDir ? null,
  # Base Chromium flags.
  chromiumFlags ? [ "--ozone-platform-hint=auto" ],
  # Appended after everything else.
  extraChromiumFlags ? [ ],
  # Merged into a single --enable-features / --disable-features flag each,
  # since Chromium only honours the last occurrence of those switches.
  enableFeatures ? [ ],
  disableFeatures ? [ ],
  # Unpacked extension directories (derivations or paths) to load.
  extensions ? [ ],
  # tabshare package, or null to leave it out entirely.
  tabshare ? null,
  # Page tabshare serves; opened by `cinny-web --tabshare`.
  tabshareUrl ? "http://localhost:8823/",
}:
let
  urlParts = builtins.match "[a-zA-Z]+://([^/?#]+)([^?#]*).*" url;
  host = builtins.elemAt urlParts 0;
  path =
    let
      p = builtins.elemAt urlParts 1;
    in
    if p == "" then "/" else p;

  appClass =
    if wmClass != null then
      wmClass
    else
      assert lib.assertMsg (
        urlParts != null
      ) "cinny-web: can't derive wmClass from url '${url}', set wmClass";
      "chrome-${host}_${lib.replaceStrings [ "/" ] [ "_" ] path}-Default";

  flags =
    chromiumFlags
    ++
      lib.optional (extensions != [ ])
        "--load-extension=${lib.concatMapStringsSep "," toString extensions}"
    ++ lib.optional (
      enableFeatures != [ ]
    ) "--enable-features=${lib.concatStringsSep "," enableFeatures}"
    ++ lib.optional (
      disableFeatures != [ ]
    ) "--disable-features=${lib.concatStringsSep "," disableFeatures}"
    ++ extraChromiumFlags;

  profile =
    if profileDir == null then
      ''"''${XDG_CONFIG_HOME:-$HOME/.config}/cinny-web"''
    else
      lib.escapeShellArg profileDir;

  header = ''
    chrome=(${lib.getExe chromium} --user-data-dir=${profile} ${lib.escapeShellArgs flags})
    app_url=${lib.escapeShellArg url}
  '';

  plainLauncher = ''
    exec "''${chrome[@]}" --app="$app_url" "$@"
  '';

  tabshareLauncher = ''
    # "cinny-web --tabshare": open the tabshare page as a tab in Cinny's browser
    if [ "''${1:-}" = "--tabshare" ]; then
      exec "''${chrome[@]}" ${lib.escapeShellArg tabshareUrl}
    fi

    # Already running? Just hand the request to the existing Chromium,
    # don't start a second tabshare (it would remove the first one's devices).
    exec 9>"''${XDG_RUNTIME_DIR:-/tmp}/cinny-web.lock"
    if ! flock -n 9; then
      exec "''${chrome[@]}" --app="$app_url" 9>&-
    fi

    tabshare 9>&- &
    tabshare_pid=$!

    cleanup() {
      kill "$tabshare_pid" 2>/dev/null || true
      wait "$tabshare_pid" 2>/dev/null || true
    }
    trap cleanup EXIT
    trap 'exit 0' INT TERM HUP

    "''${chrome[@]}" --app="$app_url" 9>&- &
    wait $! || true
  '';

  launcher = writeShellApplication {
    name = "cinny-web";
    runtimeInputs = lib.optionals (tabshare != null) [
      util-linux
      tabshare
    ];
    text = header + (if tabshare == null then plainLauncher else tabshareLauncher);
  };

  desktopItem = makeDesktopItem {
    name = appClass;
    desktopName = "Cinny Web";
    genericName = "Matrix Client";
    exec = lib.getExe launcher;
    icon = "${cinny-icon}";
    terminal = false;
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
    ];
    startupWMClass = appClass;
    actions = lib.optionalAttrs (tabshare != null) {
      tabshare = {
        name = "Open Tabshare";
        exec = "${lib.getExe launcher} --tabshare";
      };
    };
  };
in
symlinkJoin {
  name = "cinny-web";
  paths = [
    launcher
    desktopItem
  ];
  passthru = {
    inherit launcher desktopItem;
    wmClass = appClass;
    # Relative to the package root, e.g. for an autostart symlink.
    desktopFile = "share/applications/${appClass}.desktop";
  };
  meta = {
    description = "Cinny Matrix client as a Chromium app window";
    homepage = "https://cinny.in";
    mainProgram = "cinny-web";
    platforms = lib.platforms.linux;
  };
}
