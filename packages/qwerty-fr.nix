{ lib, stdenv, fetchurl, unzip, installShellFiles, ... }:

stdenv.mkDerivation rec {
  pname = "qwerty-fr";
  version = "0.7.2";

  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/releases/download/v${version}/${pname}_${version}_linux.zip";
    sha256 = "sha256-Ns2H5UU2WHuAt6NIPfR7xPPh6XwcwPpScbPk55p7fcs=";
  };

  nativeBuildInputs = [unzip installShellFiles];

  doCheck = false;

  dontConfigure = true;
  dontPatch = true;
  dontBuild = true;

  sourceRoot = "usr/";

  installPhase = ''
    mkdir -p $out/share/X11
    mkdir -p $out/share/doc
    cp -a  share/X11/* $out/share/X11/
    cp -a  share/doc/* $out/share/doc/
    installManPage share/man/man7/qwerty-fr.7.gz
  '';

  meta = with lib; {
    description = "Keyboard layout based on the QWERTY layout for French";
    longDescription =''
      Keyboard layout based on the QWERTY layout with extra symbols and diacritics
      so that typing both in French and English is easy and fast. It is also easy to learn!
    '';
    homepage = "https://github.com/jmattheis/gruvbox-dark-gtk";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = [ maintainers.nomisiv ];
  };
}
