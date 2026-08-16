{ pkgs, lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "opencode";
  version = "1.18.18";

  src = fetchzip {
    url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
    sha256 = "sha256-H+EDiYUQMie5kUW/K/egC80AeImppIBXtlbeA/hCkaM=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/bin
    cp opencode $out/bin/
    chmod +x $out/bin/opencode
  '';

  meta = with lib; {
    description = "AI coding agent, built for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = [];
  };
}
