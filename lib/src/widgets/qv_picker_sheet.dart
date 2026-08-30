import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'qv_button.dart';
import 'qv_draggable_sheet.dart';
import 'qv_text_styles.dart';

/// A modal-sheet shell for quick in-context actions — a title, a close
/// button, no icon. [body] is expected to manage its own bounded layout
/// (Expanded children, its own scrollables) — see
/// QvDraggableSheet.scrollableBody's own doc comment for why this always
/// passes false.
///
/// This widget only renders the shell — how it gets pushed onto the screen
/// (a bottom sheet, a nav-aware modal route, whatever navigation shape the
/// consuming app uses) is the app's own concern. Add a small app-side
/// helper wrapping QvPickerSheet in whatever `show...` call your app's own
/// navigation stack expects (Questvale's is `showQvPickerSheetModal` in
/// lib/cubits/home/, which wraps its own showNavAwareModalSheet).
class QvPickerSheet extends StatelessWidget {
  const QvPickerSheet({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return QvDraggableSheet(
      header: _PickerHeader(title: title),
      headerHeight: _PickerHeader.totalHeight,
      scrollableBody: false,
      body: body,
    );
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.title});

  final String title;

  static const double _height = 44;
  static const double _bottomSpacing = 10;

  /// Total rendered height — QvDraggableSheet renders this as a fixed
  /// overlay above the body, so it needs to know how much room to reserve.
  static const double totalHeight = _height + _bottomSpacing;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: _bottomSpacing),
      child: SizedBox(
        height: _height,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: QvTextStyles.emphasis
                    .copyWith(color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(width: 12),
            QvButton(
              width: _height,
              height: _height,
              buttonColor: ButtonColor.surfaceContainer,
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Symbols.close,
                weight: 700,
                size: 18,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
