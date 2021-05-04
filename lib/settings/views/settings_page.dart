import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => SettingsPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Settings Page',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
