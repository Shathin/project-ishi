import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

// ! File imports
import 'package:project_ishi/theme/themes/custom_themes.dart';

// ! Parts
part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(LightThemeState());

  /// Toggles the theme of the application
  ///
  /// Emits a [LightThemeState] if the current theme is dark and
  /// emits a [DarkThemeState] if the current theme is light
  void switchTheme() => state is LightThemeState
      ? emit(DarkThemeState())
      : emit(LightThemeState());
}
