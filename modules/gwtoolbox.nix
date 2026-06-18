{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homeModules.gwtoolbox;
in
{
  options.homeModules.gwtoolbox = {
    enable = lib.mkEnableOption "Enable Guild Wars Toolbox";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.gwtoolbox;
      description = "The gwtoolbox package to use.";
    };

    pathInHome = lib.mkOption {
      type = lib.types.str;
      description = "Path where the GWToolbox.exe should be placed in your home directory.";
      example = lib.literalExpression ''
        pathInHome = "Games/GWToolbox/GWToolbox.exe";
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.file."${cfg.pathInHome}" = {
      source = "${cfg.package}/bin/GWToolbox.exe";
    };
  };
}
