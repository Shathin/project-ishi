import 'package:flutter/material.dart';

void main() => runApp(ProjectIshi());

class ProjectIshi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: Scaffold(
        body: Center(
          child: Text(
            "Project Ishi 🥼",
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
