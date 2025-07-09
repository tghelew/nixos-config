{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "tomatrix";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "erikh";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ZdsHNUPtQ1rkfOxGioZGxtToYCSSqKUpdBglQnvwGic=";
  };

  cargoHash = "sha256-29M8/9XyfBkrXQ7/Rg+88NXIIUaNb3IdiOa8Fu0pDD0=";

  meta = with lib; {
    description = "Matrix any text document";
    homepage = "https://github.com/erikh/tomatrix";
    license = licenses.unlicense;
    maintainers = [];
  };
}
