{ pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in
{
  home.packages =
    if isLinux then
      with pkgs;
      [
        kitty
        bemenu
        waybar
        pulseaudioFull
        brightnessctl
      ]
    else
      [ ];

  wayland.windowManager.sway =
    if isLinux then
      {
        enable = true;
        config = rec {
          modifier = "Mod4";
          terminal = "kitty";
          menu = "${pkgs.bemenu}/bin/bemenu-run -l 8 --fn 'FiraCode 12' --tb '#0284c7' --tf '#ffffff'";
          bars = [ ];
          keybindings = lib.mkOptionDefault {
            "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume 0 +5%";
            "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume 0 -5%";
            "XF86AudioMute" = "exec ${pkgs.pulseaudioFull}/bin/pactl set-sink-mute 0 toggle";
            "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%+";
            "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";
          };

        };
      }
    else
      { };

  programs.waybar =
    if isLinux then
      {
        enable = true;
        settings.mainBar = {
          layer = "bottom";
          position = "bottom";
          height = 30;

          modules-left = [
            "sway/workspaces"
            "sway/mode"
            "wlr/taskbar"
          ];
          modules-center = [ "sway/window" ];
          modules-right = [
            "temperature"
            "bluetooth"
            "tray"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "battery"
            "clock"
          ];
        };
        systemd.enable = true;
      }
    else
      { };

  services.mako =
    if isLinux then
      {
        enable = true;
        backgroundColor = "#3b4045";
        borderRadius = 8;
        borderSize = 0;
        padding = "8";
      }
    else
      { };

  gtk =
    if isLinux then
      {
        enable = true;

        iconTheme = {
          name = "breeze-dark";
          package = pkgs.libsForQt5.breeze-icons;
        };

        theme = {
          name = "Breeze-Dark";
          package = pkgs.libsForQt5.breeze-gtk;
        };

        cursorTheme = {
          name = "breeze_cursors";
          package = pkgs.libsForQt5.breeze-icons;
        };

        gtk3.extraConfig = {
          Settings = ''
            gtk-application-prefer-dark-theme=1
          '';
        };

        gtk4.extraConfig = {
          Settings = ''
            gtk-application-prefer-dark-theme=1
          '';
        };
      }
    else
      { };

  home.sessionVariables.GTK_THEME = "Breeze-Dark";
}
