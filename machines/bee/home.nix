{ config, pkgs, lib, ... }:

let
  fromGitHub = rev: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = rev;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      rev = rev;
    };
  };
  username = builtins.getEnv "USER";
  path = builtins.getEnv "PATH";
  homeDirectory = builtins.getEnv "HOME";
  isLinux = builtins.currentSystem == "x86_64-linux" || builtins.currentSystem == "aarch64-linux";
  isDarwin = builtins.currentSystem == "aarch64-darwin";
  hostname = builtins.getEnv "HOSTNAME"; 
in
let tmuxbg = if hostname == "rpi4" then "colour204"
             else if hostname == "scen7" then "colour59"
             else if hostname == "logicLHR" then "colour9"
             else if hostname == "bee" then "colour40"
             else "colour255";
in
#let
#  tmuxbg = {
#    "rpi4" = "colour163";
#    "scen7" = "colour59";
#    "logicLHR" = "colour9";
#    "bee" = "colour40";
#  }.${hostname};
#in


{
  # are we on Linux?
  targets.genericLinux.enable = isLinux;
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  programs.home-manager.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    rclone
    tree
    ack
    bqn386
    chafa # sixel viewer
    fuse
    neovim
    nodejs
    asciinema
    bqn386
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    git-lfs
    tree-sitter
    ripgrep
    zellij

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];           

  programs.git = {
    enable = true;
    userName = "vegabook";
    userEmail = "thomas@scendance.fr";
    lfs.enable = true;
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R
      set -g status-bg ${tmuxbg}
            
      set -g mouse on

      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g escape-time 0
    '';
  };

  programs.zsh = if isDarwin then {
    enable = true;
    autocd = true;
    enableCompletion = true;
    shellAliases = {
      ls = "ls -alG";
      vim = "nvim";
      sd="cd ~ && cd \$(find * -type d | fzf)";
    };
    initContent = ''
      make_superscript () { sed 'y/0123456789/⁰¹²³⁴⁵⁶⁷⁸⁹/' <<< $SHLVL; };
      direnv_yes () { env | grep DIRENV_DIR | wc -l | sed 's/[0 ]//g'; };
      nixshell_yes () { env | grep IN_NIX_SHELL | wc -l | sed 's/[0 ]//g'; };
      echoer () { export PROMPT="%f%F{yellow}$(nixshell_yes)%f%F{red}$(make_superscript)%f%F{green}%n@%m %F{$016}%~%f %F{green}❯%f " };
      precmd_functions+=(echoer);
      CLICOLOR=1;
      PATH=${homeDirectory}/scripts:$PATH;
      NIXPKGS_ALLOW_UNFREE=1;
      setopt rmstarsilent
    '';
  } else {
    enable = false;
  };
    
  
  programs.fzf = {
    enable = true;
  };

  # github cli 
  programs.gh = {
    enable = true;
  };

  programs.btop = {
    enable = true;
  };

  programs.htop = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = isLinux;
  };

  programs.wezterm = {
    enable = true;
  };

  programs.bash = {
    enable = true;
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    "./.config/nvim" = {
      source = ./nvim;
      recursive = true;
    };  
    "./.config/helix" = {
      source = ./helix;
      recursive = true;
    };  
    "./.config/zellij" = {
      source = ./zellij;
      recursive = true;
    };  
    "./.config/wezterm" = {
      source = ./wezterm;
      recursive = true;
    };  
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mmai/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
    NIXPKGS_ALLOW_UNFREE=1;
  };

  home.shellAliases = { 
    vim = "nvim"; 
  };
}
