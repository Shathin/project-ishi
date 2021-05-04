import 'package:flutter/material.dart';

class ViewAllRecordsPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ViewAllRecordsPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'View All Records',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
