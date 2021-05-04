import 'package:flutter/material.dart';

class ManageRecordPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ManageRecordPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'Manage Record',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
