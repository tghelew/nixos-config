final: prev:
{
waybar = prev.waybar.overrideAttrs (oldAttrs: {
  src = final.fetchFromGithub {
    owner = "Alexays";
    repo = "waybar";
    rev = "4c0347d9f243322352a18bdf2c4d4bbcde37163e";
    sha256 = "sha256-Y4Gb1RH1ShDpH1w0xmhFM0UjdecP6JXbUo50mwu5kek=";
  };
  mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
});
}
