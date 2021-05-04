import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/utils/theme/theme.dart';

class NavbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isSelected;

  NavbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: this.tooltip,
      height: 48.0,
      showDuration: Duration(seconds: 1),
      waitDuration: Duration(microseconds: 1),
      verticalOffset: -25,
      margin: EdgeInsets.symmetric(horizontal: 100.0),
      child: Container(
        width: 64.0,
        height: 64.0,
        margin: EdgeInsets.symmetric(vertical: 6.0),
        child: ClipOval(
          child: Material(
            color: this.isSelected
                ? Colors.blue
                : context.read<ThemeCubit>().state is LightThemeState
                    ? Colors.white
                    : Colors.black,
            child: InkWell(
              onTap: this.onPressed,
              child: Center(child: FaIcon(this.icon, size: 28.0)),
            ),
          ),
        ),
      ),
    );
  }
}
