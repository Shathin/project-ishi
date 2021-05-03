/// A password model used for managing the state of the [_ConfirmPasswordInput] input field
/// The way of writing this model was inspired from FormzInput package
class ConfirmedPassword {
  final String confirmedPassword;

  /// Constructor that represents the state of the [_ConfirmPasswordInput] when the page first loads and hence has no text in this input field
  const ConfirmedPassword.pure() : confirmedPassword = '';

  /// A constructor that represents the state of the [_ConfirmPasswordInput] when some text has been inputted into this input field
  const ConfirmedPassword.dirty({required this.confirmedPassword});

  /// The password validator method
  /// Compares the text in the [_ConfirmPasswordInput] field obtained from the [confirmedPassword] class member to the [password]  matches the [_passwordRegExp] regular expression
  bool isPasswordMatching(String? password) =>
      this.confirmedPassword.compareTo(password ?? '') == 0 ? true : false;
}
