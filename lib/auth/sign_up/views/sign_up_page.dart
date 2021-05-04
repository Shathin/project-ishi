import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';

// ! Third party imports
import 'package:flutter_bloc/flutter_bloc.dart';

// ! File imports
import 'package:project_ishi/auth/sign_up/cubit/sign_up_cubit.dart';
import 'package:project_ishi/auth/sign_up/views/sign_up_form.dart';
import 'package:project_ishi/utils/app_title_large.dart';
import 'package:project_ishi/utils/theme/theme.dart';

class SignUpPage extends StatelessWidget {
  static Route route() => MaterialPageRoute<void>(builder: (_) => SignUpPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ThemeSwitcher(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocProvider<SignUpCubit>(
          create: (_) => SignUpCubit(authRepo: context.read<AuthRepo>()),
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
                    SignUpForm(),
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
