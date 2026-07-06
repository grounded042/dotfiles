{ pkgs, lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "opencode";
  version = "1.17.8";

  src = fetchzip {
    url = "https://github.com/sst/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
    sha256 = "sha256-cE10nzK7Wd8t+0Hlbs3+z7wynYNXHn/msNQHZ/L7p6I=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/bin
    cp opencode $out/bin/
    chmod +x $out/bin/opencode
  '';

  meta = with lib; {
    description = "AI coding agent, built for the terminal";
    homepage = "https://github.com/sst/opencode";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = [];
  };
}
