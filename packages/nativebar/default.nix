{
  lib,
  stdenv,
  swift,
  swiftPackages,
}:
stdenv.mkDerivation {
  pname = "nativebar";
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
    export SWIFTPM_MODULECACHE_OVERRIDE="$TMPDIR/swift-module-cache"
    export CLANG_MODULE_CACHE_PATH="$TMPDIR/clang-module-cache"
    swift build -c release --disable-sandbox --scratch-path .build
    runHook postBuild
  '';

  # nixpkgs' Darwin SwiftPM wrapper does not expose XCTest to `swift test`.
  # Run the test suite with the host Xcode toolchain before building this package.
  doCheck = false;

  installPhase = ''
    runHook preInstall
    app="$out/Applications/NativeBar.app"
    mkdir -p "$app/Contents/MacOS" "$out/bin"
    cp .build/release/NativeBar "$app/Contents/MacOS/NativeBar"
    cp ${./Info.plist} "$app/Contents/Info.plist"
    ln -s ../Applications/NativeBar.app/Contents/MacOS/NativeBar "$out/bin/nativebar"
    runHook postInstall
  '';

  meta = {
    description = "Native, event-driven macOS status bar";
    mainProgram = "nativebar";
    platforms = lib.platforms.darwin;
  };
}
