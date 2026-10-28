# home-manager module for Cinny Web.
#
# Takes this repo's flake `self` so option defaults can point at its packages:
#   homeManagerModules.cinny = import ./modules/cinny.nix self;
self:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    optional
    literalExpression
    ;

  cfg = config.programs.cinny-web;
  selfPkgs = self.packages.${pkgs.stdenv.hostPlatform.system};

  finalPackage = cfg.package.override {
    chromium = cfg.chromium.package;
    inherit (cfg) url wmClass profileDir;
    chromiumFlags = cfg.chromium.flags;
    extraChromiumFlags = cfg.chromium.extraFlags;
    enableFeatures = cfg.chromium.enableFeatures;
    disableFeatures =
      cfg.chromium.disableFeatures ++ optional cfg.noAgc.enable "WebRtcAllowInputVolumeAdjustment";
    extensions = cfg.chromium.extensions ++ optional cfg.noAgc.enable cfg.noAgc.package;
    tabshare = if cfg.tabshare.enable then cfg.tabshare.package else null;
    tabshareUrl = cfg.tabshare.url;
  };
in
{
  options.programs.cinny-web = {
    enable = mkEnableOption "Cinny as a Chromium app window";

    package = mkOption {
      type = types.package;
      default = selfPkgs.cinny-web;
      defaultText = literalExpression "self.packages.\${system}.cinny-web";
      description = "Base cinny-web package. Must accept the overrides of pkgs/cinny/cinny-web.nix.";
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      default = finalPackage;
      defaultText = literalExpression "cinny-web with all options applied";
      description = "The resulting package that gets installed.";
    };

    url = mkOption {
      type = types.str;
      default = "https://app.cinny.in";
      description = "Cinny instance to open.";
    };

    wmClass = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "chrome-app.cinny.in__-Default";
      description = ''
        Window class of the app window, also used as the desktop file name.
        null derives it from {option}`url` the same way Chromium does.
      '';
    };

    profileDir = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = literalExpression ''"''${config.xdg.configHome}/cinny-web"'';
      description = "Chromium profile directory. null uses $XDG_CONFIG_HOME/cinny-web at runtime.";
    };

    autostart = mkEnableOption "starting Cinny on login";

    chromium = {
      package = mkOption {
        type = types.package;
        default = pkgs.chromium;
        defaultText = literalExpression "pkgs.chromium";
        description = "Chromium package used to run Cinny.";
      };

      flags = mkOption {
        type = types.listOf types.str;
        default = [ "--ozone-platform-hint=auto" ];
        description = ''
          Base Chromium flags. Setting this replaces the defaults; use
          {option}`chromium.extraFlags` to add to them instead.
        '';
      };

      extraFlags = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "--disable-gpu" ];
        description = "Additional Chromium flags, appended last.";
      };

      enableFeatures = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "WebRTCPipeWireCapturer" ];
        description = "Features combined into one --enable-features flag.";
      };

      disableFeatures = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Features combined into one --disable-features flag (together with
          the ones added by {option}`noAgc.enable`).
        '';
      };

      extensions = mkOption {
        type = types.listOf (types.either types.package types.path);
        default = [ ];
        description = "Unpacked extension directories to load.";
      };
    };

    noAgc = {
      enable = mkEnableOption ''
        the fix for WebRTC automatic gain control: loads an extension that
        forces autoGainControl off and disables WebRtcAllowInputVolumeAdjustment
      '';

      package = mkOption {
        type = types.package;
        default = selfPkgs.no-agc-extension;
        defaultText = literalExpression "self.packages.\${system}.no-agc-extension";
        description = "The no-AGC extension.";
      };
    };

    tabshare = {
      enable = mkEnableOption ''
        tabshare, started and stopped together with Cinny, plus an
        "Open Tabshare" desktop action'';

      package = mkOption {
        type = types.package;
        default = selfPkgs.tabshare;
        defaultText = literalExpression "self.packages.\${system}.tabshare";
        description = "tabshare package.";
      };

      url = mkOption {
        type = types.str;
        default = "http://localhost:8823/";
        description = "Page served by tabshare, opened by the Open Tabshare action.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.finalPackage ];

    xdg.configFile."autostart/${cfg.finalPackage.wmClass}.desktop" = mkIf cfg.autostart {
      source = "${cfg.finalPackage}/${cfg.finalPackage.desktopFile}";
    };
  };
}
