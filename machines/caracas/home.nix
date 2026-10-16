{ config, pkgs, ... }:

{
  home.username = "tbrowne";
  home.homeDirectory = "/home/tbrowne";

  # Don't change after first switch.
  home.stateVersion = "26.05";

  # Fixes XDG_DATA_DIRS etc. on non-NixOS distros.
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    neovim
    helix
    wget
    htop
  ];

  programs.git = {
    enable = true;
    settings = {
      advice.addIgnoredFile = false;
      init.defaultBranch = "main";
      user = {
        name = "vegabook";
        email = "thomas.browne@mac.com";
      };
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      l = "ls -alh";
      ll = "ls -l";
      ls = "ls --color=tty";
      vim = "nvim";
    };
  };

  # Lets home-manager manage (and put itself on PATH).
  programs.home-manager.enable = true;
}
