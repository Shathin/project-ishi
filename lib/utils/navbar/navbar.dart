import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/app/app.dart';
import 'package:project_ishi/utils/navbar/navbar_button.dart';
import 'package:project_ishi/utils/theme/theme.dart';

class Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: context.read<ThemeCubit>().state is LightThemeState
            ? Colors.grey[200]
            : Colors.grey[900],
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            offset: Offset(4, 4),
            color: Colors.black26,
            blurRadius: 4.0,
            // spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // ! App Icon
          Container(
            child: Image.asset(
              'assets/labcoat/labcoat-128.png',
              height: 64.0,
              width: 64.0,
            ),
          ),
          // ! Navbar buttons
          BlocBuilder<NavigationCubit, NavigationState>(
            builder: (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                NavbarButton(
                  tooltip: 'Dashboard',
                  icon: FontAwesomeIcons.home,
                  isSelected: state.screen == Screen.dashboard ? true : false,
                  onPressed: () =>
                      context.read<NavigationCubit>().navigateToDashboard(),
                ),
                NavbarButton(
                  tooltip: 'View All Records',
                  icon: FontAwesomeIcons.bookMedical,
                  isSelected: state.screen == Screen.allRecords ? true : false,
                  onPressed: () => context
                      .read<NavigationCubit>()
                      .navigateToViewAllRecords(),
                ),
                NavbarButton(
                  tooltip: 'View All Patients',
                  icon: FontAwesomeIcons.hospitalUser,
                  isSelected: state.screen == Screen.allPatients ? true : false,
                  onPressed: () => context
                      .read<NavigationCubit>()
                      .navigateToViewAllPatients(),
                ),
                NavbarButton(
                  tooltip: 'Add Record',
                  icon: FontAwesomeIcons.plus,
                  isSelected: state.screen == Screen.addRecord ? true : false,
                  onPressed: () =>
                      context.read<NavigationCubit>().navigateToAddRecord(),
                ),
                NavbarButton(
                  tooltip: 'Generate Summary',
                  icon: FontAwesomeIcons.fileExcel,
                  isSelected: state.screen == Screen.summary ? true : false,
                  onPressed: () => context
                      .read<NavigationCubit>()
                      .navigateToGenerateSummary(),
                ),
                NavbarButton(
                  tooltip: 'Manage Template',
                  icon: FontAwesomeIcons.cogs,
                  isSelected:
                      state.screen == Screen.manageTemplate ? true : false,
                  onPressed: () => context
                      .read<NavigationCubit>()
                      .navigateToManageTemplate(),
                ),
                NavbarButton(
                  tooltip: 'Settings',
                  icon: FontAwesomeIcons.cog,
                  isSelected: state.screen == Screen.settings ? true : false,
                  onPressed: () =>
                      context.read<NavigationCubit>().navigateToSettings(),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // ! Theme switcher
              ThemeSwitcher(),
            ],
          ),
        ],
      ),
    );
  }
}
