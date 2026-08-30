import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_cubit.dart';
import '../constants.dart';
import '../jk_asset.dart';
import 'qv_inset_background.dart';

// Bordered 9-slice geometry for the fraction-fill bar image AND its inset
// background — both are sized/sliced to match (background-<type>-<suffix>.png
// counterparts the bar-<resource>-<suffix>.png assets), unlike
// QvInsetBackground's own fixed STANDARD_BORDER_SLICE/MIN_SIZE which is too
// large for a compact bar. See the *_SLICE and *_MIN_SIZE constants in
// constants.dart for why each variant needs its own min size (tied to that
// asset's own border inset).
enum QvBarSize {
  small(
    assetSuffix: 'small',
    slice: SMALL_BAR_SLICE,
    minSize: SMALL_BAR_MIN_SIZE,
  ),
  mini(
    assetSuffix: 'mini',
    slice: MINI_BAR_SLICE,
    minSize: MINI_BAR_MIN_SIZE,
  );

  final String assetSuffix;
  final Rect slice;
  final Size minSize;

  const QvBarSize({
    required this.assetSuffix,
    required this.slice,
    required this.minSize,
  });
}

// Which resource's baked-color bar asset to use — an open, const-
// constructible class (not a closed enum) so a consuming app can register
// its own resource/color without forking this widget; images/ui/bars/
// ships health/mana/exp/fire/ice out of the box (each has its own
// pre-colored PNG per QvBarSize, generated from the same template via
// retheme_color.py). A new resource just needs its own
// <prefix>-bar-<size>.png pair bundled by the consuming app under the same
// images/ui/bars/ path — see jkAsset's doc comment for why that only
// works if the app also declares that asset path itself, since a bare
// resource with a new prefix isn't one jk_pixel_ui bundles.
class QvBarResource {
  final String assetPrefix;
  const QvBarResource({required this.assetPrefix});

  static const health = QvBarResource(assetPrefix: 'health');
  static const mana = QvBarResource(assetPrefix: 'mana');
  static const exp = QvBarResource(assetPrefix: 'exp');
  static const fire = QvBarResource(assetPrefix: 'fire');
  static const ice = QvBarResource(assetPrefix: 'ice');
}

// Fraction-fill resource bar: a bordered 9-slice bar image (QvBarResource +
// QvBarSize pick the color/geometry) stacked over an inset background of the
// same size variant, with fully custom overlay content. The bar image's own
// border only wraps the filled portion (FractionallySizedBox), so the
// unfilled remainder just shows the inset background underneath, with no
// fill-bar border of its own.
class QvBar extends StatelessWidget {
  const QvBar({
    super.key,
    required this.currentValue,
    required this.maxValue,
    required this.child,
    this.resource = QvBarResource.health,
    this.size = QvBarSize.small,
    this.insetBackgroundType = QvInsetBackgroundType.surface,
    this.height = 30,
    this.width,
  });

  final int currentValue;
  final int maxValue;
  // Overlay content — fully caller-controlled (text, icon, whatever else).
  final Widget child;
  final QvBarResource resource;
  final QvBarSize size;
  final QvInsetBackgroundType insetBackgroundType;
  final double height;
  final double? width;

  static const _padding = EdgeInsets.all(0);

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    final fraction =
        maxValue > 0 ? (currentValue / maxValue).clamp(0.0, 1.0) : 0.0;
    final barAssetPath =
        'images/ui/bars/${resource.assetPrefix}-bar-${size.assetSuffix}.png';
    final backgroundAssetPath =
        'images/ui/backgrounds/$themeId/background-${insetBackgroundType.name}-${size.assetSuffix}.png';
    // Below size.minSize, the slice's fixed corners overlap and paintImage
    // throws — enforced here (padding included) so no caller can pass a
    // height that crashes, or shrinks either the bar or background image
    // below its own corners into a borderless flat box.
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: size.minSize.width + _padding.horizontal,
        minHeight: size.minSize.height + _padding.vertical,
      ),
      child: Container(
        height: height,
        width: width,
        padding: _padding,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: jkAsset(backgroundAssetPath),
            centerSlice: size.slice,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
        child: Stack(
          children: [
            // A plain FractionallySizedBox(widthFactor: fraction) can paint
            // this fill narrower than size.minSize once currentValue/
            // maxValue is a small enough ratio (e.g. a character down at
            // 7/160 HP) — the same "corners overlap and paintImage throws"
            // failure the outer ConstrainedBox above already guards the
            // whole bar against, just hitting the inner fill instead. Floor
            // a nonzero fraction's rendered width at the safe minimum
            // rather than crash every frame; a genuinely empty bar
            // (fraction == 0) stays at 0 width instead of showing a
            // phantom sliver of fill.
            LayoutBuilder(builder: (context, constraints) {
              final rawWidth = constraints.maxWidth * fraction;
              final fillWidth =
                  fraction <= 0 ? 0.0 : math.max(rawWidth, size.minSize.width);
              return Container(
                width: fillWidth,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: jkAsset(barAssetPath),
                    centerSlice: size.slice,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              );
            }),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
