{colors, fonts, ... }:

{
  layer = "top";
  position = "top";
  spacing = 0;
  height = 34;
  mod = "dock";
  modules-left = [
    "hyprland/workspaces"
    "cpu"
    "memory"
  ];

  modules-center = [
    "clock"
    "hyprland/submap"
  ];

  module-right = [
    "tray"
    "network"
    "bluetooth"
    "wireplumber"
    "battery"
    "backlight"
    "custom/power"
  ];

  "hyprland/submap" = {
    format = " {}";
    max-length = 8;
    tooltip = false;
  };

  "hyprland/workspaces" = {
    on-click = "activate";
    format = "{icon}";
    show-special = true;
    format-icons =  {
      default = "";
      "1" = "";
      "2" = "";
      "3" = "";
      "4" = "";
      "5" = "";
		  "6" = "";
		  "7" = "";
		  "8" = "";
		  "9" = "";
		  active = "";
		  urgent = "";
		  special = "";
	  };
  };

  memory = {
    interval = 5;
    format = " {}%";
    max-length = 10;
  };

  cpu = {
    interval = 1;
    format = "   {}% ";
    max-length = 10;
  };

  clock = {
    format = " {:%A %d %B %Y, %R}";
    tooltip-format = "<tt><small>{calendar}</small></tt>";
    calendar = {
      mode = "year";
      mode-mon-col = 3;
      weeks-pos = "left";
      on-scroll = 1;
      on-right-click = "mode";
      format = {
        months   = "<span color ='${builtins.replaceStrings ["\""] [""] colors.dimwhite}><b>{}</b></span>'";
        days     = "<span color ='${builtins.replaceStrings ["\""] [""] colors.magenta}><b>{}</b></span>'";
        weeks    = "<span color ='${builtins.replaceStrings ["\""] [""] colors.green}><b>{}</b></span>'";
        weekdays = "<span color ='${builtins.replaceStrings ["\""] [""] colors.yellow}><b>{}</b></span>'";
        today    = "<span color ='${builtins.replaceStrings ["\""] [""] colors.red}><b><u>{}</u></b></span>'";
      };
    };
    action = {
      on-click-right = "mode";
      on-scroll-up = "shift_up";
      on-scroll-down = "shift_down";
    };
  };

  network = {
    interval = 5;
    format-wifi = "{icon} {signalStrength}%";
    format-disconnected = "";
    formart-ethernet = " {ifname}";
    format-icons = [""];
    tooltip-format-wifi = "{icon} {essid}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
    tooltip-format-ethernet =  " {ipaddr}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";

  };

  bluetooth = {
    format = "";
    format-on = "";
    format-off = "";
    format-disabled = "";
    format-connected = "";
    tooltip-format = " {status}  {num_connections}";
  };

  wireplumber = {
    format = " {volume}%";
    format-muted = "";
  };

  battery = {
    design-capacity = true;
    format = "{icon} {capacity}%";
    format-icons = {
      default = [
      ""
      ""
      ""
      ""
      ""
    ];
      charging = [""];
    };
  };

  backlight = {
    format = "{icon} {percent}%";
    format-icons = ["" "" "" ""];
  };

  "custom/power" = {
    format = "";
    tooltip = false;
    on-click = "$NIXOS_CONFIG_BIN/rofi/powermenu";

  };

  tray = {
    icon-size = 16;
    spacing = 10;
  };


}