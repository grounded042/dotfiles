# ScreenCorners

ScreenCorners adds four mouse-transparent black corner masks and a subtle inward
shadow along every edge of each connected display. The overlays join every
Space and remain visible over fullscreen apps. It runs independently of
NativeBar and requires no special permissions.

Edge shadows sit above application windows but below NativeBar. Corner masks
remain above both so the display silhouette stays intact.

Enable its package and user launch agent through `current_system.nix`:

```nix
screenCorners = true;
```

The default 19-point radius corresponds to 38 pixels on a 2× MacBook display.
Override it through the launch environment when tuning against another panel:

```nix
EnvironmentVariables.SCREEN_CORNERS_RADIUS = "12";
```

Diagnostics use the `com.joncarl.ScreenCorners` Unified Logging subsystem:

```sh
log stream --level info --style compact \
  --predicate 'subsystem == "com.joncarl.ScreenCorners"'
```
