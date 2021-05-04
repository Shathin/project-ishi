import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => DashboardPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
