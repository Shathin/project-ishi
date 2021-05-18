import 'dart:convert';

import 'package:logging_repo/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

/// This class helps authenticate a user with only a password and
/// hence to be used only for offline single-user apps that requires a basic authentication to prevent unauthorized access
class AuthRepo {
  final SharedPreferences sharedPreferences;

  AuthRepo({required this.sharedPreferences});

  /// Getter to determine whether the user is opening the application for the first time.
  /// The [isFirstTime] key will be set to [false] only after the user registers a password for authentication
  bool get isFirstTime => this.sharedPreferences.getBool('isFirstTime') ?? true;

  /// Setter to set the [isFirstTime] preference to the [status] argument.
  /// MUST be set only after the user registers a password for authentication
  ///
  /// This is a private setter -> To avoid improper usage from the frontend
  set _isFirstTime(bool status) =>
      this.sharedPreferences.setBool('isFirstTime', status);

  /// Setter to set the [password] preference to the [password] argument.
  /// The password will be stored as a SHA512 hash of the user's password
  set password(String password) => this
          .sharedPreferences
          .setString(
              'password', sha512.convert(utf8.encode(password)).toString())
          .then((value) {
        _isFirstTime = false;
        LoggingService.loggingService.log('setPassword');
      });

  /// A method to determine if the password entered by the user matches the password stored in the preference
  bool isPasswordMatch(String password) {
    String hashedPassword = sha512.convert(utf8.encode(password)).toString();
    String storedPassword = this.sharedPreferences.getString('password') ?? '';

    LoggingService.loggingService.log('isPasswordMatch');

    return hashedPassword.compareTo(storedPassword) == 0 ? true : false;
  }
}
