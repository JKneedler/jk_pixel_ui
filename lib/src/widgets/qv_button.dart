import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_cubit.dart';
import '../constants.dart';
import '../jk_asset.dart';

enum ButtonColor {
  primary,
  secondary,
  surface,
  surfaceContainer,
  silver,
  common,
  uncommon,
  rare,
  legendary,
  epic,
  fireRed,
  iceBlue,
  arcanePurple;

  // Primary/secondary/surface/surfaceContainer are theme-dependent — each
  // registered theme (constants.dart's APP_THEMES) has its own asset folder
  // under images/ui/buttons/{themeId}/. Rarity/silver assets are shared
  // across every theme, so they stay in the flat buttons/ directory.
  //
  // barSize is null for the standard (STANDARD_BORDER_SLICE/MIN_SIZE)
  // button-<color>.png asset; QvButton's own optional `size` passes a
  // QvBarSize to instead reach for a smaller-bordered
  // button-<color>-<suffix>.png sibling, mirroring QvInsetBackground's own
  // `size` param. Not every ButtonColor has small/mini variants generated
  // yet — currently just surfaceContainer.
  String assetPath(String themeId, {QvBarSize? barSize}) {
    final suffix = barSize == null ? '' : '-${barSize.assetSuffix}';
    switch (this) {
      case ButtonColor.primary:
        return 'images/ui/buttons/$themeId/button-primary$suffix.png';
      case ButtonColor.secondary:
        return 'images/ui/buttons/$themeId/button-secondary$suffix.png';
      case ButtonColor.surface:
        return 'images/ui/buttons/$themeId/button-surface$suffix.png';
      case ButtonColor.surfaceContainer:
        return 'images/ui/buttons/$themeId/button-surface-container$suffix.png';
      case ButtonColor.silver:
        return 'images/ui/buttons/button-silver$suffix.png';
      case ButtonColor.common:
        return 'images/ui/buttons/button-rarity-common$suffix.png';
      case ButtonColor.uncommon:
        return 'images/ui/buttons/button-rarity-uncommon$suffix.png';
      case ButtonColor.rare:
        return 'images/ui/buttons/button-rarity-rare$suffix.png';
      case ButtonColor.legendary:
        return 'images/ui/buttons/button-rarity-legendary$suffix.png';
      case ButtonColor.epic:
        return 'images/ui/buttons/button-rarity-epic$suffix.png';
      case ButtonColor.fireRed:
        return 'images/ui/buttons/button-fireRed$suffix.png';
      case ButtonColor.iceBlue:
        return 'images/ui/buttons/button-iceBlue$suffix.png';
      case ButtonColor.arcanePurple:
        return 'images/ui/buttons/button-arcanePurple$suffix.png';
    }
  }

  // Pressed-state textures exist for every registered theme's primary/
  // secondary/surface/surfaceContainer assets (generated via the
  // retheme-color Light/Dark-swap technique), plus the skill-colored
  // buttons below (same technique, flat non-theme files). Rarity/silver
  // buttons don't have a pressed variant, so QvButton falls back to the
  // normal texture for those. barSize inserts its suffix before
  // "-pressed" (button-surface-container-small-pressed.png), matching how
  // the small/mini asset family is actually named on disk.
  String? pressedAssetPath(String themeId, {QvBarSize? barSize}) {
    final suffix = barSize == null ? '' : '-${barSize.assetSuffix}';
    switch (this) {
      case ButtonColor.primary:
        return 'images/ui/buttons/$themeId/button-primary$suffix-pressed.png';
      case ButtonColor.secondary:
        return 'images/ui/buttons/$themeId/button-secondary$suffix-pressed.png';
      case ButtonColor.surface:
        return 'images/ui/buttons/$themeId/button-surface$suffix-pressed.png';
      case ButtonColor.surfaceContainer:
        return 'images/ui/buttons/$themeId/button-surface-container$suffix-pressed.png';
      case ButtonColor.fireRed:
        return 'images/ui/buttons/button-fireRed$suffix-pressed.png';
      case ButtonColor.iceBlue:
        return 'images/ui/buttons/button-iceBlue$suffix-pressed.png';
      case ButtonColor.arcanePurple:
        return 'images/ui/buttons/button-arcanePurple$suffix-pressed.png';
      default:
        return null;
    }
  }
}

class QvButton extends StatefulWidget {
  const QvButton({
    super.key,
    this.onTap,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(0),
    this.buttonColor = ButtonColor.primary,
    this.darkened = false,
    this.shadow,
    this.size,
    required this.child,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final ButtonColor buttonColor;
  final bool darkened;
  final List<BoxShadow>? shadow;
  // Opts into a smaller 9-slice border than the standard 36px-minimum one
  // (down to QvBarSize.small's 20px) — for a compact button where the
  // standard border reads oversized relative to its content, same idiom
  // as QvInsetBackground's own `size`. Needs a
  // button-<color>-<suffix>.png asset to exist for buttonColor; not every
  // ButtonColor has small/mini variants generated yet.
  final QvBarSize? size;

  @override
  State<QvButton> createState() => _QvButtonState();
}

class _QvButtonState extends State<QvButton> {
  bool _isPressed = false;

  void _setPressed(bool pressed) {
    if (_isPressed != pressed) {
      setState(() => _isPressed = pressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    final size = widget.size;
    final pressedAssetPath =
        widget.buttonColor.pressedAssetPath(themeId, barSize: size);
    final showPressed = _isPressed && pressedAssetPath != null;
    final slice = size?.slice ?? STANDARD_BORDER_SLICE;
    final minSize = size?.minSize ?? STANDARD_BORDER_MIN_SIZE;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize.width,
        minHeight: minSize.height,
      ),
      child: GestureDetector(
        onTap: widget.onTap ?? () {},
        onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
        onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
        onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: jkAsset(showPressed
                    ? pressedAssetPath
                    : widget.buttonColor.assetPath(themeId, barSize: size)),
                centerSlice: slice,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
                colorFilter: widget.darkened
                    ? ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.5), BlendMode.srcATop)
                    : null,
              ),
              boxShadow: widget.shadow,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
