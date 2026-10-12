{
  lib,
  stdenv,
  swift,
  swiftPackages,
}:
stdenv.mkDerivation {
  pname = "screen-corners";
  version = "0.1.0";

  src = lib.cleanSourceWith {
    src = ./.;
    filter = path: type:
      lib.cleanSourceFilter path type
      && !(lib.hasPrefix ".build" (baseNameOf path));
  };

  nativeBuildInputs = [swift swiftPackages.swiftpm];

  buildPhase = ''
    runHook preBuild
    export NIX_CC_WRAPPER_SUPPRESS_TARGET_WARNING=1
    export SWIFTPM_MODULECACHE_OVERRIDE="$TMPDIR/swift-module-cache"
    export CLANG_MODULE_CACHE_PATH="$TMPDIR/clang-module-cache"
    swift build -c release --disable-sandbox --scratch-path .build
    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    app="$out/Applications/ScreenCorners.app"
    mkdir -p "$app/Contents/MacOS" "$out/bin"
    cp .build/release/ScreenCorners "$app/Contents/MacOS/ScreenCorners"
    cp ${./Info.plist} "$app/Contents/Info.plist"
    ln -s ../Applications/ScreenCorners.app/Contents/MacOS/ScreenCorners "$out/bin/screen-corners"
    runHook postInstall
  '';

  meta = {
    description = "Native rounded display-corner overlays for macOS";
    mainProgram = "screen-corners";
    platforms = lib.platforms.darwin;
  };
}
