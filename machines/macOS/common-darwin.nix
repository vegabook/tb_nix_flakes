{ pkgs, lib, ... }: {
  system.primaryUser = "tbrowne";

  nix-homebrew = {
    enable = true;
    user = "tbrowne";
    autoMigrate = true;
  };


  # === Yggdrasil Mesh Network (now properly defined) ===
  environment.systemPackages = [ pkgs.vim pkgs.yggdrasil ];

  # This creates the `yggdrasil` option you were using
  options.yggdrasil = {
    enable = lib.mkEnableOption "Yggdrasil overlay network";
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Yggdrasil configuration (converted to JSON and passed via stdin)";
    };
  };

  config = lib.mkIf config.yggdrasil.enable {
    launchd.user.agents.yggdrasil = {
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/yggdrasil.stdout.log";
        StandardErrorPath = "/tmp/yggdrasil.stderr.log";
      };

      # Declarative config via stdin (-useconf). No /etc file needed.
      script = ''
        exec ${pkgs.yggdrasil}/bin/yggdrasil --useconf <<'EOC'
${builtins.toJSON config.yggdrasil.settings}
EOC
      '';
    };
  };

  yggdrasil = {
    enable = true;
    settings = {
      Peers = [
        "tls://london.sabretruth.org:18472"
      ];
    };
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

}
