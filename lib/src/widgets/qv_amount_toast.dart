import 'package:flutter/material.dart';
import 'qv_button.dart';
import 'qv_text_styles.dart';

// Shows a transient "<prefix> N <label>" pill about a third of the way down
// the screen — e.g. an app might call this as showAmountToast(context,
// amount: 5, label: 'AP') for a resource gain, or with prefix: '-' and a
// different buttonColor for a loss/damage indicator. Fire-and-forget:
// inserts its own OverlayEntry and removes itself once its animation
// finishes, so callers don't need to hold a reference. Originally two
// near-identical widgets (an "AP gained" toast and a "damage taken" toast)
// that only differed in label text and color — merged into one generic
// shape once this moved out of an app that only ever needed those two.
void showAmountToast(
  BuildContext context, {
  required int amount,
  required String label,
  String prefix = '+',
  ButtonColor buttonColor = ButtonColor.primary,
  Color? textColor,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _AmountToast(
      amount: amount,
      label: label,
      prefix: prefix,
      buttonColor: buttonColor,
      textColor: textColor,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _AmountToast extends StatefulWidget {
  final int amount;
  final String label;
  final String prefix;
  final ButtonColor buttonColor;
  final Color? textColor;
  final VoidCallback onDone;

  const _AmountToast({
    required this.amount,
    required this.label,
    required this.prefix,
    required this.buttonColor,
    required this.textColor,
    required this.onDone,
  });

  @override
  State<_AmountToast> createState() => _AmountToastState();
}

class _AmountToastState extends State<_AmountToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    );
    // Fade-in and hold keep their original ~210ms/~840ms pace; fade-out is
    // stretched to ~700ms (was ~350ms) so the sink-and-fade reads as a slow
    // drift rather than a quick disappear.
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 48),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_controller);
    // Holds in place through the fade-in and hold phases, then sinks
    // downward as it fades out — like a game's floating EXP indicator.
    _translateY = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 60),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 30.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final resolvedTextColor = widget.textColor ?? colorScheme.onPrimary;

    return Positioned(
      bottom: screenHeight / 5,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _translateY.value),
              child: Opacity(opacity: _opacity.value, child: child),
            ),
            child: QvButton(
              buttonColor: widget.buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                '${widget.prefix} ${widget.amount} ${widget.label}',
                style: QvTextStyles.sectionTitle
                    .copyWith(color: resolvedTextColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
