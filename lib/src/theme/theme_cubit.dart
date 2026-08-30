import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_state.dart';
import '../constants.dart';

/// How ThemeCubit loads/saves the chosen theme id — the library has no
/// opinion on *where* that lives (a database row, shared_preferences, a
/// remote profile, ...); the consuming app supplies an implementation that
/// knows its own persistence layer. Questvale's own implementation
/// (CharacterThemePersistence, lib/cubits/theme/) wraps its
/// CharacterRepository, since Questvale stores the theme choice on the
/// Character row.
abstract class ThemePersistence {
  Future<String?> loadThemeId();
  Future<void> saveThemeId(String themeId);
}

// Provided above MaterialApp (typically where only low-level app state is
// available, not the rest of the app's provider tree) so ThemeData can be
// built from the persisted theme choice before the rest of the app's
// subtree exists. This cubit is its own source of truth for the active
// theme — setTheme both persists and emits in one step.
class ThemeCubit extends Cubit<ThemeState> {
  final ThemePersistence persistence;

  ThemeCubit({required this.persistence})
      : super(ThemeState(theme: APP_THEMES[DEFAULT_THEME_ID]!)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeId = await persistence.loadThemeId();
    final theme = APP_THEMES[themeId] ?? APP_THEMES[DEFAULT_THEME_ID]!;
    if (!isClosed) {
      emit(ThemeState(theme: theme));
    }
  }

  Future<void> setTheme(String themeId) async {
    final theme = APP_THEMES[themeId];
    if (theme == null) return;
    await persistence.saveThemeId(themeId);
    if (!isClosed) {
      emit(ThemeState(theme: theme));
    }
  }
}
