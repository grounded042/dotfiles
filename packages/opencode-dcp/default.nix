{
  lib,
  buildNpmPackage,
  runCommandLocal,
  jq,
}:
# Vendors @tarquinen/opencode-dcp (an opencode plugin) and its full node_modules
# into the Nix store so opencode never has to install it at runtime. The plugin
# entrypoint (dist/index.js) is symlinked into ~/.config/opencode/plugins/dcp.js
# by modules/opencode.
#
# Upstream ships a prebuilt `dist/`, so there is nothing to build — npm only
# materializes node_modules from the committed lockfile (dontNpmBuild).
#
# To bump: edit the version in package.json, run
#   npm install --package-lock-only --registry=https://registry.npmjs.org/
# in this directory, then rebuild (Nix prints the new npmDepsHash to paste in).
let
  # @opentui ships per-platform native binaries as optionalDependencies, but
  # npm's lockfile generator leaves them un-flagged, so `npm ci` fails EBADPLATFORM
  # on the non-host arch when cross-building (darwin-arm64 + linux-x64). Flag every
  # os/cpu-gated entry optional so npm installs only the matching one. Patching the
  # src (rather than postPatch) keeps the lockfile fetchNpmDeps prefetches and the
  # one npm ci validates identical, and leaves the committed lockfile pristine.
  patchedSrc = runCommandLocal "opencode-dcp-src" {nativeBuildInputs = [jq];} ''
    cp -r ${./.} $out
    chmod -R u+w $out
    jq '.packages |= with_entries(if (.value.os or .value.cpu) then .value.optional = true else . end)' \
      $out/package-lock.json > $out/package-lock.json.tmp
    mv $out/package-lock.json.tmp $out/package-lock.json
  '';
in
  buildNpmPackage {
    pname = "opencode-dcp";
    version = "3.1.13";

    src = patchedSrc;

    npmDepsHash = "sha256-d0WJMqLXg4DIwOR0sJEsUoxpwGe+2GU/UK9huBiZzAU=";

    # Upstream ships prebuilt dist/; we just want node_modules installed.
    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp -r node_modules $out/lib/node_modules
      runHook postInstall
    '';

    meta = with lib; {
      description = "OpenCode plugin that prunes obsolete tool outputs to save tokens";
      homepage = "https://github.com/Opencode-DCP/opencode-dynamic-context-pruning";
      license = licenses.agpl3Plus;
      platforms = ["aarch64-darwin" "x86_64-linux"];
    };
  }
