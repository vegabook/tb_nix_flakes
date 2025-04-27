{
  description = "Flake to configure beelink mini pc";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let 
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      }; 
    };
  in
  {
    nixosConfigurations = {
      beeNixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };
	      modules = [ ./configuration.nix ];
      };
    };
  };
}
