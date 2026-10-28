{ stdenv, tab-share }:
tab-share.packages.${stdenv.hostPlatform.system}.default
