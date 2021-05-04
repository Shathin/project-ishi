import 'package:flutter/material.dart';

class ViewAllPatientsPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ViewAllPatientsPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text(
            'View All Patients',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );
  }
}
