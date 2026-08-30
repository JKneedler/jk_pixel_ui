import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_cubit.dart';
import '../constants.dart';
import '../jk_asset.dart';

enum QvCardBorderType {
  rarity,
  primary,
  surface,
  surfaceContainer,
}

class QvCardBorder extends StatelessWidget {
  final QvCardBorderType type;
  // Only consulted when type == QvCardBorderType.rarity — the caller
  // supplies its own asset path (e.g. Questvale passes
  // someRarity.borderAssetPath) since this library has no concept of
  // "rarity" itself, just a border that can point at an arbitrary image.
  final String? rarityBorderAssetPath;
  final double width;
  final double height;
  final Widget child;
  final Color bgColor;
  final double widthFactor;
  final double heightFactor;
  final EdgeInsets padding;

  const QvCardBorder(
      {super.key,
      this.type = QvCardBorderType.rarity,
      this.rarityBorderAssetPath,
      required this.child,
      this.width = 0,
      this.height = 0,
      this.bgColor = Colors.transparent,
      this.widthFactor = .9,
      this.heightFactor = .9,
      this.padding = const EdgeInsets.all(12)});

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;

    String getBorderImage() {
      switch (type) {
        case QvCardBorderType.rarity:
          return rarityBorderAssetPath!;
        case QvCardBorderType.primary:
          return 'images/ui/borders/$themeId/border-primary-mini.png';
        case QvCardBorderType.surface:
          return 'images/ui/borders/$themeId/border-surface-mini.png';
        case QvCardBorderType.surfaceContainer:
          return 'images/ui/borders/$themeId/border-surface-container-mini.png';
      }
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: SizedBox(
        height: height > 0 ? height : null,
        width: width > 0 ? width : null,
        child: Stack(
          children: [
            // Positioned (not a plain Center) so this layer is ignored for
            // the Stack's own intrinsic sizing — only the border+child
            // Container below drives that, sized off child's content. That
            // keeps this safe in unbounded-height contexts (e.g. a
            // ListView.builder item), where a non-positioned
            // FractionallySizedBox here would otherwise crash.
            Positioned.fill(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: widthFactor,
                  heightFactor: heightFactor,
                  child: Container(
                    color: bgColor,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: jkAsset(getBorderImage()),
                  centerSlice: STANDARD_BORDER_SLICE,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
