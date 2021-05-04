import 'package:flutter/material.dart';

class GenerateSummaryPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => GenerateSummaryPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Generate Summary',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
