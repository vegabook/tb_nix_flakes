{
  description = "Nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {
      system.primaryUser = "tbrowne";

      # nix-homebrew — installs Homebrew itself declaratively
      nix-homebrew = {
        enable = true;
        user = "tbrowne";
        autoMigrate = true;  # safely imports any old manual brew install
      };

      # Your casks (managed by nix-darwin's homebrew module)
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
        };
        casks = [
          "telegram"
          "firefox"
          "whatsapp"
        ];
      };

      environment.systemPackages = [ pkgs.vim ];
      environment.variables = {
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
      };
      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      users.users.tbrowne.home = "/Users/tbrowne";
      power.sleep.display = "never";
      system.defaults.screensaver.askForPassword = false;

      # T5 external ssd
      launchd.daemons.mount-t5 = {
        serviceConfig = {
          Label = "com.local.mount-t5";
          ProgramArguments = [ "/usr/sbin/diskutil" "mount" "T5" ];
          RunAtLoad = true;
        };
      };

      # Enable SSH for headless/server access
      services.openssh = {
        enable = true;
        extraConfig = ''
          # Disable password login (use keys only)
          PasswordAuthentication no
          KbdInteractiveAuthentication no
          PubkeyAuthentication yes
          AcceptEnv LANG LC_*
        '';
      };

      system.activationScripts.extraActivation.text = ''
        ln -sfn /Volumes/T5 /Users/tbrowne/T5
      '';
    };
  in
  {
    darwinConfigurations."mac10" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # ← This fixes the hostPlatform error

      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
      ];
    };
  };
}
