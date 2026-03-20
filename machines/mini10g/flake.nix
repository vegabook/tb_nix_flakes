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
          "affinity"
          "transmission"
        ];
      };

      environment.systemPackages = [ pkgs.vim ];
      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      users.users.tbrowne.home = "/Users/tbrowne";

      system.activationScripts.extraActivation.text = ''
        ln -sfn /Volumes/T5 /Users/tbrowne/T5
      '';
    };
  in
  {
    darwinConfigurations."mini10g" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";  # ← This fixes the hostPlatform error

      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
      ];
    };
  };
}
