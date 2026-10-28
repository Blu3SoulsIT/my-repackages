{
  description = "Software that I like to use.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    tab-share = {
      url = "gitlab:Blu3Souls/tabshare";
      inputs.nixpkgs.follows = "nixpkgs";
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
            cinny-icon = pkgs.callPackage ./pkgs/cinny/cinny-icon.nix { };
            cinny-web = pkgs.callPackage ./pkgs/cinny/cinny-web.nix { };
            no-agc-extension = pkgs.callPackage ./pkgs/cinny/no-agc-extension.nix { };
            tabshare = pkgs.callPackage ./pkgs/cinny/tabshare.nix { inherit (inputs) tab-share; };
            gwtoolbox = (pkgs.callPackage ./pkgs/gwtoolbox/gwtoolbox.nix { });
            nuclear = (pkgs.callPackage ./pkgs/nuclear/nuclear.nix { });
            star-strings = (pkgs.callPackage ./pkgs/star-strings/star-strings.nix { });
            youtubeDownloader = (pkgs.callPackage ./pkgs/youtubeDownloader/youtubeDownloader.nix { });
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
        homeManagerModules.star-strings = import ./modules/star-strings.nix self;
        homeManagerModules.gwtoolbox = import ./modules/gwtoolbox.nix self;
        homeManagerModules.cinny = import ./modules/cinny.nix self;
      };
    };
}
