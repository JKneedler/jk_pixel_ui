import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_cubit.dart';
import '../constants.dart';
import '../jk_asset.dart';

enum QvInsetBackgroundType {
  surface,
  secondary,
  surfaceContainer;

  // barSize is null for the standard (STANDARD_BORDER_SLICE/MIN_SIZE)
  // background-<type>.png asset; QvInsetBackground's own optional `size`
  // passes a QvBarSize to instead reach for the smaller-bordered
  // background-<type>-<suffix>.png sibling QvBar's bars already use (see
  // QvBarSize's own doc comment in constants.dart).
  String assetPath(String themeId, {QvBarSize? barSize}) {
    final suffix = barSize == null ? '' : '-${barSize.assetSuffix}';
    switch (this) {
      case QvInsetBackgroundType.surface:
        return 'images/ui/backgrounds/$themeId/background-surface$suffix.png';
      case QvInsetBackgroundType.secondary:
        return 'images/ui/backgrounds/$themeId/background-secondary$suffix.png';
      case QvInsetBackgroundType.surfaceContainer:
        return 'images/ui/backgrounds/$themeId/background-surface-container$suffix.png';
    }
  }
}

class QvInsetBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final QvInsetBackgroundType type;
  final bool enabled;
  // Opts into a smaller 9-slice border than the standard 36px-minimum one
  // (down to QvBarSize.small's 20px) — for a compact box (e.g. a stat
  // pill) where the standard border reads oversized relative to its
  // content. Needs a background-<type>-<suffix>.png asset to exist for
  // this type; not every QvInsetBackgroundType has small/mini variants
  // generated yet.
  final QvBarSize? size;
  const QvInsetBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    this.width,
    this.height,
    this.type = QvInsetBackgroundType.secondary,
    this.enabled = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    final slice = size?.slice ?? STANDARD_BORDER_SLICE;
    final minSize = size?.minSize ?? STANDARD_BORDER_MIN_SIZE;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize.width,
        minHeight: minSize.height,
      ),
      child: Container(
        padding: padding,
        width: width,
        height: height,
        decoration: enabled
            ? BoxDecoration(
                image: DecorationImage(
                  image: jkAsset(type.assetPath(themeId, barSize: size)),
                  centerSlice: slice,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              )
            : null,
        child: child,
      ),
    );
  }
}
