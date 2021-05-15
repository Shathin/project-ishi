import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';

// ! Third party libraries
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/auth/auth_forms/auth_forms.dart';
import 'package:project_ishi/auth/login/login.dart';
import 'package:project_ishi/auth/sign_up/cubit/sign_up_cubit.dart';

// ! File imports

class SignUpForm extends StatelessWidget {
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
              "Register a new password",
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: EdgeInsets.all(16.0),
            child: Text(
              "This password is will be required to access the contents of the application",
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 36.0),
          _PasswordInput(),
          const SizedBox(height: 16.0),
          _ConfirmPasswordInput(),
          const SizedBox(height: 16.0),
          _RegisterPasswordButton()
        ],
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) =>
              context.read<SignUpCubit>().passwordChanged(password),
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

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmedPassword != current.confirmedPassword,
      builder: (context, state) {
        return TextField(
          onChanged: (confirmPassword) => context
              .read<SignUpCubit>()
              .confirmedPasswordChanged(confirmPassword),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            errorText: context.read<SignUpCubit>().isFormInvalid
                ? "Passwords don't match"
                : null,
            errorMaxLines: 4,
            labelStyle: context.read<SignUpCubit>().isFormInvalid
                ? TextStyle(color: Colors.red)
                : null,
            errorStyle: context.read<SignUpCubit>().isFormInvalid
                ? TextStyle(
                    color: Colors.red,
                    fontSize: 14.0,
                  )
                : null,
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

class _RegisterPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) => TextButton(
        child: Text("Register Password"),
        // onPressed: state.formStatus == FormStatus.valid
        // ?
        //     : null,
        onPressed: context.read<SignUpCubit>().isFormInvalid
            ? null
            : () async {
                context.read<SignUpCubit>().registerPassword();
                await context.read<TemplateRepo>().initializeTemplate();
                Navigator.of(context).pushReplacement(LoginPage.route());
              },
      ),
    );
  }
}
