/// A password model used for managing the state of the [_PasswordInput] input field
/// The way of writing this model was inspired from FormzInput package
class Password {
  final String password;

  /// Constructor that represents the state of the [_PasswordInput] when the page first loads and hence has no text in this input field
  const Password.pure() : password = '';

  /// A constructor that represents the state of the [_PasswordInput] when some text has been inputted into this input field
  const Password.dirty({required this.password});

  /// This regular expression matches a string that has at least 4 characters
  static final _passwordRegExp = RegExp(r'.{4,}');

  /// The password validator method.
  /// Compares the text in the [_PasswordInput] field obtained from the [password] class member matches the [_passwordRegExp] regular expression
  bool get isValidPassword => _passwordRegExp.hasMatch(this.password);
}
