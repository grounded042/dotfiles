{ pkgs, lib, stdenv, fetchzip }:

let
  platform =
    if stdenv.isAarch64 && stdenv.isDarwin then "aarch64-apple-darwin"
    else if stdenv.isx86_64 && stdenv.isLinux then "x86_64-unknown-linux-musl"
    else throw "rtk: unsupported platform ${stdenv.system}";

  hashes = {
    aarch64-apple-darwin = "sha256-tJm8/ouMAEWK/W6pbkuA8VQ73k3EMoy5q1s1MxR83mU=";
    x86_64-unknown-linux-musl = lib.fakeHash;
  };
in
stdenv.mkDerivation rec {
  pname = "rtk";
  version = "0.42.4";

  src = fetchzip {
    url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-${platform}.tar.gz";
    sha256 = hashes.${platform};
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/bin
    cp rtk $out/bin/
    chmod +x $out/bin/rtk
  '';

  meta = with lib; {
    description = "Save tokens in AI agents";
    homepage = "https://github.com/rtk-ai/rtk";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" "x86_64-linux" ];
    mainProgram = "rtk";
  };
}
