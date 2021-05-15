import 'package:database_repo/patients_repo.dart';
import 'package:database_repo/records_repo.dart';
import 'package:database_repo/template_repo.dart';
import 'package:database_repo/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/settings/cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => SettingsPage());

  final TextStyle buttonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  Widget buildSnackBar({required String text}) => Container(
        child: Row(
          children: <Widget>[
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(width: 16.0),
            Text(text),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => SettingsCubit(),
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) {
            if (previous.status == SettingsStatus.pageLoaded &&
                (current.status == SettingsStatus.initMockData ||
                    current.status == SettingsStatus.clearData))
              return true;
            else if ((previous.status == SettingsStatus.initMockData ||
                    previous.status == SettingsStatus.clearData) &&
                current.status == SettingsStatus.pageLoaded) return true;
            return false;
          },
          listener: (context, state) {
            if (state.status == SettingsStatus.initMockData) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: buildSnackBar(
                      text:
                          'Initializing Database with Mock Data! Do not navigate away from the page and please wait till the notification of completion!',
                    ),
                  ),
                );
            } else if (state.status == SettingsStatus.clearData) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: buildSnackBar(
                      text:
                          'Clearing the database! Do not navigate away from the page and please wait till the notification of completion!',
                    ),
                  ),
                );
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'Operation completed! You may now navigate away from the page!',
                    ),
                  ),
                );
            }
          },
          builder: (context, state) => Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(32.0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                ),
                Flexible(
                  flex: 8,
                  child: Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 32.0,
                      runSpacing: 32.0,
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: () async {
                            context
                                .read<SettingsCubit>()
                                .operationInitMockData();

                            await MockData.initializeMockPatientsData(
                              patientsDatabase:
                                  context.read<PatientsRepo>().patientsDatabase,
                              patientsStore:
                                  context.read<PatientsRepo>().patientsStore,
                            );

                            await MockData.initializeMockRecordsData(
                              recordsDatabase:
                                  context.read<RecordsRepo>().recordsDatabase,
                              recordsStore:
                                  context.read<RecordsRepo>().recordsStore,
                            );

                            context.read<SettingsCubit>().operationsComplete();
                          },
                          label: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Initialize with Mock Data',
                              style: buttonTextStyle,
                            ),
                          ),
                          icon: FaIcon(FontAwesomeIcons.database),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) => Colors.green,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            context.read<SettingsCubit>().operationClearData();

                            await context
                                .read<PatientsRepo>()
                                .emptyPatientsDatabase();

                            await context
                                .read<RecordsRepo>()
                                .emptyRecordsDatabase();

                            await context
                                .read<TemplateRepo>()
                                .initializeTemplate();

                            context.read<SettingsCubit>().operationsComplete();
                          },
                          label: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Reset Database',
                              style: buttonTextStyle,
                            ),
                          ),
                          icon: FaIcon(FontAwesomeIcons.trash),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) => Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
