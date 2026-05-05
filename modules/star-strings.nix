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
      default = self.packages.${pkgs.system}.star-strings;
      description = "The StarStrings package to use.";
    };

    pathInHome = lib.mkOption {
      type = lib.types.str;
      description = "Path to your LIVE/PTU directory in your home directory.";
      default = "Games/rsi-launcher/drive_c/Program Files/Roberts Space Industries/StarCitizen/LIVE";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file."${cfg.pathInHome}/Data/Localization/english/global.ini" = {
      source = "${cfg.package}/global.ini";
    };
  };
}
