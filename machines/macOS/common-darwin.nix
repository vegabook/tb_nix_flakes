{ pkgs, ... }: {
  system.primaryUser = "tbrowne";

  nix-homebrew = {
    enable = true;
    user = "tbrowne";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };

  environment.systemPackages = [ pkgs.vim ];
  environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  nix.settings.experimental-features = "nix-command flakes";
  system.stateVersion = 6;
  users.users.tbrowne.home = "/Users/tbrowne";
  power.sleep.display = "never";
  system.defaults.screensaver.askForPassword = false;
  system.defaults.loginwindow.autoLoginUser = "tbrowne";

  system.activationScripts.extraActivation.text = ''
    ln -sfn "/Users/tbrowne/Library/Mobile Documents/com~apple~CloudDocs" /Users/tbrowne/iCloud
  '';

  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      PubkeyAuthentication yes
      AcceptEnv LANG LC_*
    '';
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
}
