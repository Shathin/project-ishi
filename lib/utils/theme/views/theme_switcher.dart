import 'package:flutter/material.dart';
import 'package:project_ishi/utils/theme/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: context.read<ThemeCubit>().state is LightThemeState
          ? "Switch to Dark Mode"
          : "Switch to Light Mode",
      onPressed: () => context.read<ThemeCubit>().switchTheme(),
      child: context.read<ThemeCubit>().state is LightThemeState
          ? Icon(Icons.brightness_4)
          : Icon(Icons.brightness_5),
    );
  }
}
