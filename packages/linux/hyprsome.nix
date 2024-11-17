{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, Security
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

  cargoSha256 = "sha256-wqoU9UfXDmf7KIHgFif5rZfZY8Zu0SsaMVfwTtXLzHg=";


  meta = with lib; {
    description = "multimonitor support for hyprland";
    homepage = "https://github.com/tghelew/hyprsome";
    license = licenses.mit;
    maintainers = with maintainers; [ tghelew ];
    mainProgram = "hyprsome";
  };
}
