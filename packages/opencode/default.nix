{
  lib,
  stdenv,
  fetchzip,
}:
stdenv.mkDerivation rec {
  pname = "opencode";
  version = "2.0.27";

  src = fetchzip {
    url = "https://registry.npmjs.org/@opencode/cli-darwin-arm64/-/cli-darwin-arm64-${version}.tgz";
    sha256 = "sha256-crQzYDshMHtvopkRWo7srTcgpVB+KD9pILXlpXd6pWs=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp bin/opencode $out/bin/
    chmod +x $out/bin/opencode
  '';

  meta = with lib; {
    description = "AI coding agent, built for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
    license = licenses.mit;
    platforms = ["aarch64-darwin"];
    maintainers = [];
  };
}
