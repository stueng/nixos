{ config, pkgs, ... }:

# Import variables from common.nix (generated using configure.sh)
let inherit (import /etc/nixos/common.nix) hostname username ts_key tsroute_enabled tssubnet; in

{
  imports =
    [
      # Include the hardware configuration for the machine.
      /etc/nixos/hardware-configuration.nix
    ];

  # systemd
  boot.loader.systemd-boot.enable = true;

  # Networking
  networking.hostName = "${hostname}";
  networking.useDHCP = true;
  time.timeZone = "Europe/London";

  # Tail Scale
  
   
  environment.systemPackages = with pkgs; [
    tailscale
    #ruby
        
    (ruby.withPackages (ps: with ps; [ rubyPackages.rails-dom-testing ]))
    
    gcc
    #ntpdate
    ntp
    #libevent-devel
    libevent
    #apt-transport-https
    #maybe - rPackages.transport
    #ca-certificates
    #gnupg-agent
    gnupg
    #software-properties-common
    #??
    nmap
    #net-tools
    nettools
    #kernel-devel
    #??
    #make
    gnumake
    #??
    #ncurses-devel
    ncurses
    #openssl-devel
    openssl
    unzip
    wget
  ];

  services.tailscale.enable = true;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.firewall.enable = false;
  networking.firewall.checkReversePath = "loose";

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";

  script = with pkgs; ''
      sleep 2
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ ${tsroute_enabled} = "y" ]; then # if tailscale routing is enabled.
        if [ $status = "Running" ]; then
          ${tailscale}/bin/tailscale up -authkey ${ts_key} --advertise-routes ${tssubnet}
          exit 0
        fi
        ${tailscale}/bin/tailscale up -authkey ${ts_key} --advertise-routes ${tssubnet}
      else # if tailscale routing is not enabled
        if [ $status = "Running" ]; then #
          ${tailscale}/bin/tailscale up -authkey ${ts_key}
          exit 0
        fi
        ${tailscale}/bin/tailscale up -authkey ${ts_key}
      fi
    '';
  };

  # Install Docker.
  virtualisation.docker.enable = true;

  # Enable SSH.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  #Sorandom
  system.stateVersion = "22.11";

  # User information
  users.users = {
    "${username}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGxP5lOE1Jkx0InbMhNN3QcJObTmDuftS/BvlGk261FF7tKyq9edjCVZfkUo2I+1KGuEKhDCS27UNR3P8bnCXomYVMTKLQkG/dVHX78bN8aIOnMYDt3Bwfx6D5ZGP6t1rVPOhKkg5H+x/hq4/lsuqaMJR9nGMxJK1qKqIQfpMaTmH1guH8NQdqaxo7ccHolpvxKyJyrz2KwvjEeN4wPDFWnsSr3OC52+fOS+k7gkOtOoxEnRbjiKSeLdrmWA8cRV/p8D19iIw6xPDr/dCOrCk/MAU41bjKgO8w8RvHN8N9SZc6JuER+ZsLtXjQRIZGAgGs5X2F0D2jASEGZffXQ3/9" ];
    };
  };
}
