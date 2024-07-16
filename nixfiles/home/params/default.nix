{ pkgs, lib, system, rust-cli, ... }:

let
  theme = import ./theme.nix;
  gpg-key = "6116F3CD99CB533F07E4E1441829D5210E0EEC51";
  my-python-packages = python-packages: with python-packages; [
    pandas
    numpy
    matplotlib
    requests
    rich
  ];
  python-with-my-packages = pkgs.python3.withPackages my-python-packages;
  ffmpeg-full-unfree = pkgs.ffmpeg-full.overrideAttrs (old: rec {
    nonfreeLicensing = true;
    fdkaacExtlib = true;
  });
  linux-packages = with pkgs; if stdenv.isLinux then [
    mold
    binutils
  ] else [ ];
  packages = linux-packages ++ [ ffmpeg-full-unfree ];
in
{
  imports = [
    #./sway.nix
  ];

  home-cli-config.enable = true;

  home.username = "rappet";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/rappet" else "/home/rappet";
  home.stateVersion = "22.05";
  home.packages = packages;

  # temporary hack for NixOS unstable
  nixpkgs.overlays = [
    (self: super: {
      fcitx-engines = pkgs.fcitx5;
    })
  ];
  fonts.fontconfig.enable = lib.mkForce true;

  accounts.email = import ./email.nix;

  programs = {
    git = {
      userName = "Raphael Peters";
      userEmail = "rappet@rappet.de";
      signing = {
        key = gpg-key;
        signByDefault = true;
      };
    };
    password-store.settings.PASSWORD_STORE_KEY = gpg-key;
    password-store.settings.FOO = "bar";

    neovim-config.enable = true;

    alacritty = import ./programs/alacritty.nix {
      theme = theme;
    };
    kitty = import ./programs/kitty.nix {
      pkgs = pkgs;
      theme = theme;
    };
    ssh = {
      enable = true;
      matchBlocks = {
        storagebox = {
	        hostname = "u215491.your-storagebox.de";
	        user = "u215491";
	        port = 23;
        };
        chaosdorf = {
          host = "chaosdorf";
	        hostname = "shells.chaosdorf.de";
	        user = "rappet";
        };
        services = {
          hostname = "services.rappet.xyz";
        };
      };
    };
    topgrade = {
      enable = true;
      settings = {
        misc = {};
        linux.home_manager_arguments = ["--flake" "/home/rappet/stash/nixfiles/home"];
      };
    };
  };

  home.sessionVariables = {
    PATH = "\$HOME/.cargo/bin:\$PATH";
  };

  xsession.windowManager.i3 =
    if pkgs.stdenv.isLinux then {
      enable = true;
      config = {
        modifier = "Mod1";
        terminal = "$HOME/.nix-profile/bin/kitty";
      };
    } else { };

  services.gpg-agent =
    if pkgs.stdenv.isLinux then {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    } else { };
}
