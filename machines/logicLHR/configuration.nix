# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).


{ config, pkgs, ... }:

# all unused for now
let 
  username = builtins.getEnv "USER"; #
  hostname = builtins.getEnv "HOSTNAME";
  homeDirectory = builtins.getEnv "HOME";
in
  

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;


  networking.hostName = "logicLHR"; # Define your hostname. ## NOTE change for other systems
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "America/New_York"; ## NOTE change for other systems
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # enable nix flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    tmux
    home-manager
    htop
    git
    gcc
    gnumake
    gcc
    libiconv
    autoconf
    automake
    libtool
    zoxide
    weechat
    nostr-rs-relay
  ];

  programs.bash.promptInit =  ''

    PS1="\[\033[1;31m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w] \[\033[0m\]💂 "

  '';

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

   services.fail2ban = {
     enable = true;
     maxretry = 5; # Observe 5 violations before banning an IP
     bantime = "12h"; # Set bantime to one day
   };

   services.yggdrasil = {
     enable = true;
     configFile = "/home/tbrowne/.config/yggdrasil/yggdrasil_logicLHR.conf";
     group = "wheel";
   };

   services.caddy = {
     enable = true;

     virtualHosts."aspectdelta.com".extraConfig = ''
 	reverse_proxy http://[200:5483:a5f4:c957:d29d:ec17:381d:eebc]:4000
     '';
 
     virtualHosts."sabretruth.org".extraConfig = ''
 	reverse_proxy http://[200:5483:a5f4:c957:d29d:ec17:381d:eebc]:4004
     '';
     virtualHosts."sabertruth.com".extraConfig = ''
       redir https://sabretruth.org{uri}
     '';
     virtualHosts."sabretruth.com".extraConfig = ''
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
	server ipv6 [200:5483:a5f4:c957:d29d:ec17:381d:eebc]:41111

    '';
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 41111 7007 7008 18472 18473 50051 50052 ];

  #systemd.timers."example_python_script" = {
  #wantedBy = [ "timers.target" ];
  #  timerConfig = {
  #    OnBootSec = "1m";
  #    OnUnitActiveSec = "1m";
  #    Unit = "example_python_script.service";
  #  };
  #};

  ## example python script
  #systemd.services."example_python_script" = 
  #let
  #  script = /home/tbrowne/scratch/outnum.py;
  #in {
  #  path = with pkgs; [
  #    git
  #    (python311.withPackages (ps: with ps; [
  #      numpy 
  #      pandas 
  #      scipy 
  #      scikit-learn 
  #      matplotlib
  #      ipython
  #      requests
  #      aiohttp
  #      gql
  #      pathlib2
  #      psycopg2
  #      sqlalchemy
  #      selenium
  #      webdriver-manager
  #    ]))
  #  ];
  #  script = "python3 ${script}";
  #  serviceConfig = {
  #    Type = "oneshot";
  #    User = "root";
  #  };
  #};


  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
