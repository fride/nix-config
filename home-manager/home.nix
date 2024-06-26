# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "jgf";
    homeDirectory = "/home/jgf";
  };

  # Add stuff for your user as you see fit:
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;
  programs.java.enable = true;
  programs.neovim.enable = true;
  home.packages = with pkgs; [
    # core cli tools
    zoxide
    gitui
    jq
    lf
    yq
    tldr
    fd
    helix
    curl
    just
    steam

    # L S P
    nil # Another LSP for NIX
    nodePackages_latest.vscode-json-languageserver-bin
    dhall-lsp-server # TODO this is broken!?
    clojure-lsp
    clj-kondo
    ktlint
    cmake # needed by emacs
    cmake-language-server
    fmt
    scalafmt


  ];
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type file --follow";
    defaultOptions = [ "--height 40%" "--reverse" ];
    enableZshIntegration = true;
  };
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userEmail = "jan@friderici.net";
    userName = "Jan Friderici";
    aliases = {
      undo = "reset HEAD~1 --mixed";
      amend = "commit -a --amend";
      st = "status -sb";
      co = "checkout";
      br = "branch";
      last = "log -1 HEAD";
      p = "push";
      ll = "log --oneline";
      cm = "commit -m";
      se = "!git rev-list --all | xargs git grep -F";
    };
     extraConfig = {
        pull = {
          rebase = true;
        };
        init = {
          defaultBranch = "main";
        };
        core = {
          excludesfile = "~/.gitignore_global";
        };
        include = {
          path = "~/.gitconfig.local";
        };
     };
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
