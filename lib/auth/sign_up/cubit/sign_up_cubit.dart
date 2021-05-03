import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:project_ishi/auth/auth_forms/auth_forms.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepo authRepo;

  SignUpCubit({required this.authRepo}) : super(const SignUpState());

  /// Emits a new [SignUpState] when the [oldPasswordChanged] field changes with the updated value of the [oldPasswordChanged] field
  void passwordChanged(String value) {
    final password = Password.dirty(password: value);
    emit(state.copyWith(
      password: password,
      formStatus: validate(password, state.confirmedPassword),
    ));
  }

  /// Emits a new [SignUpState] when the [confirmedNewPassword] field changes with the updated value of the [confirmedNewPassword] field
  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(confirmedPassword: value);
    emit(state.copyWith(
      confirmedPassword: confirmedPassword,
      formStatus: validate(state.password, confirmedPassword),
    ));
  }

  /// A convinience getter that determines current status of the form is invalid
  bool get isFormInvalid => state.formStatus == FormStatus.invalid;

  /// A method that evaluates the current status of the form
  /// - The form is [FormStatus.valid] if both the [password] and [confirmedPassword] fields match
  /// - The form is [FormStatus.invalid] if the [password] and [confirmedPassword] fields dont' match
  /// - The form is [FormStatus.dirty] if both the [password] field is invalid
  FormStatus validate(
    Password? password,
    ConfirmedPassword? confirmedPassword,
  ) =>
      (password?.isValidPassword ?? false)
          ? ((confirmedPassword?.isPasswordMatching(password?.password) ??
                  false)
              ? FormStatus.valid
              : FormStatus.invalid)
          : FormStatus.dirty;

  /// Register's the entered password
  void registerPassword() {
    this.authRepo.password = state.password.password;
  }
}
