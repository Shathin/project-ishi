import 'package:flutter/material.dart';

// ! Third party libraries
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/app/app.dart';
import 'package:project_ishi/auth/login/cubit/login_cubit.dart';

// ! File imports

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      constraints: BoxConstraints(
        maxWidth: 512.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.all(16.0),
            child: Text(
              "Login",
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: EdgeInsets.all(16.0),
            child: Text(
              "Enter your secret password",
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 36.0),
          _PasswordInput(),
          const SizedBox(height: 16.0),
          _VerifyPasswordButton()
        ],
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) =>
              context.read<LoginCubit>().passwordChanged(password),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText:
                state.password.isValidPassword ? null : 'Invalid Password!',
            errorMaxLines: 4,
            counterText: 'Minimum length: 4',
            labelStyle: state.password.isValidPassword
                ? null
                : TextStyle(color: Colors.red),
            errorStyle: state.password.isValidPassword
                ? null
                : TextStyle(
                    color: Colors.red,
                    fontSize: 14.0,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            filled: true,
          ),
        );
      },
    );
  }
}

class _VerifyPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => TextButton(
        child: Text("Verify Password"),
        onPressed: context.read<LoginCubit>().isFormInvalid
            ? null
            : () {
                if (context.read<LoginCubit>().verifyPassword()) {
                  Navigator.of(context).pushReplacement(App.route());
                } else {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('❌ Wrong password! Please try again!'),
                      ),
                    );
                }
              },
      ),
    );
  }
}
