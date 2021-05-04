part of 'theme_cubit.dart';

/// Abstract representing the current theme
abstract class ThemeState {
  /// Getter to access the [ThemeData] object of the current theme
  abstract final ThemeData themeData;
}

class LightThemeState extends ThemeState {
  final ThemeData _lightThemeData;

  LightThemeState()
      : _lightThemeData = ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
          buttonColor: Colors.blue,
          textTheme: TextTheme(
            headline1: CustomTextTheme.headline1.copyWith(color: Colors.black),
            headline2: CustomTextTheme.headline2.copyWith(color: Colors.black),
            headline3: CustomTextTheme.headline3.copyWith(color: Colors.black),
            headline4: CustomTextTheme.headline4.copyWith(color: Colors.black),
            headline5: CustomTextTheme.headline5.copyWith(color: Colors.black),
            headline6: CustomTextTheme.headline6.copyWith(color: Colors.black),
            subtitle1: CustomTextTheme.subtitle1.copyWith(color: Colors.black),
            subtitle2: CustomTextTheme.subtitle2.copyWith(color: Colors.black),
            bodyText1: CustomTextTheme.bodyText1.copyWith(color: Colors.black),
            bodyText2: CustomTextTheme.bodyText2.copyWith(color: Colors.black),
            button: CustomTextTheme.button.copyWith(color: Colors.black),
            caption: CustomTextTheme.caption.copyWith(color: Colors.black),
            overline: CustomTextTheme.overline.copyWith(color: Colors.black),
          ),
        );

  @override
  ThemeData get themeData => this._lightThemeData;
}

class DarkThemeState extends ThemeState {
  final ThemeData _darkThemeData;

  DarkThemeState()
      : _darkThemeData = ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blue[900],
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue[900],
          ),
          buttonColor: Colors.blue[900],
          textTheme: TextTheme(
            headline1: CustomTextTheme.headline1.copyWith(color: Colors.white),
            headline2: CustomTextTheme.headline2.copyWith(color: Colors.white),
            headline3: CustomTextTheme.headline3.copyWith(color: Colors.white),
            headline4: CustomTextTheme.headline4.copyWith(color: Colors.white),
            headline5: CustomTextTheme.headline5.copyWith(color: Colors.white),
            headline6: CustomTextTheme.headline6.copyWith(color: Colors.white),
            subtitle1: CustomTextTheme.subtitle1.copyWith(color: Colors.white),
            subtitle2: CustomTextTheme.subtitle2.copyWith(color: Colors.white),
            bodyText1: CustomTextTheme.bodyText1.copyWith(color: Colors.white),
            bodyText2: CustomTextTheme.bodyText2.copyWith(color: Colors.white),
            button: CustomTextTheme.button.copyWith(color: Colors.white),
            caption: CustomTextTheme.caption.copyWith(color: Colors.white),
            overline: CustomTextTheme.overline.copyWith(color: Colors.white),
          ),
        );

  @override
  ThemeData get themeData => this._darkThemeData;
}
