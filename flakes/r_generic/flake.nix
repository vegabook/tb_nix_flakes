{
  description = "R development environment";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs"; # also valid: "nixpkgs"
  };

  # Flake outputs
  outputs = { self, nixpkgs }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          # The Nix packages provided in the environment
          packages = with pkgs; [
            R
            rPackages.xts
            rPackages.dplyr
            rPackages.glmnet
            rPackages.ggplot2
            rPackages.reshape2
            rPackages.lattice
            rPackages.quantreg
            rPackages.gridBase
            radianWrapper
            rPackages.ggplot2
            rPackages.xts
            rPackages.ggsci
            rPackages.ragg
            rPackages.png
            rPackages.viridis
            rPackages.forcats
            rPackages.ggridges
            rPackages.scales
            rPackages.RColorBrewer
            rPackages.cowplot
            rPackages.magick
            rPackages.RPostgreSQL
            rPackages.DBI
            rPackages.devtools
            rPackages.tidyverse
            rPackages.svglite
            rPackages.openai
            rPackages.readxl
          ];
        };
      });
    };
}
