part of 'login_cubit.dart';

class LoginState {
  final Password password;
  final FormStatus formStatus;

  const LoginState({
    this.password = const Password.pure(),
    this.formStatus = FormStatus.pure,
  });

  LoginState copyWith({
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FormStatus? formStatus,
  }) {
    return LoginState(
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
