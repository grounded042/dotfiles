# To update:
# 1. Check new version: curl -s https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r .version
# 2. Regenerate package-lock.json:
#      cd /tmp && mkdir cc && cd cc
#      curl -sL https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-<VERSION>.tgz | tar xz --strip-components=1
#      npm install --package-lock-only --ignore-scripts
#      cp package-lock.json ~/code/dotfiles/packages/claude-code/
# 3. Update version and src hash below, set npmDepsHash = ""
# 4. Run: nix build --impure '.#darwinConfigurations.joncarl-macbook.pkgs.claude-code'
#    Copy the "got:" hash into npmDepsHash
# 5. Rebuild
{
  lib,
  buildNpmPackage,
  fetchzip,
  procps,
  bubblewrap,
  socat,
  stdenv,
}:
buildNpmPackage (finalAttrs: {
  pname = "claude-code";
  version = "2.1.101";

  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${finalAttrs.version}.tgz";
    hash = "sha256-nPdrFc7RiVuKVHE7ycCzIoCZN/fdgwjbEcTULennchU=";
  };

  npmDepsHash = "sha256-IR7yWhQ4KcdH762ryL6pUjPskdO1IABLxh+82/Ki3tY=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    substituteInPlace cli.js --replace-fail '#!/bin/sh' '#!/usr/bin/env sh'
  '';

  dontNpmBuild = true;
  env.AUTHORIZED = "1";

  postInstall = ''
    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
      --set DISABLE_INSTALLATION_CHECKS 1 \
      --unset DEV \
      --prefix PATH : ${lib.makeBinPath ([procps] ++ lib.optionals stdenv.hostPlatform.isLinux [bubblewrap socat])}
  '';

  meta = {
    description = "Claude Code CLI by Anthropic";
    homepage = "https://github.com/anthropics/claude-code";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    platforms = lib.platforms.unix;
  };
})
