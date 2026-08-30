# jk_pixel_ui

A shared pixel-art Flutter UI kit — 9-sliced button/border/background/bar
textures, the widgets that render them, and a theme engine — extracted from
[Questvale](https://github.com/JKneedler/questvale) so the same components
and textures can be reused (and updated in one place) across multiple apps.

## What's in here

- **Widgets** (`lib/src/widgets/`) — generic building blocks: buttons, cards,
  borders, backgrounds, resource bars, modal sheets, form controls, text
  styles, and small animation wrappers. Exported from the single barrel file
  `lib/jk_pixel_ui.dart`.
- **Theme engine** (`lib/src/theme/`) — `ThemeCubit`/`ThemeState`, driven by
  an app-supplied `ThemePersistence` implementation (the library has no
  opinion on *where* the chosen theme is stored — that's the consuming app's
  job).
- **Themes & geometry constants** (`lib/src/constants.dart`) — the three
  shipped palettes (`charcoal-gold`, `sunrise-peach`, `violet-dusk`) plus the
  9-slice geometry (`STANDARD_BORDER_SLICE`, bar/border slice + min-size
  constants) every texture in `images/ui/` is built against.
- **Textures** (`images/ui/`) — the actual PNG assets, one subtree per theme.

## Using it from another app

Not yet published to pub.dev — consume it as a path or git dependency:

```yaml
dependencies:
  jk_pixel_ui:
    path: ../jk_pixel_ui   # local development
    # or, once pushed:
    # git:
    #   url: https://github.com/JKneedler/jk_pixel_ui.git
    #   ref: v0.1.0
```

Then:

```dart
import 'package:jk_pixel_ui/jk_pixel_ui.dart';
```

Any texture this package bundles must be loaded through the `jkAsset(String
path)` helper (not a bare `AssetImage`/`Image.asset` call) so Flutter resolves
it from this package's own asset bundle rather than the consuming app's.

## Design conventions

- Every raised-container texture (`button-*`, `background-*`) shades
  asymmetrically: the **top** cap carries the Light/highlight accent, the
  **bottom** cap carries the Dark accent plus a soft drop shadow — never a
  mirror of each other. See `qv_background.dart`'s doc comment before adding
  a new `-no-top`/`-no-bottom` variant.
- New texture variants should be generated with `retheme_color.py` (dry-run
  first, verify full color coverage, then apply for real) rather than by
  hand-editing pixels or naively flipping/rotating a sibling asset.
