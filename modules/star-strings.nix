{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeModules.star-strings;
in
{
  options.homeModules.star-strings = {
    enable = lib.mkEnableOption "Star Citizen Localization";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.star-strings;
      description = "The StarStrings package to use.";
    };

    pathInHome = lib.mkOption {
      type = lib.types.str;
      description = "Path to your LIVE/PTU directory in your home directory.";
      default = "Games/rsi-launcher/drive_c/Program Files/Roberts Space Industries/StarCitizen";
    };

    environments = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Name of the environments to install the language file into.";
      default = [
        "LIVE"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = (
      lib.genAttrs
        (lib.map (e: "${cfg.pathInHome}/${e}/Data/Localization/english/global.ini") cfg.environments)
        (name: {
          source = "${cfg.package}/global.ini";
        })
    );
  };
}
