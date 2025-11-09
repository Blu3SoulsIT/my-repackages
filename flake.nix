{
  description = "X1 Control Panel software for Swiftpoint mouse products.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [];
      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = {
          arcdpsLogManager = (pkgs.callPackage ./pkgs/arcdpsLogManager/arcdpsLogManager.nix { });
        };
      };
      flake = { };
    };
}
