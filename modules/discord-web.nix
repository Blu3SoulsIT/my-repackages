self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.discord-web;
  selfPkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.programs.discord-web = {
    enable = lib.mkEnableOption "Discord as a Chromium web app";

    package = lib.mkOption {
      type = lib.types.package;
      default = selfPkgs.discord-web;
      defaultText = lib.literalExpression "self.packages.\${system}.discord-web";
      description = "The discord-web package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
