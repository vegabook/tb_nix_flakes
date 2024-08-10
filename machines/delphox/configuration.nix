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
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "delphox"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.interfaces.ens18 = {
    ipv4.addresses = [
      {
        address = "45.92.36.186";
        prefixLength = 27;
      }
    ];
    ipv6.addresses = [
      {
        address = "2a0e:1bc1:161:4cf6::1";
        prefixLength = 64;
      }
    ];
  };

  networking.defaultGateway = "45.92.36.161";
  networking.defaultGateway6 = "2a0e:1bc1:161::1";

  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];

  # enable nix flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.allowed-users = [ "*" ];

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

  users.mutableUsers = true; # users congruent with configuration
  
  users.users.tbrowne = {
    isNormalUser = true;
    description = "Thomas Browne";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  users.users.shafy = {
    isNormalUser = true;
    description = "Mohamed Abd El Shafy";
    extraGroups = [];
    packages = with pkgs; [];
  };

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    group = "wheel";
    settings = {
      Peers = [
        "tls://fr2.servers.devices.cwinfo.net:23108"
        "tls://s2.i2pd.xyz:39575"
      ];
      Listen = [ "tls://[::]:18472" ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim 
    wget
    git
    tmux
    mkpasswd
    htop
    tree
  ];

  programs.bash.shellAliases = {
    sudo="sudo ";
    l="ls -alh";
    ll="ls -l";
    ls="ls --color=tty";
    vim="nvim";
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false; 
  };

  services.fail2ban.enable = true;

  # Postgres
  # ...
  # ...
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "neonews" ];
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
  };


  services.caddy = {
    enable = true;

    virtualHosts."www.scendance.fr" = {
    	extraConfig = ''
    	  reverse_proxy http://[204:915b:4fa1:1d9a:a061:4b9e:76be:f1fc]:4001
    	'';
    };
    virtualHosts."scendance.fr".extraConfig = ''
      redir https://www.scendance.fr{uri}
    '';
    virtualHosts."scen.dance".extraConfig = ''
      redir https://www.scendance.fr{uri}
    '';
    virtualHosts."scendance.digital".extraConfig = ''
      redir https://www.scendance.fr{uri}
    '';
    virtualHosts."scendance.com".extraConfig = ''
      redir https://www.scendance.fr{uri}
    '';

    virtualHosts."suprabonds.com".extraConfig = ''
	reverse_proxy http://[204:915b:4fa1:1d9a:a061:4b9e:76be:f1fc]:4002
    ''; 
    
    virtualHosts."signaliser.com".extraConfig = ''
	reverse_proxy http://[204:915b:4fa1:1d9a:a061:4b9e:76be:f1fc]:4003
    ''; 

    virtualHosts."sabretruth.org".extraConfig = ''
	reverse_proxy http://[204:915b:4fa1:1d9a:a061:4b9e:76be:f1fc]:4004
    ''; 
    virtualHosts."sabertruth.com".extraConfig = ''
      redir https://sabretruth.org{uri}
    '';
    virtualHosts."sabretruth.org".extraConfig = ''
      redir https://sabretruth.org{uri}
    '';
    virtualHosts."sabertruth.org".extraConfig = ''
      redir https://sabretruth.org{uri}
    '';
  };

  services.haproxy = {
    enable = true;
    config = ''
      global
	daemon
	maxconn 10000

      defaults
	timeout connect 500s
	timeout client 5000s
	timeout server 1h

      frontend sshd
	bind *:41111
	default_backend ssh
	timeout client 1h

      backend ssh
	mode tcp
	server ipv6 [204:915b:4fa1:1d9a:a061:4b9e:76be:f1fc]:41111
    '';
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 41111 7007 7008 18472 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
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
