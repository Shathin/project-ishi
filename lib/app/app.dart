import 'package:flutter/material.dart';

class App extends StatelessWidget {
  static Route route() => MaterialPageRoute<void>(builder: (_) => App());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Project Ishi 🥼',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }
}
