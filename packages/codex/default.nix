{
  lib,
  stdenv,
  fetchzip,
}: let
  version = "0.149.0";

  codeModeHost = fetchzip {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-aarch64-apple-darwin.tar.gz";
    hash = "sha256-OHuBjl8ILtXNaHc+iwCqA0EkE9wCxJTzG8tfKGjZx28=";
    stripRoot = false;
  };
in
  stdenv.mkDerivation {
    pname = "codex";
    inherit version;

    src = fetchzip {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-aarch64-apple-darwin.tar.gz";
      hash = "sha256-uJU6Ik+/UpVuDgOl3xot9X3wI6lVQf0oNBOeVZVlgjs=";
      stripRoot = false;
    };

    installPhase = ''
      mkdir -p $out/bin
      cp codex-aarch64-apple-darwin $out/bin/codex
      cp ${codeModeHost}/codex-code-mode-host-aarch64-apple-darwin $out/bin/codex-code-mode-host
      chmod +x $out/bin/codex $out/bin/codex-code-mode-host
    '';

    meta = with lib; {
      description = "OpenAI Codex CLI, an AI coding agent for the terminal";
      homepage = "https://github.com/openai/codex";
      license = licenses.asl20;
      mainProgram = "codex";
      platforms = platforms.darwin;
      maintainers = [];
    };
  }
