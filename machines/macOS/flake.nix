{
  description = "Nix-darwin system flake for macOS machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    commonModules = [
      ./common-darwin.nix
      nix-homebrew.darwinModules.nix-homebrew
      {
        system.configurationRevision = self.rev or self.dirtyRev or null;
      }
    ];
  in
  {
    darwinConfigurations."mac10" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = commonModules ++ [ ./mac10.nix ];
    };

    darwinConfigurations."mac4" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = commonModules ++ [ ./mac4.nix ];
    };
  };
}
