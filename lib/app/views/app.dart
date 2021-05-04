import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/app/app.dart';
import 'package:project_ishi/dashboard/dashboard.dart';
import 'package:project_ishi/generate_summary/generate_summary.dart';
import 'package:project_ishi/manage_record/manage_record.dart';
import 'package:project_ishi/manage_template/manage_template.dart';
import 'package:project_ishi/utils/navbar/navbar.dart';
import 'package:project_ishi/view_all_patients/views/view_all_patients_page.dart';
import 'package:project_ishi/view_all_records/view_all_records.dart';

class AppPage extends StatelessWidget {
  static Route route() => MaterialPageRoute<void>(builder: (_) => AppPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: BlocProvider(
          create: (_) => NavigationCubit(),
          child: Container(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Navbar(),
                Expanded(
                  child: BlocBuilder<NavigationCubit, NavigationState>(
                    builder: (context, state) {
                      switch (state.screen) {
                        case Screen.dashboard:
                          return DashboardPage();
                        case Screen.allRecords:
                          return ViewAllRecordsPage();
                        case Screen.addRecord:
                          return ManageRecordPage();
                        case Screen.allPatients:
                          return ViewAllPatientsPage();
                        case Screen.manageTemplate:
                          return ManageTemplatePage();
                        case Screen.summary:
                          return GenerateSummaryPage();
                        default:
                          return DashboardPage();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
