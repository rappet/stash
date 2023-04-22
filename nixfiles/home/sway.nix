{ pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in
{
  home.packages =
    if isLinux then with pkgs; [
      kitty
      bemenu
      waybar
      pulseaudioFull
      brightnessctl
    ] else [ ];

  wayland.windowManager.sway =
    if isLinux then {
      enable = true;
      config = rec {
        modifier = "Mod4";
        terminal = "kitty";
        menu = "${pkgs.bemenu}/bin/bemenu-run -l 8 --fn 'FiraCode 12' --tb '#0284c7' --tf '#ffffff'";
        bars = [ ];
        startup = [
          { command = "${pkgs.mako}/bin/mako"; }
        ];
        keybindings = lib.mkOptionDefault {
          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume 0 +5%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudioFull}/bin/pactl set-sink-volume 0 -5%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudioFull}/bin/pactl set-sink-mute 0 toggle";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%+";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";
        };

      };
    } else { };

  programs.waybar =
    if isLinux then {
      enable = true;
      settings.mainBar = {
        layer = "bottom";
        position = "bottom";
        height = 30;

        modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
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
    } else { };
}
