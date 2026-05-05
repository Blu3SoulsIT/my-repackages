{
  description = "Software that I like to use.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [ "x86_64-linux" ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          lib,
          system,
          ...
        }:
        {
          packages = {
            youtubeDownloader = (pkgs.callPackage ./pkgs/youtubeDownloader/youtubeDownloader.nix { });
            star-strings = (pkgs.callPackage ./pkgs/star-strings/star-strings.nix { });
          };

          apps.update-all = {
            type = "app";
            program = lib.getExe (
              pkgs.writeShellApplication {
                name = "update-all";
                text = lib.concatStringsSep "\n" (
                  lib.mapAttrsToList (name: pkg: ''
                    echo "Running update script for: ${name}"
                    ${lib.getExe pkg.updateScript}
                  '') (lib.filterAttrs (n: v: v ? updateScript) config.packages)
                );
              }
            );
            meta.description = "Updates all packages.";
          };
        };

      flake = {
        homeManagerModules.star-strings = import ./modules/star-strings.nix { inherit self; };
      };
    };
}
