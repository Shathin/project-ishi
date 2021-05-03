import 'package:flutter/material.dart';

class AppTitleLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            'assets/labcoat/labcoat-512.png',
            height: 64.0,
            width: 64.0,
            semanticLabel: 'Project Ishi Icon',
          ),
          SizedBox(width: 24.0),
          Text(
            'Project Ishi',
            style: Theme.of(context).textTheme.headline1,
          ),
        ],
      ),
    );
  }
}
