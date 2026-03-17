{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      environment.systemPackages =
        [ pkgs.vim
        ];

      nix.settings.experimental-features = "nix-command flakes";

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";

      users.users.tbrowne.home = "/Users/tbrowne";

			system.activationScripts.extraActivation.text = ''
				ln -sfn /Volumes/T5 /Users/tbrowne/T5
			'';
    };
  in
  {
    darwinConfigurations."mini10g" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
