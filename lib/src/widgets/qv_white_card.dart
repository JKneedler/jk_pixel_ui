import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_cubit.dart';
import '../constants.dart';
import '../jk_asset.dart';

class QVWhiteCard extends StatelessWidget {
  const QVWhiteCard({
    super.key,
    required this.child,
    required this.onTap,
    this.padding =
        const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 40),
    this.decorationImage,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback onTap;
  // An arbitrary caller-supplied image provider (not necessarily one of
  // this package's own bundled textures) — pass a plain AssetImage(...)
  // for an app asset, or jkAsset(...) for one of this package's own.
  final ImageProvider? decorationImage;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final themeId = context.watch<ThemeCubit>().state.theme.id;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Center(
              child: FractionallySizedBox(
                widthFactor: .95,
                heightFactor: .95,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    image: decorationImage != null
                        ? DecorationImage(
                            image: decorationImage!,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.none,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                padding: padding,
                foregroundDecoration: BoxDecoration(
                  image: DecorationImage(
                    image: jkAsset(
                        'images/ui/borders/$themeId/border-primary.png'),
                    centerSlice: STANDARD_BORDER_SLICE,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
