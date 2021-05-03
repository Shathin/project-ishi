import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:project_ishi/auth/auth_forms/auth_forms.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo authRepo;
  LoginCubit({required this.authRepo}) : super(const LoginState());

  /// Emits a new [LoginState] when the [oldPasswordChanged] field changes with the updated value of the [oldPasswordChanged] field
  void passwordChanged(String value) {
    final password = Password.dirty(password: value);
    emit(state.copyWith(
      password: password,
      formStatus: validate(password),
    ));
  }

  /// A convinience getter that determines if the current state of form is invalid i.e., password doesn't match regex
  bool get isFormInvalid => state.formStatus == FormStatus.invalid;

  /// The form is [FormStatus.valid] if [password] fields is valid
  FormStatus validate(Password? password) =>
      (password?.isValidPassword ?? false)
          ? FormStatus.valid
          : FormStatus.dirty;

  bool verifyPassword() =>
      this.authRepo.isPasswordMatch(state.password.password);
}
