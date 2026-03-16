# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.kernelParams = [ "cpufreq.default_governor=schedutil" ]; # for cpu cap at 2ghz
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 2147483648;


  systemd.services.cpu-freq-cap = {
    description = "Cap CPU GHz";
    wantedBy = [ "sysinit.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "cap-cpu" ''
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
          echo 2000000 > "$cpu/scaling_max_freq"
        done
      '';
      RemainAfterExit = true;
    };
  };

  networking.hostName = "bee";
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

  services.thermald.enable = true;

  swapDevices = [{
    device = "/swap/swapfile";
    size = 96 * 1024;
  }];

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.tbrowne = {
    isNormalUser = true;
    description = "Thomas Browne";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
     neovim
     helix
     wget
     htop
     git
     home-manager
     lm_sensors
  ];

  programs.git = {
    enable = true;
    config = {
      advice = {
        addIgnoredFile = false;
      };
      init = {
        defaultBranch = "main";
      };
      user = {
        name = "vegabook";
        email = "thomas.browne@mac.com";
      };
    };
  };

  programs.bash.shellAliases = {
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";
    vim = "nvim";
  };

  # Virtualisation
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

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
     maxretry = 5;
     bantime = "12h";
  };

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    group = "wheel";
    settings = {
      Peers = [
        tls://london.sabretruth.org:18472
      ];
      #Listen = [             # uncomment to listen
      #  "tls://[::]:18472"
      #  "quic://[::]:18473"
      #];
    };
  };

  services.postgresql = {
    enable = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    4004   # elixir HTTP
    18472  # yggdrasil
    18473  # yggdrasil
    50051  # gBLP bloomberg gRPC
    50052  # gBLP bloomberg gRPC
  ];
  networking.firewall.allowedUDPPorts = [
    4004   # elixir HTTP
    18472  # yggdrasil
    18473  # yggdrasil
    50051  # gBLP bloomberg gRPC
    50052  # gBLP bloomberg gRPC
  ];
  system.stateVersion = "23.11";

}

