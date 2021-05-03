import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/theme/theme.dart';

void main() => runApp(ProjectIshi());

class ProjectIshi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      lazy: true,
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) => MaterialApp(
          theme: state.themeData,
          home: Scaffold(
            body: Center(
              child: Text(
                "Project Ishi 🥼",
                style: state.themeData.textTheme.headline1,
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.read<ThemeCubit>().switchTheme(),
              child: context.read<ThemeCubit>().state is LightThemeState
                  ? Icon(
                      Icons.brightness_4,
                    )
                  : Icon(
                      Icons.brightness_5,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
