{ config, pkgs, ... }:

{
#  imports =
#    [ # Include the results of the hardware scan.
#      ./hardware-configuration.nix
#    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
    options = ["noatime"];
  };

  environment.systemPackages = import ./system-packages.nix pkgs;

  networking.hostName = "controlserver1";

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  system.stateVersion = "22.11"; # Did you read the comment?
}
