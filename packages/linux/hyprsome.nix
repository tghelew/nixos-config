{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "hyprsome";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "tghelew";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/6vNFh7n6WvYerrL8m9sgUKsO2KKj7/f8xc4rzHy9Io=";
  };

  cargoHash = "sha256-jQNdIkq2iRDNWskd5f8kX6q9BO/CBSXhMH41WNRft8E=";


  meta = with lib; {
    description = "multimonitor support for hyprland";
    homepage = "https://github.com/tghelew/hyprsome";
    license = licenses.mit;
    maintainers = [];
    mainProgram = "hyprsome";
  };
}
