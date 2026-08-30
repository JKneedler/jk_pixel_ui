import 'package:flutter/widgets.dart';

/// Resolves a jk_pixel_ui-relative asset path (e.g.
/// 'images/ui/buttons/charcoal-gold/button-primary.png') to an AssetImage
/// Flutter loads from THIS package's own bundled assets, regardless of
/// which app is consuming it. Every AssetImage/Image built from a path
/// under this package's images/ui/ tree — inside this package's own
/// widgets and at any consuming app's call sites that reference a texture
/// this package owns directly (rather than through one of its widgets) —
/// must go through this helper instead of a bare AssetImage(path), or
/// Flutter will look for the file in the CONSUMING app's asset bundle
/// instead and fail to find it.
AssetImage jkAsset(String relativePath) =>
    AssetImage(relativePath, package: 'jk_pixel_ui');
