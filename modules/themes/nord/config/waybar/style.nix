{colors, fonts, ... }:
''
* {
  font-family: Material Design Icons, FontAwesome, Weather Icons, ${fonts.mono.name}
  font-size: 17px;
}

window#waybar {
  background-color: ${colors.black};
  color: ${colors.white};
  border-radius: 8px;
  border-width: 3px;
  border-color: ${colors.brightblack};
  border-style: solid;
}

window#waybar.hidden {
  opacity: 0.1;
}

#window {
  color: ${colors.brightblack};
}

#workspaces,
#submap,
#memory,
#clock,
#tray,
#network,
#bluetooth
#wireplumber
#battery
#backlight
#custom/power,
#cpu {
  color: ${colors.red};
  border-radius: 8px 8px 8px 8px;
}

#memory {
  color: ${colors.green};
  border-radius: 8px 8px 8px 8px;
}

@keyframes button_activate {
	from { opacity: .3 }
	to { opacity: 1.; }
}

#workspaces button {
	border: none;
	color:  #d4d2a9;
	padding: 3px;
	background: transparent;
	box-shadow: none;
}

#workspaces button.active {
	color:  ${colors.blue};
	background: radial-gradient(circle, ${colors.blue} 5%,
                                      ${colors.black} 18%,
                                      ${colors.grey} 23%,
                                      ${colors.dimblack} 24%,
                                      ${colors.grey} 30%);

	animation: button_activate .2s ease-in-out;
}

#workspaces button.urgent {
	color:  ${colors.red};
	background: radial-gradient(circle, ${colors.blue} 20%, ${colors.grey} 30%);
}

#workspaces button.persistent {
	color:  ${colors.brightblack};
}

#workspaces button:hover {
	border: none;
	background: radial-gradient(circle, ${colors.blue} 20%, ${colors.grey}) 30%);
}

#workspaces button.active:hover, #workspaces button.urgent:hover {
	background: inherit;
}

#workspaces,
#submap,
#clock,
#cpu,
#memory,
#backlight,
#battery,
#bluetooth
#wireplumber,
#tray,
#network {
  background-color: ${colors.black};
  padding: 0em 2em;

  font-size: 20px;

  padding-left: 7.5px;
  padding-right: 7.5px;

  padding-top: 2px;
  padding-bottom: 2px;

  margin-top: 10px;
  margin-bottom: 10px;
  margin-right: 10px;
}

#workspaces {
  padding-right: 10px;
}

#bluetooth,
#wireplumber {
  color: ${colors.dimblue};
  padding-left: 10px;
  margin-right: 10px;
  font-size: 25px;
  border-radius: 0px 8px 8px 0px;
  margin-left: -5px;
}


#backlight {
  color: ${colors.dimgrey};
  padding-right: 5px;
  padding-left: 8px;
  font-size: 21.2px;
}

#network {
  padding-left: 0.2em;
  color: ${colors.dimblue};
  border-radius: 8px 0px 0px 8px;
  padding-left: 12px;
  padding-right: 14px;
  font-size: 20px;
  margin-right: -5px;
}

#network.disconnected {
  color: ${colors.brightred};
}

#battery {
  color: ${colors.brightcyan};
  border-radius: 0px 8px 8px 0px;
  padding-right: 2px;
  font-size: 22px;
}

#battery.plugged {
  color: ${colors.brightcyan};
  padding-left: 6px;
  padding-right: 12px;
  font-size: 22px;
}

#battery.charging {
  font-size: 18px;
  padding-right: 13px;
  padding-left: 4px;
}

#battery.full,
#battery.plugged {
  font-size: 22.5px;
  padding-right: 10px;
}

@keyframes blink {
  to {
    background-color: ${colors.dimblack};
    color: ${colors.dimwhite};
  }
}


#clock {
  color: ${colors.brightblack};
  font-family: ${fonts.mono.name};
  font-size: 17px;
  font-weight: bold;
  margin-top: 10px;
  margin-right: 10px;
  margin-bottom: 10px;
  border-radius: 8px 8px 8px 8px;
}

#custom/power{
  color: ${colors.brightred};
  margin-right: 12px;
  border-radius: 8px;
  padding: 0 6px 0 6.8px;
  margin-top: 7px;
  margin-bottom: 7px;
}

tooltip {
  font-family: ${fonts.mono.name};
  border-radius: 8px;
  padding: 15px;
  background-color: #242933;
}

tooltip label {
  font-family: ${fonts.mono.name};
  padding: 5px;
  background-color: #242933;
}

label:focus {
  background-color: ${colors.black};
}

#tray {
  margin-right: 10px;
  margin-top: 10px;
  margin-bottom: 10px;
  font-size: 30px;
  border-radius: 8px 8px 8px 8px;
}

#tray > .passive {
  -gtk-icon-effect: dim;
}

#tray > .needs-attention {
  -gtk-icon-effect: highlight;
  background-color: ${colors.red};
}

#memory,
#cpu {
  font-size: 16px;
}

''
