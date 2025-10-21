# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "bee"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tbrowne = {
    isNormalUser = true;
    description = "Thomas Browne";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     neovim 
     helix
     wget
     htop
     tmux
     git
     home-manager
     bison
     flex
     fontforge
     makeWrapper
     pkg-config
     gnumake
     gcc
     libiconv
     autoconf
     automake
     libtool
     btrbk
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  fileSystems."/export/sea5" = {
    device = "/mnt/sea5";
    options = [ "bind" ];
  };

  programs.bash.shellAliases = {
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";
    vim = "nvim";
  };

  # List services that you want to enable:

  services.nfs.server.exports = ''
    /export/sea5         192.168.0.0/16(rw,fsid=0,no_subtree_check,sync,all_squash,anonuid=1000,anongid=100)
  '';

  services.nfs.server = {
    enable = true;
    lockdPort=30011;
    mountdPort = 30012;
    statdPort = 30010;
    extraNfsdConfig = "";
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [
      41111
    ];
    settings.PasswordAuthentication = false;
  };

  services.fail2ban = {
     enable = true;
     maxretry = 5; # Observe 5 violations before banning an IP
     bantime = "12h"; # Set bantime to one day
  };

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    group = "wheel";
    settings = {
      Peers = [
        tls://london.sabretruth.org:18472
      ];
    };
  };

  services.postgresql = {
    enable = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 
    4004
    111
    20048
    2049
    30010
    30011
    30012
    50051
    50052
  ];
  networking.firewall.allowedUDPPorts = [ 
    4000
    4001
    4002
    4003
    111
    20048
    2049
    30010
    30011
    30012
    50051
    50052
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?



}
