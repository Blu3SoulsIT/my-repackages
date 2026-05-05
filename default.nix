let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsRev = lock.nodes.nixpkgs.locked.rev;
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${nixpkgsRev}.tar.gz") { };
in
{
  youtubeDownloader = pkgs.callPackage ./pkgs/youtubeDownloader/youtubeDownloader.nix { };
  star-strings = pkgs.callPackage ./pkgs/star-strings/star-strings.nix { };
}
