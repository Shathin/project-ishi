import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
// ! Third party libraries
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ! File imports
import 'package:auth_repo/auth_repo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Authentication Repository', () {
    late final SharedPreferences sharedPreferences;
    late final AuthRepo authRepo;
    final String password1 = 'sample-password';
    final String password2 = 'invalid-password';

    /// Initializes the variables used throughout testing
    setUpAll(() async {
      sharedPreferences = await SharedPreferences.getInstance();
      authRepo = AuthRepo(sharedPreferences: sharedPreferences);
    });

    /// Clears the shared preferences that were set during testing
    tearDownAll(() async {
      await sharedPreferences.clear();
    });

    test(
      'Test [isFirstTime] getter before registering a password',
      () => expect(
        authRepo.isFirstTime,
        true,
      ),
    );

    test(
      'Test existence of "isFirstTime" preference before registering a password',
      () => expect(
        sharedPreferences.containsKey('isFirstTime'),
        false,
      ),
    );

    test(
      'Test existence of "password" preference before [password] setter invocation',
      () => expect(
        sharedPreferences.containsKey('password'),
        false,
      ),
    );

    test(
      'Test existence of "password" preference after [password] setter invocation',
      () {
        authRepo.password = password1;
        expect(
          sharedPreferences.containsKey('password'),
          true,
        );
      },
    );

    test(
      'Test value of "password" preference after [password] setter invocation',
      () {
        String hashedPassword =
            sha512.convert(utf8.encode(password1)).toString();
        expect(
          sharedPreferences.getString('password'),
          hashedPassword,
        );
      },
    );

    test(
      'Test [isPasswordMatch] method for correct password ',
      () => expect(
        authRepo.isPasswordMatch(password1),
        true,
      ),
    );

    test(
      'Test [isPasswordMatch] method for incorrect password',
      () => expect(
        authRepo.isPasswordMatch(password2),
        false,
      ),
    );

    test(
      'Test [isFirstTime] getter after registering a password',
      () => expect(
        authRepo.isFirstTime,
        false,
      ),
    );

    test(
      'Test existence of "isFirstTime" preference after registering a password',
      () => expect(
        sharedPreferences.containsKey('isFirstTime'),
        true,
      ),
    );

    test(
      'Test value of "isFirstTime" preference after registering a password',
      () => expect(
        authRepo.isFirstTime,
        sharedPreferences.getBool('isFirstTime'),
      ),
    );
  });
}
