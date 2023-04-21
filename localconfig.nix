{ config, pkgs, ... }:

{
      imports =
      [
        (builtins.fetchurl "https://raw.githubusercontent.com/stueng/nixos/main/dockerhost1/configuration.nix")
      ];
}
