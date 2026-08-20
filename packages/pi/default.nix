{
  pkgs,
  lib,
  stdenv,
  fetchzip,
}:
stdenv.mkDerivation rec {
  pname = "pi";
  version = "0.84.2";

  src = fetchzip {
    url = "https://github.com/earendil-works/pi/releases/download/v${version}/pi-darwin-arm64.tar.gz";
    sha256 = "sha256-jrp29PSJxeyVzD7JuUoyu/O8R0ItZ3Ei6Yc2TS087bk=";
  };

  # The pi binary resolves its wasm module, native addon, and node_modules
  # relative to its own location, so the whole release directory has to be
  # installed together rather than just the executable.
  installPhase = ''
    mkdir -p $out/libexec/pi $out/bin
    cp -r . $out/libexec/pi/
    chmod +x $out/libexec/pi/pi
    ln -s $out/libexec/pi/pi $out/bin/pi
  '';

  meta = with lib; {
    description = "AI coding agent, built for the terminal";
    homepage = "https://github.com/earendil-works/pi";
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = [];
  };
}
