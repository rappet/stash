# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

with lib.strings;

let
  dedupe-paths = [ "/home" ];
  in
  {
    imports =
      [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./apple-silicon-support
      ../../common.nix
      ../../desktop/desktop.nix
      ../../desktop/develop.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.luks.devices.nixos-asahi-pv.device = "/dev/disk/by-label/nixos-asahi-luks";

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/btrfs".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
  };

  environment.pathsToLink = [ "/libexec" ];

  hardware.asahi = {
    peripheralFirmwareDirectory = ./firmware;
    withRust = true;
    addEdgeKernelConfig = true;
    useExperimentalGPUDriver = true;
  };

  hardware.bluetooth.enable = true;

  services.xserver.videoDrivers = [ "apple" ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  users.users.rappet.extraGroups = [ "networkmanager" ];

  networking.hostName = "ibook-nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  fonts.fontconfig.antialias = true;

  zramSwap = {
    enable = true;
    memoryPercent = 150;
  };

  #services.xserver.windowManager.i3 = {
  #  enable = true;
  #  extraPackages = with pkgs; [
  #    dmenu #application launcher most people use
  #    i3status # gives you the default i3 status bar
  #    i3lock #default i3 screen locker
  #    i3blocks #if you are planning on using i3blocks over i3status
  #  ];
  #};

  environment.systemPackages = with pkgs; [
    alacritty
    wayland
    xdg-utils
    glib
    dracula-theme
    gnome3.adwaita-icon-theme
    swaylock
    swayidle
    grim
    slurp
    wl-clipboard
    bemenu
    mako
  ];

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  programs.sway = {
    enable = true;
    #wrapperFeatures.gtk = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  systemd.timers."dedupe-home" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "24h";
      Unit = "dedupe-home.service";
    };
  };

  systemd.services."dedupe-home" = {
    script = ''
        set -eu
        ${pkgs.duperemove}/bin/duperemove -drh ${concatStringsSep " " dedupe-paths}
   '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;




  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  #];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It’s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

