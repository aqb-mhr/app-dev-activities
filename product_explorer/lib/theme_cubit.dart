import 'package:flutter_bloc/flutter_bloc.dart';

import 'settings_service.dart';

/// `true` = dark mode. Saved with [SettingsService] so the theme is already
/// right the next time the app opens.
class ThemeCubit extends Cubit<bool> {
  final SettingsService _settings;

  ThemeCubit(this._settings, {bool startDark = false}) : super(startDark);

  Future<void> toggle() async {
    final next = !state;
    emit(next);
    await _settings.setDarkMode(next);
  }
}
