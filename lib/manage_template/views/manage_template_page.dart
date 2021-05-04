import 'package:flutter/material.dart';

class ManageTemplatePage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ManageTemplatePage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Manage Template',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
