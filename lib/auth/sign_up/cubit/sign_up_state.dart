part of 'sign_up_cubit.dart';

class SignUpState {
  final Password password;
  final ConfirmedPassword confirmedPassword;
  final FormStatus formStatus;

  const SignUpState({
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.formStatus = FormStatus.pure,
  });

  SignUpState copyWith({
    Password? password,
    ConfirmedPassword? confirmedPassword,
    FormStatus? formStatus,
  }) {
    return SignUpState(
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
