import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';

// ! Third party imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/auth/login/cubit/login_cubit.dart';

// ! File imports
import 'package:project_ishi/utils/app_title_large.dart';
import 'package:project_ishi/utils/theme/theme.dart';

import 'login_form.dart';

class LoginPage extends StatelessWidget {
  static Route route() => MaterialPageRoute<void>(builder: (_) => LoginPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ThemeSwitcher(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(authRepo: context.read<AuthRepo>()),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppTitleLarge(),
                    SizedBox(
                      width: 1024,
                      child: Divider(
                        height: 64.0,
                      ),
                    ),
                    LoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
