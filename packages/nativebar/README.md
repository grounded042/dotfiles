# NativeBar

NativeBar is a native, event-driven replacement for this repository's
SketchyBar configuration. Select the bar for each machine in
`current_system.nix`:

```nix
# One of: "sketchybar", "nativebar", or "none".
statusBar = "nativebar";
```

Selecting NativeBar installs the package and enables its user launch agent.
The selector is mutually exclusive, so SketchyBar is disabled by the same
configuration.

The first prototype provides:

- a 32-point AppKit panel on each display using native Liquid Glass on macOS
  26 or newer, with a material fallback and a separate, mouse-transparent fade
  beneath it;
- glass tint and foreground colors that follow macOS light or dark appearance;
- ten noninteractive Space indicators, with the active Space queried from
  yabai after AppKit reports a Space change;
- a clock scheduled on exact minute boundaries; and
- native, event-driven Wi-Fi, volume, and battery indicators; and
- persistent out-of-process extensions using newline-delimited JSON.

## Development

```sh
swift test --package-path packages/nativebar
swift run --package-path packages/nativebar NativeBar
```

Wi-Fi connection state does not require special permission. To additionally
show the SSID, launch the packaged app once with `--request-location` and grant
Location Services access:

```sh
open result/Applications/NativeBar.app --args --request-location
```

The app bundle is required because it contains the Location Services usage
description. If access is denied or macOS redacts the SSID, NativeBar keeps
showing the connection-state icon without a network name.

Running the prototype does not stop SketchyBar, so the bars will overlap. Stop
the prototype with `pkill NativeBar` after visual testing.

## Logging

NativeBar writes lifecycle and component diagnostics to macOS Unified Logging
under the `com.joncarl.NativeBar` subsystem. Stream new entries with:

```sh
log stream --level info --style compact \
  --predicate 'subsystem == "com.joncarl.NativeBar"'
```

Inspect errors retained from the last hour with:

```sh
log show --last 1h --style compact \
  --predicate 'subsystem == "com.joncarl.NativeBar" AND messageType >= error'
```

Extension launch failures, exits, invalid protocol messages, and stderr are
tagged with the extension ID. Stderr text and local extension-directory paths
are marked private; SSIDs are never logged.

## Extensions

NativeBar reads manifests from `~/.config/nativebar/extensions.d`. Set
`NATIVEBAR_EXTENSION_DIRS` to a colon-separated list to use other directories.

Each `*.json` manifest uses protocol version 1:

```json
{
  "id": "example",
  "protocol": 1,
  "position": "right",
  "order": 20,
  "executable": "/absolute/path/to/nativebar-example-status",
  "arguments": []
}
```

The executable must use an absolute path and remain running. Whenever its
display changes, it writes and flushes one JSON object per line:

```json
{"symbol":"hammer.fill","label":"Nix","color":"#73daca"}
```

`symbol` is an SF Symbol name. `label` and `color` are optional. Invalid lines
are ignored. A terminated extension is restarted with exponential backoff, up
to 64 seconds. Adding, changing, or removing manifests reloads the extension
set without restarting NativeBar.

### Nix extension example

An extension can be completely declarative in `currentSystem.home`. This
example creates a persistent executable in the Nix store and writes its
manifest to NativeBar's default extension directory:

```nix
home = {
  pkgs,
  ...
}: let
  exampleStatus = pkgs.writeShellApplication {
    name = "nativebar-example-status";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      printf '%s\n' \
        '{"symbol":"hammer.fill","label":"Nix","color":"#73daca"}'
      exec sleep infinity
    '';
  };
in {
  home.packages = [exampleStatus];

  xdg.configFile."nativebar/extensions.d/example.json".text =
    builtins.toJSON {
      id = "example";
      protocol = 1;
      position = "right";
      order = 20;
      executable = "${exampleStatus}/bin/nativebar-example-status";
      arguments = [];
    };
};
```

A left-positioned extension appears after the Spaces; a right-positioned
extension appears before Wi-Fi. Lower `order` values appear first within their
position.
