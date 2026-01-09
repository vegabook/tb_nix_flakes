{
  description = "Python 3.11 development environment";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
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
            python312
            python312Packages.uv
            python312Packages.numpy
            sqlite
            libsixel
            R
            rPackages.arrow
            rPackages.xts
            typst
          ];

          shellHook = ''
            if [ -z "$NIX_SHELL_NESTED" ]; then
              export NIX_SHELL_NESTED=1
              alias ipy="uv run ipython --nosep --TerminalInteractiveShell.editing_mode=vi --TerminalInteractiveShell.ttimeoutlen=10"
              alias autopy="uv run ipython --nosep -i --ext autoreload -c '%autoreload 2' --colors=LightBG"
              export PS1="⛳ \e[38;5;211m\]Trading-Caddie\e[0m $PS1"
              if [ ! -d .venv ]; then
                echo "Running uv init, adding ipython and pip"
                uv init .
                uv add pip
                uv add ipython
              fi
              uv run pip list
            else
              echo "Nested nix-shell detected, skipping uv init"
            fi
          '';
        };
      });
    };
}


