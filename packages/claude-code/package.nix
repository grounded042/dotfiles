# To update:
# 1. Check new version: curl -s https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r .version
# 2. Update version below, set hash = ""
# 3. Run: nix build --impure '.#darwinConfigurations.joncarl-macbook.pkgs.claude-code'
#    Copy the "got:" hash into hash
# 4. Rebuild
{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  procps,
  bubblewrap,
  socat,
}: let
  platform =
    if stdenv.hostPlatform.isDarwin
    then "darwin"
    else "linux";
  arch =
    if stdenv.hostPlatform.isAarch64
    then "arm64"
    else "x64";
  suffix =
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isMusl
    then "-musl"
    else "";
  platformStr = "${platform}-${arch}${suffix}";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "claude-code";
    version = "2.1.214";

    src = fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code-${platformStr}/-/claude-code-${platformStr}-${finalAttrs.version}.tgz";
      hash = "sha256-9tOMzSZaBMsBFOA+jTYzd2/Ga1aCqPPPElEvXBLP6fs=";
    };

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      mkdir -p $out/bin
      cp claude $out/bin/claude
      chmod +x $out/bin/claude
      wrapProgram $out/bin/claude \
        --set DISABLE_AUTOUPDATER 1 \
        --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --unset DEV \
        ${lib.optionalString stdenv.hostPlatform.isLinux
        "--prefix PATH : ${lib.makeBinPath [procps bubblewrap socat]}"}
    '';

    meta = {
      description = "Claude Code CLI by Anthropic";
      homepage = "https://github.com/anthropics/claude-code";
      license = lib.licenses.unfree;
      mainProgram = "claude";
      platforms = ["aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux"];
    };
  })
