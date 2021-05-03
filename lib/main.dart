import 'package:flutter/material.dart';

// ! Third Party libraries
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ! Custom libraries
import 'package:auth_repo/auth_repo.dart';

// ! File Imports
import 'package:project_ishi/theme/theme.dart';
import 'package:project_ishi/auth/sign_up/sign_up.dart';
import 'package:project_ishi/auth/login/login.dart';

Future<void> main() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  // Uncomment to clear shared preferences when required
  // await sharedPreferences.clear();

  AuthRepo authRepo = AuthRepo(sharedPreferences: sharedPreferences);

  runApp(ProjectIshi(authRepo: authRepo));
}

class ProjectIshi extends StatelessWidget {
  final AuthRepo authRepo;

  ProjectIshi({required this.authRepo});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: this.authRepo),
      ],
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        lazy: true,
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) => MaterialApp(
            theme: state.themeData,
            home: context.read<AuthRepo>().isFirstTime
                ? SignUpPage()
                : LoginPage(),
          ),
        ),
      ),
    );
  }
}
