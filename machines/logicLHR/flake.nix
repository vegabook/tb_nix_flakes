{
  description = "Flake to configure logicLHR (and potentially other Logic Servers)";

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
      logicLHR = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };
	modules = [ ./configuration.nix ];
      };
    };
  };
}

